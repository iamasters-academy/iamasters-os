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
