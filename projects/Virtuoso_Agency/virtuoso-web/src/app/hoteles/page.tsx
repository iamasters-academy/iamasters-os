import type { Metadata } from 'next';
import NicheHero from '@/components/NicheHero';
import HowItWorksSteps from '@/components/HowItWorksSteps';
import CTASection from '@/components/CTASection';
import { serviceJsonLd, JsonLd } from '@/lib/seo';

export const metadata: Metadata = {
  title: 'Agente de Reservas para Hoteles con IA',
  description:
    'MACA responde consultas de disponibilidad y tarifas por WhatsApp 24/7, consulta tu calendario en tiempo real y confirma reservas sin intervención manual.',
  alternates: { canonical: '/hoteles' },
};

const HOW_IT_WORKS = [
  {
    title: 'Huésped escribe por WhatsApp',
    description: 'Pregunta disponibilidad, tarifas o hace una reserva directa, en cualquier momento del día.',
  },
  {
    title: 'MACA responde y consulta disponibilidad',
    description: 'El agente entiende fechas, tipo de habitación y número de huéspedes, y consulta el calendario en tiempo real.',
  },
  {
    title: 'Confirma la reserva sin intervención manual',
    description: 'Si hay disponibilidad, la reserva queda confirmada y registrada — sin que el equipo de recepción tenga que intervenir.',
  },
  {
    title: 'Escala a un humano cuando hace falta',
    description: 'Casos especiales o negociaciones se transfieren al equipo con todo el contexto de la conversación.',
  },
];

export default function HotelesPage() {
  return (
    <>
      <JsonLd
        data={serviceJsonLd({
          name: 'Agente de Reservas para Hoteles con IA',
          description: 'Agente conversacional que atiende consultas y reservas hoteleras por WhatsApp 24/7.',
          slug: 'hoteles',
          audience: ['Hoteles independientes y grupos hoteleros pequeños'],
        })}
      />
      <NicheHero
        badge="MACA · Agente de reservas para hoteles"
        title="Atiende reservas de hotel"
        highlight="sin perder ni un mensaje"
        subtitle="Las consultas de disponibilidad y tarifas llegan a cualquier hora. MACA responde de inmediato, consulta tu calendario y confirma la reserva — para que tu equipo de recepción se enfoque en el huésped que ya está en el lobby."
        metrics={[]}
        ctaHref="/diagnostico"
        ctaLabel="Agenda diagnóstico gratuito"
      />
      <HowItWorksSteps steps={HOW_IT_WORKS} />
      <CTASection />
    </>
  );
}
