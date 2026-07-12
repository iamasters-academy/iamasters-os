import type { Metadata } from 'next';
import NicheHero from '@/components/NicheHero';
import HowItWorksSteps from '@/components/HowItWorksSteps';
import CTASection from '@/components/CTASection';
import { serviceJsonLd, JsonLd } from '@/lib/seo';

export const metadata: Metadata = {
  title: 'Automatización Inmobiliaria Premium con IA',
  description:
    'SofIA sincroniza tu inventario cada noche, detecta altas, bajas y cambios de precio, y responde a cada prospecto por WhatsApp con una oferta personalizada.',
  alternates: { canonical: '/inmobiliarias' },
};

const HOW_IT_WORKS = [
  {
    title: 'Sincronización nocturna del inventario',
    description: 'Cada noche el sistema detecta propiedades nuevas, eliminadas y cambios de precio, sin intervención manual.',
  },
  {
    title: 'WhatsApp responde con oferta personalizada',
    description: 'Cada prospecto recibe una respuesta ajustada a lo que busca y a lo que cambió en el inventario esa noche.',
  },
  {
    title: 'El interés queda registrado automáticamente',
    description: 'Cada propiedad que menciona un prospecto se vincula a su perfil, sin captura manual del asesor.',
  },
  {
    title: 'Todo centralizado en un CRM especializado',
    description: 'Ficha técnica con fotografía, precio vigente y la lista de interesados por cada inmueble, en un solo lugar.',
  },
];

export default function InmobiliariasPage() {
  return (
    <>
      <JsonLd
        data={serviceJsonLd({
          name: 'Automatización Inmobiliaria Premium con IA',
          description: 'Sincronización de inventario, atención por WhatsApp y CRM especializado para inmobiliarias.',
          slug: 'inmobiliarias',
          audience: ['Inmobiliarias, brokers independientes y equipos de ventas'],
        })}
      />
      <NicheHero
        badge="SofIA · Automatización inmobiliaria premium"
        title="Sincroniza tu inventario"
        highlight="y convierte cada mensaje en una oportunidad"
        subtitle="El inventario cambia todos los días — propiedades nuevas, bajas, precios actualizados — sin que esa novedad llegue a tiempo a las conversaciones de WhatsApp. SofIA sincroniza cada noche y responde con una oferta ajustada a lo que cada prospecto busca."
        metrics={[]}
        ctaHref="/diagnostico"
        ctaLabel="Agenda diagnóstico gratuito"
      />
      <HowItWorksSteps steps={HOW_IT_WORKS} />
      <CTASection />
    </>
  );
}
