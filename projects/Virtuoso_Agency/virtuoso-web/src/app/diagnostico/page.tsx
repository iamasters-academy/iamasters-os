import type { Metadata } from 'next';
import DiagnosticoWidget from '@/components/DiagnosticoWidget';
import { serviceJsonLd, JsonLd } from '@/lib/seo';

export const metadata: Metadata = {
  title: 'Diagnóstico Gratuito de 60 Segundos',
  description: 'Describe el problema de tu negocio y recibe al instante qué solución de Virtuoso IA aplica a tu caso y por qué — sin costo, sin compromiso.',
  alternates: { canonical: '/diagnostico' },
};

export default function DiagnosticoPage() {
  return (
    <>
      <JsonLd
        data={serviceJsonLd({
          name: 'Diagnóstico Gratuito Virtuoso IA',
          description: 'Herramienta gratuita que analiza el problema de negocio descrito por el prospecto y recomienda la solución del portafolio Virtuoso IA que mejor aplica.',
          slug: 'diagnostico',
          audience: ['Dueños y operadores de negocios en México'],
        })}
      />
      <DiagnosticoWidget />
    </>
  );
}
