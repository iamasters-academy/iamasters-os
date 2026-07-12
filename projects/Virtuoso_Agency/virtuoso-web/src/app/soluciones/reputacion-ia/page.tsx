import type { Metadata } from 'next';
import NicheHero from '@/components/NicheHero';
import UsedByGrid from '@/components/UsedByGrid';
import HowItWorksSteps from '@/components/HowItWorksSteps';
import CTASection from '@/components/CTASection';
import { serviceJsonLd, JsonLd } from '@/lib/seo';

export const metadata: Metadata = {
  title: 'Gestión de Reputación con IA',
  description:
    'Responde fácilmente a reseñas y aumenta tu credibilidad online. IA que redacta respuestas personalizadas y solicita reseñas automáticamente después de cada venta.',
  alternates: { canonical: '/soluciones/reputacion-ia' },
};

const DELIVERY_STEPS = [
  {
    title: 'Conectamos tu perfil de reseñas',
    description: 'Integramos Google, Facebook o el módulo de Reputación de tu CRM — sin cambiar cómo ya operas.',
  },
  {
    title: 'La IA redacta una respuesta personalizada',
    description: 'Cada reseña nueva recibe una respuesta con el tono de tu marca, en minutos, no en días.',
  },
  {
    title: 'Tú apruebas o se publica automáticamente',
    description: 'Eliges el nivel de control: revisar cada respuesta antes de publicar, o dejar que el sistema opere solo.',
  },
  {
    title: 'Solicitud automática de nuevas reseñas',
    description: 'Después de cada venta o estancia, el sistema pide una reseña en el momento correcto — sin que nadie tenga que acordarse.',
  },
];

export default function ReputacionIaPage() {
  return (
    <>
      <JsonLd
        data={serviceJsonLd({
          name: 'Gestión de Reputación con IA',
          description: 'IA que responde reseñas y solicita nuevas automáticamente para aumentar la credibilidad online del negocio.',
          slug: 'soluciones/reputacion-ia',
          audience: ['Restaurantes', 'Hoteles', 'Colegios', 'Cualquier negocio con reseñas online'],
        })}
      />
      <NicheHero
        badge="Solución transversal · aplica a cualquier nicho"
        title="Responde fácilmente a reseñas"
        highlight="y aumenta tu credibilidad online"
        subtitle="Cada reseña sin responder es una oportunidad perdida de mostrar que tu negocio escucha. La IA redacta la respuesta, tú decides si la revisas o la dejas fluir."
        metrics={[]}
        ctaHref="/diagnostico"
        ctaLabel="Agenda diagnóstico gratuito"
      />
      <UsedByGrid
        items={[
          {
            name: 'JAÜS Coffee',
            description: 'Primer caso piloto: IA de respuesta a reseñas de Google en configuración, integrada a su paquete de presencia digital.',
          },
        ]}
      />
      <HowItWorksSteps steps={DELIVERY_STEPS} />
      <CTASection />
    </>
  );
}
