"""FIX M1: outputs resolve under <cwd>/<project>/conocimiento/..., never inside the skill."""
import pytest

from lib.paths import list_projects, resolve_output_dir, slugify


def test_resolve_output_dir_under_project(tmp_project):
    out = resolve_output_dir("projects/demo", "nb-1", base=tmp_project)
    assert out == tmp_project / "projects" / "demo" / "conocimiento" / "notebooklm-extracted" / "nb-1"


def test_resolve_output_dir_requires_project(tmp_project):
    with pytest.raises(ValueError):
        resolve_output_dir(None, "nb-1", base=tmp_project)


def test_slugify():
    assert slugify("Análisis Táctico 2026") == "análisis-táctico-2026"
    assert slugify("Modelos xG / avanzados!!") == "modelos-xg-avanzados"
    assert slugify("   espacios   ") == "espacios"
    assert slugify("") == ""


def test_list_projects(tmp_project):
    projects = list_projects(base=tmp_project)
    assert "projects/demo" in projects


def test_list_projects_includes_clients(tmp_project):
    (tmp_project / "clients" / "acme").mkdir(parents=True)
    (tmp_project / "clients" / "acme" / "conocimiento").mkdir()
    projects = list_projects(base=tmp_project)
    assert "projects/demo" in projects
    assert "clients/acme" in projects
