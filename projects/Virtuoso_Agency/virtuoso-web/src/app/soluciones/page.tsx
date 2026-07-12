import type { Metadata } from 'next';
import Link from 'next/link';
import { CAPABILITIES } from '@/lib/site-config';
import CTASection from '@/components/CTASection';

export const metadata: Metadata = {
  title: 'Soluciones',
  description: 'Capacidades de Virtuoso IA: gestión de reputación con IA, sitios web optimizados para SEO, GEO y AEO, y más.',
  alternates: { canonical: '/soluciones' },
};

export default function SolucionesPage() {
  return (
    <>
      <section className="container" style={{ padding: '96px 24px 64px', textAlign: 'center' }}>
        <h1 style={{ fontSize: 'clamp(28px, 4vw, 44px)', letterSpacing: '-1.5px', marginBottom: 20 }}>
          Capacidades que resuelven tu problema, <span style={{ color: 'var(--primary)' }}>no el nombre de un producto</span>
        </h1>
        <p style={{ fontSize: 17, color: 'var(--gray)', maxWidth: '56ch', margin: '0 auto' }}>
          Cada solución de Virtuoso IA está construida para un problema específico, con casos reales detrás.
        </p>
      </section>
      <section className="container" style={{ padding: '0 24px 64px' }}>
        <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(260px, 1fr))', gap: 20 }}>
          {CAPABILITIES.map((c) => {
            const card = (
              <div
                style={{
                  border: '1px solid var(--border)',
                  borderRadius: 16,
                  padding: 28,
                  height: '100%',
                  opacity: c.live ? 1 : 0.6,
                }}
              >
                <h2 style={{ fontSize: 18, marginBottom: 8 }}>{c.label}</h2>
                <p style={{ fontSize: 14, color: 'var(--gray)' }}>{c.description}</p>
                {!c.live && (
                  <span style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', textTransform: 'uppercase' }}>
                    Próximamente
                  </span>
                )}
              </div>
            );
            return c.live ? (
              <Link key={c.slug} href={`/soluciones/${c.slug}`}>
                {card}
              </Link>
            ) : (
              <div key={c.slug}>{card}</div>
            );
          })}
        </div>
      </section>
      <CTASection />
    </>
  );
}
