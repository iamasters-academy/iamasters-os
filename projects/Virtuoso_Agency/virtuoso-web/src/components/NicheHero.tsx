type Metric = { value: string; label: string };

type NicheHeroProps = {
  badge: string;
  title: string;
  highlight: string;
  subtitle: string;
  metrics: Metric[];
  ctaHref: string;
  ctaLabel: string;
};

export default function NicheHero({ badge, title, highlight, subtitle, metrics, ctaHref, ctaLabel }: NicheHeroProps) {
  return (
    <section className="container" style={{ padding: '96px 24px 64px', textAlign: 'center' }}>
      <div
        style={{
          display: 'inline-flex',
          alignItems: 'center',
          gap: 8,
          border: '1px solid var(--border)',
          borderRadius: 999,
          padding: '6px 16px',
          marginBottom: 24,
          fontSize: 12,
          fontWeight: 700,
          color: 'var(--primary)',
        }}
      >
        {badge}
      </div>
      <h1 style={{ fontSize: 'clamp(28px, 4vw, 48px)', letterSpacing: '-1.5px', lineHeight: 1.15, marginBottom: 20 }}>
        {title} <span style={{ color: 'var(--primary)' }}>{highlight}</span>
      </h1>
      <p style={{ fontSize: 17, color: 'var(--gray)', maxWidth: '56ch', margin: '0 auto 28px' }}>{subtitle}</p>
      <div style={{ display: 'flex', flexWrap: 'wrap', justifyContent: 'center', gap: 12, marginBottom: 32 }}>
        {metrics.map((m) => (
          <div
            key={m.label}
            style={{
              display: 'flex',
              alignItems: 'center',
              gap: 6,
              background: 'var(--gray-light)',
              border: '1px solid var(--border)',
              borderRadius: 999,
              padding: '8px 16px',
              fontSize: 12,
            }}
          >
            <strong>{m.value}</strong>
            <span style={{ color: 'var(--gray)' }}>{m.label}</span>
          </div>
        ))}
      </div>
      <a
        href={ctaHref}
        style={{
          display: 'inline-block',
          background: 'var(--yellow)',
          color: 'var(--primary-dark)',
          fontWeight: 700,
          padding: '16px 32px',
          borderRadius: 999,
        }}
      >
        {ctaLabel}
      </a>
    </section>
  );
}
