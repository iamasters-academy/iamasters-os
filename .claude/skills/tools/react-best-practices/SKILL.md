---
name: react-best-practices
description: Guías de desarrollo React/Next.js: hooks, patrones de componente, gestión de estado y optimización de rendimiento. Úsala cuando el operador diga o pida "buenas prácticas de React", "revisa mi componente React", "optimiza el rendimiento de esta app React", "cómo estructuro este hook/estado", "patrón correcto en Next.js" o construya/refactorice frontend React. Paso de implementación en la cadena de construir web/app.
author: vercel
category: development
tags: [react, typescript, nextjs]
---

# React Best Practices

Modern guidelines for building performant, maintainable React and Next.js applications.

## Component Patterns
- **Functional Components**: Use arrow functions and Hooks for all components.
- **Composition**: Favor composition over inheritance; use children props for layout wrappers.
- **Typed Props**: Define interfaces for all component props using TypeScript.

## Hooks & State
- **Rule of Hooks**: Never call hooks inside loops, conditions, or nested functions.
- **Custom Hooks**: Extract complex logic into reusable custom hooks (e.g., `useAuth`, `useFetch`).
- **State Management**: Use local state (`useState`) for UI state, and context or specialized stores for global data.

## Performance
- **Memoization**: Use `useMemo` and `useCallback` sparingly to avoid expensive re-renders on every update.
- **Lazy Loading**: Use `React.lazy` and `Suspense` for large components or route-based code splitting.
- **Key Prop**: Always provide unique, stable `key` props for list items.

*Refer to [Vercel's official guidelines](https://github.com/vercel-labs/agent-skills) for specific enterprise patterns.*

## Referencias

- [vercel-labs/agent-skills](https://github.com/vercel-labs/agent-skills) — Base original de la skill
- Licencia: No especificada en repo original
