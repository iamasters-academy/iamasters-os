import type { Metadata } from 'next';
import NicheHero from '@/components/NicheHero';
import CaseStudyCard from '@/components/CaseStudyCard';
import HowItWorksSteps from '@/components/HowItWorksSteps';
import CTASection from '@/components/CTASection';
import { serviceJsonLd, JsonLd } from '@/lib/seo';

export const metadata: Metadata = {
  title: 'Sistema de Reservas para Restaurantes con IA',
  description:
    'Agente de WhatsApp que responde en menos de 2 minutos, gestiona mesas y eventos, y convierte reservas perdidas en ventas. Caso real: Al Bat Sport Bar, +40% de ventas en 30 días.',
  alternates: { canonical: '/restaurantes' },
};

const HOW_IT_WORKS = [
  {
    title: 'Cliente reserva por WhatsApp o web',
    description: 'Escribe en lenguaje natural. La IA entiende tipo de servicio, número de personas, fecha y preferencias sin formularios.',
  },
  {
    title: 'IA detecta y categoriza automáticamente',
    description: 'El sistema identifica si es mesa, evento, experiencia o paquete especial. Asigna tipo y disponibilidad al instante.',
  },
  {
    title: 'Se agenda en el calendario en tiempo real',
    description: 'La reserva aparece con código de color según servicio. Cero conflictos, cero doble booking, actualización instantánea.',
  },
  {
    title: 'Confirmación y recordatorio automáticos',
    description: 'El cliente recibe confirmación inmediata vía WhatsApp + recordatorio 24h antes. Cero no-shows, cero intervención manual.',
  },
];

export default function RestaurantesPage() {
  return (
    <>
      <JsonLd
        data={serviceJsonLd({
          name: 'Sistema de Reservas para Restaurantes con IA',
          description: 'Agente de WhatsApp que gestiona reservas de restaurantes 24/7.',
          slug: 'restaurantes',
          audience: ['Dueños y operadores de restaurantes'],
        })}
      />
      <NicheHero
        badge="Caso real · Al Bat Sport Bar · CDMX · Abril 2026"
        title="¿Cuántas reservas pierde"
        highlight="tu restaurante hoy?"
        subtitle="Al Bat pasó de WhatsApp caótico a +40% más ventas con IA que gestiona mesas, eventos y jaulas — automáticamente."
        metrics={[
          { value: '127', label: 'reservas/mes' },
          { value: '94%', label: 'ocupación' },
          { value: '<2 min', label: 'respuesta' },
        ]}
        ctaHref="/diagnostico"
        ctaLabel="Agenda diagnóstico gratuito"
      />
      <CaseStudyCard
        badge="Caso de éxito verificado · Abril 2026"
        title="Al Bat multiplicó ventas con sistema completo"
        description="Sport bar con jaulas de bateo en CDMX. Tenían 3 líneas de negocio gestionadas de forma manual. En 30 días, el sistema automatizó todo."
        metrics={[
          { value: '+40%', label: 'ventas en 30 días' },
          { value: '127', label: 'reservas/mes' },
          { value: '94%', label: 'tasa de ocupación' },
          { value: '0', label: 'llamadas perdidas' },
        ]}
        systemItems={[
          'Agente IA en WhatsApp · Responde 24/7 en lenguaje natural',
          'Google Ads con tracking de conversiones reales de reservas',
          'Calendario centralizado: 4 tipos de reserva + código de colores',
          'Recordatorios automáticos · Sin no-shows, sin staff adicional',
        ]}
      />
      <HowItWorksSteps steps={HOW_IT_WORKS} />
      <CTASection />
    </>
  );
}
