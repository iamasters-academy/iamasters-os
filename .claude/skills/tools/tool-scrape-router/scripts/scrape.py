#!/usr/bin/env python3
"""
scrape.py — deterministic runner for tool-scrape-router.

Two modes:
  --probe                 Report available capabilities as JSON (routing is
                          capability-aware: pick among what is actually installed).
  --url <URL> ...         Extract a page via the zero-cost escalation ladder:
                            1) httpx + trafilatura  (fast, no browser, free)
                            2) Firecrawl API        (if FIRECRAWL_API_KEY set)
                            3) crawl4ai             (if installed, local markdown)
                            4) playwright           (if installed, JS render)

Design rules:
  - No hardcoded secrets. FIRECRAWL_API_KEY is read from the environment
    (optionally loaded from a local .env by the caller).
  - Fail loud, never silent: every rung logs to stderr why it failed before
    escalating. The manifest records the full ladder that was tried.
  - Respect robots.txt by default (skip with --ignore-robots only when the
    operator has authorization).
  - Cross-platform (pure Python; heavy deps are optional and probed, never assumed).

Usage:
  python scrape.py --probe
  python scrape.py --url https://example.com --out ./out --format markdown
  python scrape.py --url https://site --mode static --out ./out
"""
from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.robotparser
from datetime import datetime, timezone
from pathlib import Path
from urllib.parse import urlparse

DEFAULT_UA = (
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/125.0 Safari/537.36"
)


def _log(msg: str) -> None:
    """Log to stderr so stdout stays machine-parseable (JSON/data)."""
    print(f"[scrape] {msg}", file=sys.stderr)


def _has(mod: str) -> bool:
    import importlib.util

    return importlib.util.find_spec(mod) is not None


def probe() -> dict:
    """Report what this environment can actually do."""
    return {
        "python": sys.version.split()[0],
        "platform": sys.platform,
        "httpx": _has("httpx"),
        "trafilatura": _has("trafilatura"),
        "markitdown": _has("markitdown"),
        "crawl4ai": _has("crawl4ai"),
        "playwright": _has("playwright"),
        "scrapy": _has("scrapy"),
        "firecrawl_key": bool(os.environ.get("FIRECRAWL_API_KEY")),
    }


def robots_allowed(url: str, ua: str = DEFAULT_UA) -> bool | None:
    """Return True/False per robots.txt, or None if it can't be determined."""
    try:
        parts = urlparse(url)
        robots_url = f"{parts.scheme}://{parts.netloc}/robots.txt"
        rp = urllib.robotparser.RobotFileParser()
        rp.set_url(robots_url)
        rp.read()
        return rp.can_fetch(ua, url)
    except Exception as e:  # noqa: BLE001 — robots is best-effort, never fatal
        _log(f"robots.txt check inconclusive ({e}); treating as unknown")
        return None


# ---- Ladder rungs -----------------------------------------------------------
# Each rung returns (text, meta) on success or raises to escalate.


def rung_httpx_trafilatura(url: str, ua: str) -> tuple[str, dict]:
    import httpx  # local import so --probe works without deps
    import trafilatura

    with httpx.Client(follow_redirects=True, timeout=30, headers={"User-Agent": ua}) as c:
        r = c.get(url)
    if r.status_code in (403, 429) or r.status_code >= 500:
        raise RuntimeError(f"blocked/error http {r.status_code}")
    extracted = trafilatura.extract(
        r.text, include_links=True, output_format="markdown", url=url
    )
    if not extracted or len(extracted.strip()) < 40:
        raise RuntimeError("empty/thin extraction (likely JS-rendered)")
    return extracted, {"http_status": r.status_code}


def rung_firecrawl(url: str, ua: str) -> tuple[str, dict]:
    import httpx

    key = os.environ.get("FIRECRAWL_API_KEY")
    if not key:
        raise RuntimeError("no FIRECRAWL_API_KEY")
    with httpx.Client(timeout=60) as c:
        r = c.post(
            "https://api.firecrawl.dev/v1/scrape",
            headers={"Authorization": f"Bearer {key}", "Content-Type": "application/json"},
            json={"url": url, "formats": ["markdown"], "onlyMainContent": True},
        )
    r.raise_for_status()
    md = (r.json().get("data") or {}).get("markdown")
    if not md:
        raise RuntimeError("firecrawl returned no markdown")
    return md, {"http_status": r.status_code}


def rung_crawl4ai(url: str, ua: str) -> tuple[str, dict]:
    import asyncio

    from crawl4ai import AsyncWebCrawler  # type: ignore

    async def _run() -> str:
        async with AsyncWebCrawler() as crawler:
            res = await crawler.arun(url=url)
            return res.markdown or ""

    md = asyncio.run(_run())
    if not md.strip():
        raise RuntimeError("crawl4ai returned empty markdown")
    return md, {}


def rung_playwright(url: str, ua: str) -> tuple[str, dict]:
    from playwright.sync_api import sync_playwright  # type: ignore

    with sync_playwright() as p:
        browser = p.chromium.launch()
        page = browser.new_page(user_agent=ua)
        page.goto(url, wait_until="networkidle", timeout=45000)
        html = page.content()
        browser.close()
    try:
        import trafilatura

        md = trafilatura.extract(html, output_format="markdown", url=url) or html
    except Exception:  # noqa: BLE001 — fall back to raw html if trafilatura absent
        md = html
    return md, {}


LADDER = [
    ("httpx+trafilatura", rung_httpx_trafilatura),
    ("firecrawl", rung_firecrawl),
    ("crawl4ai", rung_crawl4ai),
    ("playwright", rung_playwright),
]


def extract(url: str, mode: str, ua: str, ignore_robots: bool) -> dict:
    allowed = robots_allowed(url, ua)
    if allowed is False and not ignore_robots:
        return {
            "url": url,
            "tool_used": None,
            "ladder_tried": [],
            "robots_allowed": False,
            "error": "robots.txt disallows this path; refusing (use --ignore-robots "
            "only with authorization)",
        }

    # mode=markdown skips the plain httpx rung and goes straight to clean-markdown tools.
    rungs = LADDER
    if mode == "render":
        rungs = [r for r in LADDER if r[0] == "playwright"] or LADDER
    elif mode == "markdown":
        rungs = [r for r in LADDER if r[0] != "httpx+trafilatura"] or LADDER

    tried: list[dict] = []
    for name, fn in rungs:
        try:
            text, meta = fn(url, ua)
            tried.append({"rung": name, "ok": True})
            return {
                "url": url,
                "tool_used": name,
                "ladder_tried": tried,
                "robots_allowed": allowed,
                "chars": len(text),
                "text": text,
                **meta,
            }
        except ImportError:
            tried.append({"rung": name, "ok": False, "why": "not installed"})
            _log(f"{name}: not installed, escalating")
        except Exception as e:  # noqa: BLE001 — log and escalate to next rung
            tried.append({"rung": name, "ok": False, "why": str(e)})
            _log(f"{name}: failed ({e}), escalating")

    return {
        "url": url,
        "tool_used": None,
        "ladder_tried": tried,
        "robots_allowed": allowed,
        "error": "all rungs failed; install a heavier tool or route to Apify MCP",
    }


def write_output(result: dict, out_dir: str, fmt: str) -> None:
    out = Path(out_dir)
    out.mkdir(parents=True, exist_ok=True)
    text = result.pop("text", None)
    if text is not None:
        ext = {"markdown": "md", "text": "txt", "json": "json"}.get(fmt, "md")
        (out / f"data.{ext}").write_text(text, encoding="utf-8")
    manifest = {
        **result,
        "format": fmt,
        "generated_at": datetime.now(timezone.utc).isoformat(),
    }
    (out / "manifest.json").write_text(
        json.dumps(manifest, ensure_ascii=False, indent=2), encoding="utf-8"
    )
    _log(f"wrote {out/'manifest.json'}" + (f" + data.{ext}" if text is not None else ""))


def main() -> int:
    ap = argparse.ArgumentParser(description="tool-scrape-router runner")
    ap.add_argument("--probe", action="store_true", help="report capabilities as JSON")
    ap.add_argument("--url", help="URL to extract")
    ap.add_argument("--mode", default="auto", choices=["auto", "static", "markdown", "render"])
    ap.add_argument("--format", default="markdown", choices=["markdown", "text", "json"])
    ap.add_argument("--out", default=None, help="output dir (writes data.* + manifest.json)")
    ap.add_argument("--ua", default=DEFAULT_UA, help="User-Agent header")
    ap.add_argument("--ignore-robots", action="store_true", help="only with authorization")
    args = ap.parse_args()

    if args.probe:
        print(json.dumps(probe(), indent=2))
        return 0

    if not args.url:
        ap.error("--url is required unless --probe")

    result = extract(args.url, args.mode, args.ua, args.ignore_robots)

    if args.out:
        write_output(result, args.out, args.format)
    else:
        # No --out: print manifest (without the full text) to stdout for piping.
        preview = dict(result)
        txt = preview.pop("text", None)
        if txt is not None:
            preview["chars"] = len(txt)
        print(json.dumps(preview, ensure_ascii=False, indent=2))

    return 0 if result.get("tool_used") else 1


if __name__ == "__main__":
    raise SystemExit(main())
