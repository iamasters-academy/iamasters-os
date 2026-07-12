import type { Metadata } from 'next';
import NicheHero from '@/components/NicheHero';
import HowItWorksSteps from '@/components/HowItWorksSteps';
import CTASection from '@/components/CTASection';
import { serviceJsonLd, JsonLd } from '@/lib/seo';

export const metadata: Metadata = {
  title: 'Menú Digital con IA — Se Actualiza Solo',
  description:
    'Menú digital que se actualiza en tiempo real desde un panel simple: precios, disponibilidad y fotos sin depender de reimprimir el menú.',
  alternates: { canonical: '/soluciones/menus-digitales' },
};

const HOW_IT_WORKS = [
  {
    title: 'El equipo edita desde un panel simple',
    description: 'Precios, disponibilidad y fotos se actualizan sin depender de un diseñador o de reimprimir el menú.',
  },
  {
    title: 'El cambio se refleja al instante',
    description: 'El menú público (por QR o link) muestra la versión actualizada en tiempo real, sin caché ni demoras.',
  },
  {
    title: 'El cliente ve exactamente lo que hay disponible',
    description: 'Cero platillos agotados mostrados como disponibles, cero precios desactualizados.',
  },
  {
    title: 'Datos de qué se pide más, listos para decidir',
    description: 'El sistema deja ver qué platillos se consultan más, información que hoy se pierde en un menú de papel.',
  },
];

export default function MenusDigitalesPage() {
  return (
    <>
      <JsonLd
        data={serviceJsonLd({
          name: 'Menú Digital con IA',
          description: 'Menú digital con edición en tiempo real de precios, disponibilidad y fotos.',
          slug: 'soluciones/menus-digitales',
          audience: ['Restaurantes', 'Bares', 'Cafeterías'],
        })}
      />
      <NicheHero
        badge="Solución transversal · aplica a cualquier nicho"
        title="Un menú digital que se actualiza solo"
        highlight="y también vende"
        subtitle="Cambiar un precio o marcar un platillo como agotado no debería tomar más de un minuto. El menú público se actualiza en tiempo real desde un panel de administración simple, sin depender de imprimir de nuevo."
        metrics={[]}
        ctaHref="/diagnostico"
        ctaLabel="Agenda diagnóstico gratuito"
      />
      <HowItWorksSteps steps={HOW_IT_WORKS} />
      <CTASection />
    </>
  );
}
