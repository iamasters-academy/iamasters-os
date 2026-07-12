import type { Metadata } from 'next';
import NicheHero from '@/components/NicheHero';
import HowItWorksSteps from '@/components/HowItWorksSteps';
import CTASection from '@/components/CTASection';
import { serviceJsonLd, JsonLd } from '@/lib/seo';

export const metadata: Metadata = {
  title: 'Automatización Financiera y Cierre de Caja con IA',
  description:
    'Captura el cierre diario con una foto del ticket por WhatsApp. La IA extrae los datos, los organiza y actualiza el dashboard — sin hojas de cálculo.',
  alternates: { canonical: '/soluciones/automatizacion-financiera' },
};

const HOW_IT_WORKS = [
  {
    title: 'Foto del ticket por WhatsApp',
    description: 'Al cerrar el día, se toma una foto del corte de caja y se envía por WhatsApp — sin apps nuevas que aprender.',
  },
  {
    title: 'La IA extrae los datos automáticamente',
    description: 'Visión por computadora lee ventas, propinas y método de pago directo de la foto.',
  },
  {
    title: 'Se organiza en una base de datos centralizada',
    description: 'Cada cierre queda registrado y ordenado, listo para consultarse en cualquier momento.',
  },
  {
    title: 'El dashboard ejecutivo se actualiza solo',
    description: 'Ventas, tendencias y alertas quedan disponibles sin que nadie tenga que armar un reporte.',
  },
];

export default function AutomatizacionFinancieraPage() {
  return (
    <>
      <JsonLd
        data={serviceJsonLd({
          name: 'Automatización Financiera y Cierre de Caja con IA',
          description: 'Captura y organización automática del cierre diario mediante fotos de tickets por WhatsApp.',
          slug: 'soluciones/automatizacion-financiera',
          audience: ['Restaurantes', 'Bares', 'Negocios con cierre de caja diario'],
        })}
      />
      <NicheHero
        badge="Solución transversal · aplica a cualquier nicho"
        title="Automatiza el cierre de caja"
        highlight="sin depender de que alguien se acuerde"
        subtitle="El cierre diario se captura con una foto del ticket por WhatsApp. La IA extrae los datos, los organiza y actualiza el dashboard — sin hojas de cálculo que alguien tiene que llenar a mano cada noche."
        metrics={[]}
        ctaHref="/diagnostico"
        ctaLabel="Agenda diagnóstico gratuito"
      />
      <HowItWorksSteps steps={HOW_IT_WORKS} />
      <CTASection />
    </>
  );
}
