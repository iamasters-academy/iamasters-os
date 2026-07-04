---
name: developer-growth-analysis
description: Analiza tu historial de código reciente para detectar patrones, gaps de desarrollo y áreas de mejora, cura recursos de aprendizaje y genera un informe. Úsala cuando el operador diga "analiza mi historial de código", "en qué estoy fallando programando", "dónde puedo mejorar como dev", "detecta mis gaps técnicos", o quiera un informe de sus patrones de desarrollo.
---

# Developer Growth Analysis

Analyzes your development patterns and habits based on your Claude Code interaction history to provide data-driven insights for growth.

## Core Process

1. **Read History**: Access local chat history  from the past 24-48 hours.
2. **Analyze Patterns**: Identify projects, domains (frontend, backend, etc.), technologies used, and types of problems solved.
3. **Detect Gaps**: Look for repeated struggles, complex decisions, or knowledge gaps (e.g., async patterns, TS utility types).
4. **Generate Report**: Create a structured summary including work focus, prioritized improvement areas, and strengths.
5. **Curate Resources**: Find high-quality articles (e.g., from HackerNews) that directly address the identified gaps.
6. **Delivery**: Send the report as a clean markdown artifact or deliver via Slack DMs if connected.

## Report Structure

- **Work Summary**: Overview of technologies and projects touched.
- **Improvement Areas**: Prioritized list with "Why it matters", "Observations", and "Recommendations".
- **Strengths**: Positive patterns to continue.
- **Action Items**: Sequence of concrete steps.
- **Learning Resources**: Links to articles and discussions.

## Best Practices
- Run this weekly to track progress.
- Focus on one improvement area at a time.
- Use evidence-based observations from real code samples in history.
