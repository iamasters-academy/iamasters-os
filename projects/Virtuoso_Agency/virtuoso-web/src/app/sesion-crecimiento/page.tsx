import type { Metadata } from 'next';
import HowItWorksSteps from '@/components/HowItWorksSteps';
import { serviceJsonLd, faqJsonLd, JsonLd } from '@/lib/seo';

export const metadata: Metadata = {
  title: 'Sesión de Crecimiento — Auditoría Estratégica Gratuita',
  description: 'En una sesión estratégica revisamos tu captación, atención, CRM, seguimiento y medición para encontrar oportunidades claras de automatización.',
  alternates: { canonical: '/sesion-crecimiento' },
};

const BOOKING_URL = 'https://agencia.virtuosopro.digital/widget/bookings/sesion-estrategica-virtuoso';
const WHATSAPP_URL = 'https://wa.me/525572068124?text=Hola%21%20quiero%20m%C3%A1s%20informaci%C3%B3n';

const HOW_IT_WORKS = [
  { title: 'Mapa del flujo actual', description: 'Vemos cómo entra, se atiende y se pierde un lead en tu operación actual.' },
  { title: 'Oportunidades rápidas', description: 'Detectamos automatizaciones con impacto inmediato, no una lista infinita de ideas.' },
  { title: 'Stack recomendado', description: 'Definimos si conviene GHL, n8n, WhatsApp, VAPI, Sheets o Airtable para tu caso.' },
  { title: 'Siguiente paso claro', description: 'Sales de la sesión con una ruta realista de implementación, con costos y tiempos.' },
];

const FAQS = [
  {
    question: '¿La sesión tiene costo?',
    answer: 'La Growth Session inicial es para entender tu operación y detectar si hay una oportunidad real de mejora.',
  },
];

export default function SesionCrecimientoPage() {
  return (
    <>
      <JsonLd
        data={[
          serviceJsonLd({
            name: 'Sesión de Crecimiento Virtuoso IA',
            description: 'Auditoría estratégica de captación, atención, CRM, seguimiento y medición para detectar oportunidades de automatización.',
            slug: 'sesion-crecimiento',
            audience: ['Dueños y operadores de negocios en México'],
          }),
          faqJsonLd(FAQS),
        ]}
      />

      <section className="container" style={{ padding: '96px 24px 48px', textAlign: 'center' }}>
        <div
          style={{
            display: 'inline-flex', alignItems: 'center', gap: 8, border: '1px solid var(--border)',
            borderRadius: 999, padding: '6px 16px', marginBottom: 24, fontSize: 12, fontWeight: 700, color: 'var(--primary)',
          }}
        >
          Growth Session
        </div>
        <h1 style={{ fontSize: 'clamp(28px, 4vw, 48px)', letterSpacing: '-1.5px', lineHeight: 1.15, marginBottom: 20 }}>
          Detectemos dónde se te están <span style={{ color: 'var(--primary)' }}>escapando ventas</span>
        </h1>
        <p style={{ fontSize: 17, color: 'var(--gray)', maxWidth: '56ch', margin: '0 auto 32px' }}>
          En una sesión estratégica revisamos tu captación, atención, CRM, seguimiento y medición para encontrar oportunidades claras de automatización.
        </p>
        <div style={{ display: 'flex', gap: 16, justifyContent: 'center', flexWrap: 'wrap' }}>
          <a
            href={BOOKING_URL}
            target="_blank"
            rel="noopener"
            style={{ background: 'var(--yellow)', color: 'var(--primary-dark)', fontWeight: 700, padding: '16px 32px', borderRadius: 999 }}
          >
            Agendar Growth Session
          </a>
          <a
            href={WHATSAPP_URL}
            target="_blank"
            rel="noopener"
            style={{ border: '2px solid var(--primary)', color: 'var(--primary)', fontWeight: 700, padding: '14px 30px', borderRadius: 999 }}
          >
            Preguntar por WhatsApp
          </a>
        </div>
      </section>

      <HowItWorksSteps steps={HOW_IT_WORKS} />

      <section className="container" style={{ padding: '48px 24px 96px', maxWidth: 720 }}>
        <h2 style={{ fontSize: 24, marginBottom: 20 }}>Preguntas frecuentes</h2>
        {FAQS.map((f) => (
          <details key={f.question} style={{ padding: '16px 0', borderBottom: '1px solid var(--border)' }}>
            <summary style={{ fontWeight: 700, cursor: 'pointer' }}>{f.question}</summary>
            <p style={{ marginTop: 10, color: 'var(--gray)', fontSize: 14, lineHeight: 1.6 }}>{f.answer}</p>
          </details>
        ))}
      </section>
    </>
  );
}
