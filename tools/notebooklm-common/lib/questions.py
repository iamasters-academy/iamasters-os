"""The 8 strategic questions — single source of truth.

Previously duplicated literally across ~9 files per skill. Here there are exactly
two tuples (per_source for the extractor, transversal for deep-research) plus
load_questions() for CLI override and adapt_questions() to inject the user's
domain context into each question.
"""
from __future__ import annotations

import json
from dataclasses import dataclass, replace
from pathlib import Path
from typing import Literal

try:
    import yaml
except ImportError:  # yaml only needed for .yaml/.yml overrides; JSON still works
    yaml = None


@dataclass(frozen=True)
class Question:
    num: int
    name: str
    question: str
    type: str


Scope = Literal["per_source", "transversal"]


# per_source scope (notebooklm-extractor): each question targets ONE source.
BASE_QUESTIONS_PER_SOURCE: tuple[Question, ...] = (
    Question(1, "descomposicion_profunda", "Analiza esta fuente específica y descompónla en conceptos clave, supuestos ocultos, matices de nivel experto y lo que la mayoría de los lectores suele pasar por alto.", "descomposicion"),
    Question(2, "analisis_comparativo", "Compara esta fuente con las demás fuentes del notebook. Muestra en qué coinciden, dónde difiere y qué ideas únicas aporta esta fuente específica.", "comparativa"),
    Question(3, "ideas_originales", "Genera 20 ideas originales, oportunidades o aplicaciones inspiradas específicamente en esta fuente.", "ideacion"),
    Question(4, "resumen_ejecutivo", "Crea un resumen ejecutivo de 5 minutos con solo las ideas más estratégicas de esta fuente.", "sintesis"),
    Question(5, "plan_accion", "Con base en esta fuente, crea un plan de acción práctico con primeros pasos, prioridades y fechas límite.", "planificacion"),
    Question(6, "contenido_multiproposito", "Usa esta fuente para generar: una publicación de LinkedIn, esquema de artículo, hilo de tweets e idea de boletín informativo.", "content-marketing"),
    Question(7, "sistematizacion", "Convierte las ideas de esta fuente en un marco de trabajo práctico, lista de verificación o sistema repetible.", "sistematizacion"),
    Question(8, "analisis_critico", "Presenta los argumentos más sólidos a favor y en contra de la tesis principal de esta fuente, como lo harían expertos debatiendo.", "critica"),
)


# transversal scope (notebooklm-experto-deepresearch): each question targets ALL sources.
BASE_QUESTIONS_TRANSVERSAL: tuple[Question, ...] = (
    Question(1, "descomposicion_profunda", "Descompón estas fuentes en conceptos clave, supuestos ocultos, matices de nivel experto y lo que la mayoría de lectores suele pasar por alto.", "descomposicion"),
    Question(2, "analisis_comparativo", "Compara todas las fuentes cargadas. Muestra en qué coinciden, dónde difieren y qué ideas únicas aporta cada fuente.", "comparativa"),
    Question(3, "generacion_ideas", "Genera 20 ideas originales, oportunidades o aplicaciones inspiradas en los materiales que he subido.", "ideacion"),
    Question(4, "resumen_ejecutivo", "Crea un resumen ejecutivo de 5 minutos con solo las ideas más estratégicas.", "sintesis"),
    Question(5, "plan_accion", "Con base en todo en estas fuentes, crea un plan de acción práctico con primeros pasos, prioridades y fechas límite.", "planificacion"),
    Question(6, "contenido_multiproposito", "Usa estas fuentes para generar: una publicación de Instagram, TikTok, LinkedIn, esquema de artículo, hilo de tweets e idea de boletín informativo.", "content-marketing"),
    Question(7, "sistematizacion", "Convierte las ideas de estas fuentes en un marco de trabajo práctico, lista de verificación o sistema repetible.", "sistematizacion"),
    Question(8, "analisis_critico", "Presenta los argumentos más sólidos a favor y en contra de la tesis principal de estas fuentes, como lo harían expertos debatiendo.", "critica"),
)


def _base_for(scope: Scope) -> tuple[Question, ...]:
    return BASE_QUESTIONS_PER_SOURCE if scope == "per_source" else BASE_QUESTIONS_TRANSVERSAL


def load_questions(path: Path | str | None, *, scope: Scope) -> list[Question]:
    """Load the 8 questions: from a YAML/JSON override file, or the built-in base for scope."""
    base = _base_for(scope)
    if path is None:
        return list(base)

    p = Path(path)
    raw = p.read_text(encoding="utf-8")
    if p.suffix.lower() in (".yaml", ".yml"):
        if yaml is None:
            raise RuntimeError("PyYAML required for .yaml question files: pip install PyYAML")
        data = yaml.safe_load(raw)
    else:
        data = json.loads(raw)

    items = data.get("questions", data) if isinstance(data, dict) else data
    if not isinstance(items, list):
        raise ValueError(f"Question file {p} must contain a list of questions")

    qs: list[Question] = []
    for i, it in enumerate(items, 1):
        if not isinstance(it, dict) or "name" not in it or "question" not in it:
            raise ValueError(f"Question #{i} in {p} must have 'name' and 'question'")
        qs.append(Question(
            num=int(it.get("num", i)),
            name=it["name"],
            question=it["question"],
            type=it.get("type", ""),
        ))
    return qs


def adapt_questions(qs: list[Question], domain: str | None) -> list[Question]:
    """Inject the user's domain context into each question. None/empty → unchanged."""
    if not domain:
        return list(qs)
    prefix = f"Contexto del dominio: {domain.strip()}. "
    return [replace(q, question=prefix + q.question) for q in qs]
