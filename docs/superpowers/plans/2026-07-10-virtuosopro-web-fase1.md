# Virtuosopro.digital — Fase 1: Fundación + Home — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Scaffold el sitio Next.js de `virtuosopro.digital` (proyecto `virtuoso-web`) con la capa SEO/GEO/AEO completa y una Home real y desplegada — la base sobre la que se construyen las páginas de nicho y capacidad en fases siguientes.

**Architecture:** Next.js 16 (App Router) + Tailwind CSS 4 + TypeScript, mismo stack exacto que `projects/cct-sitio-web` (referencia ya en producción). Sin CMS ni base de datos — contenido en código (`src/lib/`). Desplegado en Vercel.

**Tech Stack:** Next.js 16.2.x, React 19.2.x, Tailwind CSS 4, TypeScript 5, ESLint 9 (flat config), `next/font/google` (Poppins + Raleway).

**Nota sobre testing:** el proyecto de referencia (`cct-sitio-web`) no usa ningún framework de tests — es un sitio de contenido sin lógica de negocio que lo justifique. Este plan sigue ese mismo patrón: cada tarea se verifica con `npm run build` (falla si hay errores de tipos/compilación) y una revisión visual en `npm run dev`, no con tests unitarios. Si una tarea futura introduce lógica real (ej. el formulario de contacto, el widget de diagnóstico), esa sí debe llevar test.

**Alcance de este plan:** solo Fase 1 (fundación + Home). Las páginas de nicho (`/restaurantes`, `/colegios`...) y de capacidad (`/soluciones/...`) son fases 2+ con su propio plan, una vez esta fase esté desplegada y revisada — así cada fase entrega software funcionando y verificable por sí solo (spec: `docs/superpowers/specs/2026-07-10-virtuosopro-sitio-web-design.md`).

---

## File Structure

```
projects/Virtuoso_Agency/virtuoso-web/
├── package.json
├── tsconfig.json
├── next.config.ts
├── postcss.config.mjs
├── eslint.config.mjs
├── .gitignore
├── public/
│   └── llms.txt
└── src/
    ├── app/
    │   ├── layout.tsx        — layout raíz: fuentes, Organization JSON-LD, Nav, Footer
    │   ├── page.tsx           — Home
    │   ├── globals.css        — Tailwind + tokens de marca
    │   ├── sitemap.ts
    │   └── robots.ts
    ├── lib/
    │   ├── seo.tsx            — SITE config + builders de JSON-LD (Organization/Service/Breadcrumb/FAQ)
    │   └── site-config.ts     — nav, secciones del portafolio, capacidades (fuente única de verdad)
    └── components/
        ├── Nav.tsx
        ├── Footer.tsx
        ├── Hero.tsx
        ├── NicheSelectorGrid.tsx
        ├── MetricTicker.tsx
        └── CTASection.tsx
```

---

### Task 1: Scaffold del proyecto Next.js

**Files:**
- Create: `projects/Virtuoso_Agency/virtuoso-web/package.json`
- Create: `projects/Virtuoso_Agency/virtuoso-web/tsconfig.json`
- Create: `projects/Virtuoso_Agency/virtuoso-web/next.config.ts`
- Create: `projects/Virtuoso_Agency/virtuoso-web/postcss.config.mjs`
- Create: `projects/Virtuoso_Agency/virtuoso-web/eslint.config.mjs`
- Create: `projects/Virtuoso_Agency/virtuoso-web/.gitignore`

- [ ] **Step 1: Crear `package.json`**

```json
{
  "name": "virtuoso-web",
  "version": "0.1.0",
  "private": true,
  "scripts": {
    "dev": "next dev",
    "build": "next build",
    "start": "next start",
    "lint": "eslint"
  },
  "dependencies": {
    "next": "16.2.10",
    "react": "19.2.4",
    "react-dom": "19.2.4"
  },
  "devDependencies": {
    "@tailwindcss/postcss": "^4",
    "@types/node": "^20",
    "@types/react": "^19",
    "@types/react-dom": "^19",
    "eslint": "^9",
    "eslint-config-next": "16.2.10",
    "tailwindcss": "^4",
    "typescript": "^5"
  }
}
```

- [ ] **Step 2: Crear `tsconfig.json`**

```json
{
  "compilerOptions": {
    "target": "ES2017",
    "lib": ["dom", "dom.iterable", "esnext"],
    "allowJs": true,
    "skipLibCheck": true,
    "strict": true,
    "noEmit": true,
    "esModuleInterop": true,
    "module": "esnext",
    "moduleResolution": "bundler",
    "resolveJsonModule": true,
    "isolatedModules": true,
    "jsx": "react-jsx",
    "incremental": true,
    "plugins": [{ "name": "next" }],
    "paths": { "@/*": ["./src/*"] }
  },
  "include": [
    "next-env.d.ts",
    "**/*.ts",
    "**/*.tsx",
    ".next/types/**/*.ts",
    ".next/dev/types/**/*.ts",
    "**/*.mts"
  ],
  "exclude": ["node_modules"]
}
```

- [ ] **Step 3: Crear `next.config.ts`**

```typescript
import type { NextConfig } from 'next';

const nextConfig: NextConfig = {};

export default nextConfig;
```

- [ ] **Step 4: Crear `postcss.config.mjs`**

```javascript
const config = {
  plugins: {
    '@tailwindcss/postcss': {},
  },
};

export default config;
```

- [ ] **Step 5: Crear `eslint.config.mjs`**

```javascript
import { defineConfig, globalIgnores } from 'eslint/config';
import nextVitals from 'eslint-config-next/core-web-vitals';
import nextTs from 'eslint-config-next/typescript';

const eslintConfig = defineConfig([
  ...nextVitals,
  ...nextTs,
  globalIgnores(['.next/**', 'out/**', 'build/**', 'next-env.d.ts']),
]);

export default eslintConfig;
```

- [ ] **Step 6: Crear `.gitignore`**

```
node_modules
.next
out
*.tsbuildinfo
next-env.d.ts
.vercel
.DS_Store
```

- [ ] **Step 7: Instalar dependencias**

Run: `cd projects/Virtuoso_Agency/virtuoso-web && npm install`
Expected: instala sin errores, genera `package-lock.json` y `node_modules/`

- [ ] **Step 8: Commit**

```bash
git add projects/Virtuoso_Agency/virtuoso-web/package.json projects/Virtuoso_Agency/virtuoso-web/package-lock.json projects/Virtuoso_Agency/virtuoso-web/tsconfig.json projects/Virtuoso_Agency/virtuoso-web/next.config.ts projects/Virtuoso_Agency/virtuoso-web/postcss.config.mjs projects/Virtuoso_Agency/virtuoso-web/eslint.config.mjs projects/Virtuoso_Agency/virtuoso-web/.gitignore
git commit -m "chore(virtuoso-web): scaffold Next.js project"
```

---

### Task 2: Design tokens y CSS global

**Files:**
- Create: `projects/Virtuoso_Agency/virtuoso-web/src/app/globals.css`

- [ ] **Step 1: Crear `globals.css` con los tokens de marca de `IDENTIDAD.md`**

```css
@import "tailwindcss";

/* ── Design tokens — IDENTIDAD.md ──────────────────────────────── */
:root {
  --primary: #1e0a80;    /* Azul */
  --primary-dark: #1a1a2e; /* Azul Fuerte */
  --cyan: #5CD4E6;       /* Acento frío */
  --yellow: #dee800;     /* Acento cálido */
  --white: #ffffff;
  --gray: #6b7280;
  --gray-light: #f8f9fa;
  --border: #e5e7eb;
}

/* ── Reset ──────────────────────────────────────────────────────── */
*, *::before, *::after { box-sizing: border-box; margin: 0; padding: 0; }
html { scroll-behavior: smooth; }
body {
  font-family: var(--font-body, 'Raleway', system-ui, sans-serif);
  color: var(--primary-dark);
  background: var(--white);
  -webkit-font-smoothing: antialiased;
}
h1, h2, h3, h4 {
  font-family: var(--font-display, 'Poppins', system-ui, sans-serif);
  font-weight: 800;
}
img { max-width: 100%; height: auto; display: block; }
a { color: inherit; text-decoration: none; }

/* ── Utility ────────────────────────────────────────────────────── */
.container { max-width: 1140px; margin: 0 auto; padding: 0 24px; }
@media (min-width: 640px) { .container { padding: 0 40px; } }
```

- [ ] **Step 2: Commit**

```bash
git add projects/Virtuoso_Agency/virtuoso-web/src/app/globals.css
git commit -m "feat(virtuoso-web): brand design tokens"
```

---

### Task 3: Capa SEO/GEO/AEO (`src/lib/seo.tsx`)

**Files:**
- Create: `projects/Virtuoso_Agency/virtuoso-web/src/lib/seo.tsx`

- [ ] **Step 1: Crear `seo.tsx`** — mismo patrón que `cct-sitio-web/src/lib/seo.tsx`, adaptado a Virtuoso IA:

```tsx
// Central SEO/GEO/AEO config: site constants + JSON-LD builders.
// GEO = Generative Engine Optimization (AI Overviews, Perplexity, ChatGPT search)
// AEO = Answer Engine Optimization (featured snippets, direct answers)

export const SITE = {
  name: 'Virtuoso IA',
  shortName: 'Virtuoso',
  url: 'https://virtuosopro.digital',
  email: 'ia@virtuosopro.digital',
  country: 'MX',
  description:
    'Virtuoso IA desarrolla sistemas de inteligencia artificial especializados por industria en México: agentes de WhatsApp, automatización financiera, gestión de reputación y sitios web optimizados para buscadores de IA.',
  ogImage: '/og-image.png',
} as const;

/* ── Organization (root layout) ──────────────────────────────────── */
export function orgJsonLd() {
  return {
    '@context': 'https://schema.org',
    '@type': 'Organization',
    '@id': `${SITE.url}/#organization`,
    name: SITE.name,
    alternateName: SITE.shortName,
    url: SITE.url,
    description: SITE.description,
    email: SITE.email,
    address: { '@type': 'PostalAddress', addressCountry: SITE.country },
    areaServed: { '@type': 'Country', name: 'México' },
    knowsAbout: [
      'Automatización con inteligencia artificial',
      'Agentes de WhatsApp',
      'Gestión de reputación con IA',
      'SEO, GEO y AEO',
      'Automatización financiera',
      'Sistemas operativos de gestión',
    ],
  };
}

/* ── Service (páginas de nicho / capacidad) ──────────────────────── */
export function serviceJsonLd(opts: {
  name: string;
  description: string;
  slug: string;
  audience: string[];
}) {
  return {
    '@context': 'https://schema.org',
    '@type': 'Service',
    name: opts.name,
    description: opts.description,
    url: `${SITE.url}/${opts.slug}`,
    provider: { '@id': `${SITE.url}/#organization` },
    areaServed: { '@type': 'Country', name: 'México' },
    audience: opts.audience.map((a) => ({ '@type': 'Audience', audienceType: a })),
  };
}

/* ── BreadcrumbList ───────────────────────────────────────────────── */
export function breadcrumbJsonLd(items: { name: string; path: string }[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'BreadcrumbList',
    itemListElement: items.map((item, i) => ({
      '@type': 'ListItem',
      position: i + 1,
      name: item.name,
      item: `${SITE.url}${item.path}`,
    })),
  };
}

/* ── FAQPage (AEO: respuestas directas para motores de IA) ───────── */
export function faqJsonLd(faqs: { question: string; answer: string }[]) {
  return {
    '@context': 'https://schema.org',
    '@type': 'FAQPage',
    mainEntity: faqs.map((f) => ({
      '@type': 'Question',
      name: f.question,
      acceptedAnswer: { '@type': 'Answer', text: f.answer },
    })),
  };
}

/* ── Render helper ────────────────────────────────────────────────── */
export function JsonLd({ data }: { data: object | object[] }) {
  const items = Array.isArray(data) ? data : [data];
  return (
    <>
      {items.map((item, i) => (
        <script
          key={i}
          type="application/ld+json"
          dangerouslySetInnerHTML={{ __html: JSON.stringify(item) }}
        />
      ))}
    </>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add projects/Virtuoso_Agency/virtuoso-web/src/lib/seo.tsx
git commit -m "feat(virtuoso-web): SEO/GEO/AEO lib (Organization, Service, FAQ JSON-LD)"
```

---

### Task 4: Configuración del sitio (`src/lib/site-config.ts`)

**Files:**
- Create: `projects/Virtuoso_Agency/virtuoso-web/src/lib/site-config.ts`

Fuente única de verdad para nav y contenido de la Home. Solo incluye rutas que YA EXISTEN en esta fase (Home); las de nicho/capacidad se agregan a este archivo en sus propias fases — así el nav nunca enlaza a una página que no existe.

- [ ] **Step 1: Crear `site-config.ts`**

```typescript
export type NicheCard = {
  slug: string;
  label: string;
  description: string;
  live: boolean; // true = ruta ya construida, enlaza; false = "próximamente", sin link
};

export const NICHES: NicheCard[] = [
  { slug: 'restaurantes', label: 'Restaurantes', description: 'Reservas, WhatsApp y CRM en un solo sistema.', live: false },
  { slug: 'hoteles', label: 'Hoteles', description: 'Agente de reservas conversacional 24/7.', live: false },
  { slug: 'colegios', label: 'Colegios', description: 'Admisiones automatizadas con IA.', live: false },
  { slug: 'inmobiliarias', label: 'Inmobiliarias', description: 'Inventario, WhatsApp y CRM sincronizados.', live: false },
];

export const METRICS = [
  { value: '+40%', label: 'ventas en 30 días (caso Al Bat)' },
  { value: '38%', label: 'mejor conversión en admisiones (caso Colegio Boston)' },
  { value: '<2 min', label: 'tiempo de respuesta promedio' },
  { value: '24/7', label: 'atención sin intervención manual' },
];

export const NAV_LINKS = [
  { href: '/diagnostico', label: 'Diagnóstico gratuito' },
  { href: '/sesion-crecimiento', label: 'Sesión de Crecimiento' },
  { href: '/contacto', label: 'Contacto' },
];
```

- [ ] **Step 2: Commit**

```bash
git add projects/Virtuoso_Agency/virtuoso-web/src/lib/site-config.ts
git commit -m "feat(virtuoso-web): site config — nichos y métricas de la Home"
```

---

### Task 5: `sitemap.ts`, `robots.ts`, `llms.txt`

**Files:**
- Create: `projects/Virtuoso_Agency/virtuoso-web/src/app/sitemap.ts`
- Create: `projects/Virtuoso_Agency/virtuoso-web/src/app/robots.ts`
- Create: `projects/Virtuoso_Agency/virtuoso-web/public/llms.txt`

- [ ] **Step 1: Crear `sitemap.ts`** — solo rutas que existen en esta fase:

```typescript
import type { MetadataRoute } from 'next';
import { SITE } from '@/lib/seo';

export default function sitemap(): MetadataRoute.Sitemap {
  return [
    { url: SITE.url, changeFrequency: 'weekly', priority: 1 },
  ];
}
```

- [ ] **Step 2: Crear `robots.ts`** — permite explícitamente crawlers de IA (mismo patrón que CCT, clave para GEO):

```typescript
import type { MetadataRoute } from 'next';
import { SITE } from '@/lib/seo';

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [
      { userAgent: '*', allow: '/' },
      { userAgent: 'GPTBot', allow: '/' },
      { userAgent: 'ChatGPT-User', allow: '/' },
      { userAgent: 'ClaudeBot', allow: '/' },
      { userAgent: 'Claude-Web', allow: '/' },
      { userAgent: 'PerplexityBot', allow: '/' },
      { userAgent: 'Google-Extended', allow: '/' },
    ],
    sitemap: `${SITE.url}/sitemap.xml`,
  };
}
```

- [ ] **Step 3: Crear `public/llms.txt`**

```
# Virtuoso IA

> Virtuoso IA desarrolla sistemas de inteligencia artificial especializados por industria en México: agentes de WhatsApp que venden y reservan, automatización financiera, gestión de reputación con IA, y sitios web optimizados para buscadores tradicionales y de IA (SEO, GEO, AEO).

Contacto: ia@virtuosopro.digital

## Soluciones por industria

- Restaurantes: sistema de reservas con agente WhatsApp 24/7. Caso real: Al Bat Sport Bar (CDMX), +40% ventas en 30 días.
- Hoteles: agente de reservas conversacional (MACA).
- Colegios: automatización de admisiones con IA. Caso real: Colegio Boston, 38% de mejora en conversión.
- Inmobiliarias: sincronización de inventario, WhatsApp y CRM especializado (SofIA).

## Herramientas

- Diagnóstico gratuito: https://virtuosopro.digital/diagnostico — análisis de 60 segundos que recomienda la solución adecuada.
- Sesión de Crecimiento: https://virtuosopro.digital/sesion-crecimiento — auditoría estratégica de captura de leads, atención y CRM.

## Datos verificables

- Caso Al Bat Sport Bar: +40% ventas en 30 días, 127 reservas/mes, 94% ocupación, respuesta <2 min.
- Caso Colegio Boston: 100% automatizado, <2 min de consulta a cita agendada, hasta 38% de mejora en conversión.
```

- [ ] **Step 4: Commit**

```bash
git add projects/Virtuoso_Agency/virtuoso-web/src/app/sitemap.ts projects/Virtuoso_Agency/virtuoso-web/src/app/robots.ts projects/Virtuoso_Agency/virtuoso-web/public/llms.txt
git commit -m "feat(virtuoso-web): sitemap, robots (AI crawlers) y llms.txt"
```

---

### Task 6: Componentes de Home

**Files:**
- Create: `projects/Virtuoso_Agency/virtuoso-web/src/components/Hero.tsx`
- Create: `projects/Virtuoso_Agency/virtuoso-web/src/components/NicheSelectorGrid.tsx`
- Create: `projects/Virtuoso_Agency/virtuoso-web/src/components/MetricTicker.tsx`
- Create: `projects/Virtuoso_Agency/virtuoso-web/src/components/CTASection.tsx`

- [ ] **Step 1: Crear `Hero.tsx`**

```tsx
export default function Hero() {
  return (
    <section className="container" style={{ padding: '96px 24px 64px', textAlign: 'center' }}>
      <h1 style={{ fontSize: 'clamp(32px, 5vw, 56px)', letterSpacing: '-1.5px', lineHeight: 1.1, marginBottom: 20 }}>
        El problema no es falta de datos.
        <br />
        <span style={{ color: 'var(--primary)' }}>Es falta de un sistema que los use.</span>
      </h1>
      <p style={{ fontSize: 18, color: 'var(--gray)', maxWidth: '60ch', margin: '0 auto' }}>
        Sistemas de inteligencia artificial especializados por industria: agentes de WhatsApp,
        automatización financiera, reputación y sitios web que te encuentran en Google y te
        recomiendan ChatGPT, Gemini y Perplexity.
      </p>
    </section>
  );
}
```

- [ ] **Step 2: Crear `NicheSelectorGrid.tsx`**

```tsx
import Link from 'next/link';
import { NICHES } from '@/lib/site-config';

export default function NicheSelectorGrid() {
  return (
    <section className="container" style={{ padding: '48px 24px' }}>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: 20 }}>
        {NICHES.map((n) => {
          const card = (
            <div
              style={{
                border: '1px solid var(--border)',
                borderRadius: 16,
                padding: 28,
                height: '100%',
                opacity: n.live ? 1 : 0.6,
              }}
            >
              <h3 style={{ fontSize: 18, marginBottom: 8 }}>{n.label}</h3>
              <p style={{ fontSize: 14, color: 'var(--gray)' }}>{n.description}</p>
              {!n.live && (
                <span style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', textTransform: 'uppercase' }}>
                  Próximamente
                </span>
              )}
            </div>
          );
          return n.live ? (
            <Link key={n.slug} href={`/${n.slug}`}>
              {card}
            </Link>
          ) : (
            <div key={n.slug}>{card}</div>
          );
        })}
      </div>
    </section>
  );
}
```

- [ ] **Step 3: Crear `MetricTicker.tsx`**

```tsx
import { METRICS } from '@/lib/site-config';

export default function MetricTicker() {
  return (
    <section style={{ background: 'var(--primary)', padding: '40px 0' }}>
      <div
        className="container"
        style={{ display: 'flex', flexWrap: 'wrap', justifyContent: 'center', gap: 40 }}
      >
        {METRICS.map((m) => (
          <div key={m.label} style={{ textAlign: 'center', color: 'var(--white)' }}>
            <div style={{ fontSize: 32, fontWeight: 900, color: 'var(--yellow)' }}>{m.value}</div>
            <div style={{ fontSize: 12, opacity: 0.8, maxWidth: 160 }}>{m.label}</div>
          </div>
        ))}
      </div>
    </section>
  );
}
```

- [ ] **Step 4: Crear `CTASection.tsx`**

```tsx
export default function CTASection() {
  return (
    <section className="container" style={{ padding: '64px 24px', textAlign: 'center' }}>
      <h2 style={{ fontSize: 28, marginBottom: 16 }}>¿Por dónde empezamos?</h2>
      <p style={{ color: 'var(--gray)', marginBottom: 28 }}>
        Diagnóstico gratuito de 60 segundos, o una Sesión de Crecimiento de 30 minutos con tu equipo.
      </p>
      <div style={{ display: 'flex', gap: 16, justifyContent: 'center', flexWrap: 'wrap' }}>
        <a
          href="/diagnostico"
          style={{
            background: 'var(--yellow)',
            color: 'var(--primary-dark)',
            fontWeight: 700,
            padding: '14px 28px',
            borderRadius: 999,
          }}
        >
          Diagnóstico gratuito
        </a>
        <a
          href="/sesion-crecimiento"
          style={{
            border: '2px solid var(--primary)',
            color: 'var(--primary)',
            fontWeight: 700,
            padding: '12px 26px',
            borderRadius: 999,
          }}
        >
          Sesión de Crecimiento
        </a>
      </div>
    </section>
  );
}
```

- [ ] **Step 5: Commit**

```bash
git add projects/Virtuoso_Agency/virtuoso-web/src/components/Hero.tsx projects/Virtuoso_Agency/virtuoso-web/src/components/NicheSelectorGrid.tsx projects/Virtuoso_Agency/virtuoso-web/src/components/MetricTicker.tsx projects/Virtuoso_Agency/virtuoso-web/src/components/CTASection.tsx
git commit -m "feat(virtuoso-web): componentes de Home (Hero, NicheSelectorGrid, MetricTicker, CTASection)"
```

---

### Task 7: Nav y Footer

**Files:**
- Create: `projects/Virtuoso_Agency/virtuoso-web/src/components/Nav.tsx`
- Create: `projects/Virtuoso_Agency/virtuoso-web/src/components/Footer.tsx`

- [ ] **Step 1: Crear `Nav.tsx`**

```tsx
import Link from 'next/link';
import { NAV_LINKS } from '@/lib/site-config';

export default function Nav() {
  return (
    <header
      style={{
        position: 'sticky',
        top: 0,
        zIndex: 50,
        background: 'rgba(255,255,255,0.95)',
        backdropFilter: 'blur(10px)',
        borderBottom: '1px solid var(--border)',
      }}
    >
      <div
        className="container"
        style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '14px 24px' }}
      >
        <Link href="/" style={{ fontWeight: 900, fontSize: 18, color: 'var(--primary)' }}>
          VIRTUOSO <span style={{ color: 'var(--cyan)' }}>IA</span>
        </Link>
        <nav style={{ display: 'flex', gap: 20 }}>
          {NAV_LINKS.map((link) => (
            <Link key={link.href} href={link.href} style={{ fontSize: 14, fontWeight: 600 }}>
              {link.label}
            </Link>
          ))}
        </nav>
      </div>
    </header>
  );
}
```

- [ ] **Step 2: Crear `Footer.tsx`**

```tsx
export default function Footer() {
  return (
    <footer style={{ background: 'var(--primary-dark)', color: 'var(--white)', padding: '48px 24px', marginTop: 64 }}>
      <div className="container" style={{ display: 'flex', justifyContent: 'space-between', flexWrap: 'wrap', gap: 24 }}>
        <div>
          <strong>Virtuoso IA</strong>
          <p style={{ fontSize: 13, opacity: 0.7, marginTop: 8 }}>
            Sistemas de inteligencia artificial especializados por industria.
          </p>
        </div>
        <div style={{ fontSize: 13, opacity: 0.7 }}>
          © {new Date().getFullYear()} Virtuoso IA · Todos los derechos reservados
        </div>
      </div>
    </footer>
  );
}
```

- [ ] **Step 3: Commit**

```bash
git add projects/Virtuoso_Agency/virtuoso-web/src/components/Nav.tsx projects/Virtuoso_Agency/virtuoso-web/src/components/Footer.tsx
git commit -m "feat(virtuoso-web): Nav y Footer"
```

---

### Task 8: Layout raíz

**Files:**
- Create: `projects/Virtuoso_Agency/virtuoso-web/src/app/layout.tsx`

- [ ] **Step 1: Crear `layout.tsx`**

```tsx
import type { Metadata } from 'next';
import { Poppins, Raleway } from 'next/font/google';
import Nav from '@/components/Nav';
import Footer from '@/components/Footer';
import { SITE, orgJsonLd, JsonLd } from '@/lib/seo';
import './globals.css';

const display = Poppins({
  subsets: ['latin'],
  weight: ['700', '800'],
  variable: '--font-display',
  display: 'swap',
});

const body = Raleway({
  subsets: ['latin'],
  weight: ['400', '600', '700'],
  variable: '--font-body',
  display: 'swap',
});

export const metadata: Metadata = {
  metadataBase: new URL(SITE.url),
  title: {
    default: 'Virtuoso IA · Sistemas de IA especializados por industria',
    template: '%s | Virtuoso IA',
  },
  description: SITE.description,
  alternates: { canonical: '/' },
  openGraph: {
    type: 'website',
    locale: 'es_MX',
    siteName: SITE.name,
    title: 'Virtuoso IA · Sistemas de IA especializados por industria',
    description: SITE.description,
    images: [{ url: SITE.ogImage, width: 1200, height: 630, alt: SITE.name }],
  },
  robots: { index: true, follow: true },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es" className={`${display.variable} ${body.variable}`}>
      <body>
        <JsonLd data={orgJsonLd()} />
        <Nav />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  );
}
```

- [ ] **Step 2: Commit**

```bash
git add projects/Virtuoso_Agency/virtuoso-web/src/app/layout.tsx
git commit -m "feat(virtuoso-web): layout raíz con fuentes de marca y Organization JSON-LD"
```

---

### Task 9: Página Home

**Files:**
- Create: `projects/Virtuoso_Agency/virtuoso-web/src/app/page.tsx`

- [ ] **Step 1: Crear `page.tsx`**

```tsx
import Hero from '@/components/Hero';
import NicheSelectorGrid from '@/components/NicheSelectorGrid';
import MetricTicker from '@/components/MetricTicker';
import CTASection from '@/components/CTASection';

export default function HomePage() {
  return (
    <>
      <Hero />
      <NicheSelectorGrid />
      <MetricTicker />
      <CTASection />
    </>
  );
}
```

- [ ] **Step 2: Verificar el build**

Run: `cd projects/Virtuoso_Agency/virtuoso-web && npm run build`
Expected: `Compiled successfully`, sin errores de tipos ni de lint.

- [ ] **Step 3: Verificar visualmente en dev**

Run: `npm run dev`
Abrir `http://localhost:3000` en el navegador (usar el tool de Browser). Confirmar:
- Hero se ve con la tipografía Poppins/Raleway cargando
- Las 4 tarjetas de nicho aparecen con "Próximamente" (ninguna es clicable todavía)
- El ticker de métricas con fondo azul y números en amarillo
- CTA final con los dos botones

- [ ] **Step 4: Commit**

```bash
git add projects/Virtuoso_Agency/virtuoso-web/src/app/page.tsx
git commit -m "feat(virtuoso-web): página Home"
```

---

### Task 10: Deploy a Vercel

**Files:** ninguno nuevo — despliegue del proyecto ya construido.

- [ ] **Step 1: Vincular el proyecto a Vercel**

Run: `cd projects/Virtuoso_Agency/virtuoso-web && vercel link --yes`
Expected: crea `.vercel/project.json` con un nuevo proyecto `virtuoso-web`.

- [ ] **Step 2: Deploy a producción**

Run: `vercel --prod --yes`
Expected: build exitoso, devuelve una URL `*.vercel.app`.

- [ ] **Step 3: Verificar en el navegador**

Abrir la URL de producción con el tool de Browser y confirmar que se ve igual que en `localhost:3000`.

- [ ] **Step 4: Reportar al usuario**

Antes de conectar el dominio `virtuosopro.digital` (hoy apuntando a GHL) a este proyecto, **detente y confirma con Héctor** — es un cambio de DNS que afecta el sitio en vivo. No cambiar el dominio sin luz verde explícita.

---

## Siguientes fases (fuera de este plan)

- **Fase 2:** páginas de nicho con caso real — `/restaurantes` (migrar `landing-restaurantes-preview/index.html`), `/colegios` (caso Miss Carmen). Incluye construir `Hero` variante con antes/después, `CaseStudyCard`, `HowItWorksSteps`.
- **Fase 3:** páginas de capacidad — `/soluciones`, `/soluciones/reputacion-ia`, `/soluciones/sitios-web-seo-geo-aeo`.
- **Fase 4:** nichos restantes con versión corta — `/hoteles`, `/inmobiliarias`, `/soluciones/automatizacion-financiera`, `/soluciones/menus-digitales`, tarjetas puente a `sistemat.app` e `innovarse.com.mx`.
- **Fase 5:** `/casos-de-exito` (hub + individuales), `/diagnostico` (reempacar el widget existente como componente), `/sesion-crecimiento`, `/contacto`, `/aviso-de-privacidad`.
- **Migración de dominio:** redirects 301 desde los subdominios GHL una vez el sitio nuevo cubra las rutas equivalentes — requiere aprobación explícita antes de tocar DNS.
