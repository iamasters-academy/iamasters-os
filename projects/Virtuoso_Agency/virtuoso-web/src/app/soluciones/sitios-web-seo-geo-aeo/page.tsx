import type { Metadata } from 'next';
import NicheHero from '@/components/NicheHero';
import UsedByGrid from '@/components/UsedByGrid';
import HowItWorksSteps from '@/components/HowItWorksSteps';
import CTASection from '@/components/CTASection';
import { serviceJsonLd, JsonLd } from '@/lib/seo';

export const metadata: Metadata = {
  title: 'Sitios Web con SEO, GEO y AEO',
  description:
    'Desarrollo de sitios web optimizados con SEO, GEO y AEO: te encuentran en Google y te recomiendan ChatGPT, Gemini y Perplexity.',
  alternates: { canonical: '/soluciones/sitios-web-seo-geo-aeo' },
};

const DELIVERY_STEPS = [
  {
    title: 'Auditoría GEO/AEO inicial',
    description: 'Medimos tu visibilidad actual en buscadores tradicionales y de IA — mismo formato que el caso OPC Latam (68/100 en visibilidad IA).',
  },
  {
    title: 'Arquitectura técnica desde cero',
    description: 'Sitemap, llms.txt, schema markup y metadatos pensados para que los motores de IA citen tu contenido, no solo Google.',
  },
  {
    title: 'Construcción o migración del sitio',
    description: 'Next.js con el mismo stack que ya usamos en producción — rápido, sin dependencias de un CMS externo.',
  },
  {
    title: 'Mantenimiento y contenido mensual',
    description: 'Extensión opcional: seguimos publicando contenido optimizado para mantener y crecer tu visibilidad.',
  },
];

export default function SitiosWebPage() {
  return (
    <>
      <JsonLd
        data={serviceJsonLd({
          name: 'Sitios Web con SEO, GEO y AEO',
          description: 'Desarrollo de sitios web optimizados para buscadores tradicionales y motores de búsqueda de IA.',
          slug: 'soluciones/sitios-web-seo-geo-aeo',
          audience: ['Cualquier negocio que necesite presencia web profesional'],
        })}
      />
      <NicheHero
        badge="Solución transversal · aplica a cualquier nicho"
        title="Sitios web que te encuentran en Google"
        highlight="y te recomiendan ChatGPT, Gemini y Perplexity"
        subtitle="Casi nadie en el mercado local ofrece optimización para buscadores de IA todavía. Nosotros ya lo entregamos — y lo auditamos con datos reales."
        metrics={[]}
        ctaHref="/diagnostico"
        ctaLabel="Agenda diagnóstico gratuito"
      />
      <UsedByGrid
        items={[
          { name: 'Centro de Calidad Turística', description: 'ccturistica.com — migración completa con suite SEO/GEO/AEO, sitemap, llms.txt y schema markup.' },
          { name: 'Tayira Travel', description: 'Sitio web desplegado con arquitectura optimizada para buscadores.' },
          { name: 'JAÜS Coffee', description: 'Landing con Google Search Console y Google My Business optimizados.' },
        ]}
      />
      <HowItWorksSteps steps={DELIVERY_STEPS} />
      <CTASection />
    </>
  );
}
