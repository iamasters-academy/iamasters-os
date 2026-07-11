import type { Metadata } from 'next';
import NicheHero from '@/components/NicheHero';
import CaseStudyCard from '@/components/CaseStudyCard';
import HowItWorksSteps from '@/components/HowItWorksSteps';
import CTASection from '@/components/CTASection';
import { serviceJsonLd, JsonLd } from '@/lib/seo';

export const metadata: Metadata = {
  title: 'Automatización de Admisiones para Colegios con IA',
  description:
    'Agente de WhatsApp que atiende admisiones 24/7, califica prospectos y agenda visitas al campus sin saturar a tu equipo. Caso real: Colegio Boston, hasta 38% de mejora en conversión.',
  alternates: { canonical: '/colegios' },
};

const HOW_IT_WORKS = [
  {
    title: 'Familia escribe por WhatsApp',
    description: 'Pregunta sobre inscripciones, colegiaturas o el proceso de admisión en lenguaje natural, a cualquier hora.',
  },
  {
    title: 'Miss Carmen califica y responde',
    description: 'El agente entrevista al prospecto, resuelve dudas sobre la oferta académica y detecta el nivel de interés real.',
  },
  {
    title: 'Se agenda la visita al campus',
    description: 'Si el prospecto está listo, la cita se agenda directo en el calendario del colegio — sin ida y vuelta manual.',
  },
  {
    title: 'Seguimiento con trazabilidad completa',
    description: 'Todo el historial queda integrado al CRM: el equipo de admisiones ve exactamente en qué etapa está cada familia.',
  },
];

export default function ColegiosPage() {
  return (
    <>
      <JsonLd
        data={serviceJsonLd({
          name: 'Automatización de Admisiones para Colegios con IA',
          description: 'Agente de WhatsApp que atiende y califica admisiones escolares 24/7.',
          slug: 'colegios',
          audience: ['Directores y equipos de admisiones de colegios privados'],
        })}
      />
      <NicheHero
        badge="Caso real · Colegio Boston"
        title="Automatice sus admisiones:"
        highlight="de la primera duda a la visita al campus"
        subtitle="Sin velocidad de respuesta y seguimiento consistente, sus campañas solo generan ruido, no inscripciones. Miss Carmen atiende cada consulta en segundos, sin saturar a su equipo."
        metrics={[
          { value: '100%', label: 'automatizado' },
          { value: '<2 min', label: 'consulta a cita' },
          { value: '24/7', label: 'disponibilidad' },
        ]}
        ctaHref="/diagnostico"
        ctaLabel="Agendar cita de diagnóstico"
      />
      <CaseStudyCard
        badge="Caso de éxito verificado"
        title="Colegio Boston automatizó sus admisiones con Miss Carmen"
        description="El agente de IA atiende la primera duda de cada familia, califica el interés real y agenda la visita al campus — todo por WhatsApp, sin intervención humana."
        metrics={[
          { value: '100%', label: 'automatizado' },
          { value: '<5 seg', label: 'tiempo de respuesta' },
          { value: '0', label: 'intervención humana' },
          { value: '38%', label: 'mejora en conversión' },
        ]}
        systemItems={[
          'Agente Miss Carmen en WhatsApp · Atiende admisiones 24/7',
          'Calificación automática de prospectos en la conversación',
          'Agendado directo de visitas al campus, sin ida y vuelta manual',
          'Trazabilidad comercial completa integrada al CRM',
        ]}
      />
      <HowItWorksSteps steps={HOW_IT_WORKS} />
      <CTASection />
    </>
  );
}
