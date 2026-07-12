import type { Metadata } from 'next';
import ContactForm from '@/components/ContactForm';

export const metadata: Metadata = {
  title: 'Contacto',
  description: 'Escríbenos y te contactamos en menos de 24 horas para hablar de tu negocio.',
  alternates: { canonical: '/contacto' },
};

export default function ContactoPage() {
  return (
    <section className="container" style={{ padding: '96px 24px', display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(320px, 1fr))', gap: 48, alignItems: 'start' }}>
      <div>
        <h1 style={{ fontSize: 'clamp(28px, 4vw, 44px)', letterSpacing: '-1.5px', lineHeight: 1.15, marginBottom: 16 }}>
          Hablemos de tu negocio
        </h1>
        <p style={{ fontSize: 16, color: 'var(--gray)', lineHeight: 1.7, maxWidth: '48ch' }}>
          Cuéntanos qué necesitas y un consultor de Virtuoso IA te contacta en menos de 24 horas. Si prefieres algo inmediato,
          prueba el <a href="/diagnostico" style={{ color: 'var(--primary)', fontWeight: 700 }}>diagnóstico gratuito de 60 segundos</a>.
        </p>
      </div>
      <ContactForm />
    </section>
  );
}
