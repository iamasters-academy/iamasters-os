import Link from 'next/link';
import { NICHES } from '@/lib/site-config';

export default function NicheSelectorGrid() {
  return (
    <section className="container" style={{ padding: '48px 24px' }}>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(240px, 1fr))', gap: 20 }}>
        {NICHES.map((n) => {
          const card = (
            <div
              style={{
                border: '1px solid var(--border)',
                borderRadius: 16,
                padding: 28,
                height: '100%',
                opacity: n.live ? 1 : 0.6,
              }}
            >
              <h3 style={{ fontSize: 18, marginBottom: 8 }}>{n.label}</h3>
              <p style={{ fontSize: 14, color: 'var(--gray)' }}>{n.description}</p>
              {!n.live && (
                <span style={{ fontSize: 11, fontWeight: 700, color: 'var(--gray)', textTransform: 'uppercase' }}>
                  Próximamente
                </span>
              )}
            </div>
          );
          return n.live ? (
            <Link key={n.slug} href={`/${n.slug}`}>
              {card}
            </Link>
          ) : (
            <div key={n.slug}>{card}</div>
          );
        })}
      </div>
    </section>
  );
}
