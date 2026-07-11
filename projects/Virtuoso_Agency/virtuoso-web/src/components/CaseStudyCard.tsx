type Metric = { value: string; label: string };

type CaseStudyCardProps = {
  badge: string;
  title: string;
  description: string;
  metrics: Metric[];
  systemItems: string[];
};

export default function CaseStudyCard({ badge, title, description, metrics, systemItems }: CaseStudyCardProps) {
  return (
    <section className="container" style={{ padding: '64px 24px' }}>
      <div
        style={{
          display: 'inline-flex',
          alignItems: 'center',
          gap: 6,
          border: '1px solid var(--yellow)',
          background: 'rgba(222,232,0,0.12)',
          borderRadius: 999,
          padding: '5px 14px',
          marginBottom: 20,
          fontSize: 11,
          fontWeight: 700,
        }}
      >
        {badge}
      </div>
      <h2 style={{ fontSize: 32, marginBottom: 16 }}>{title}</h2>
      <p style={{ fontSize: 15, color: 'var(--gray)', marginBottom: 28, maxWidth: '65ch' }}>{description}</p>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(140px, 1fr))', gap: 10, marginBottom: 24, maxWidth: 560 }}>
        {metrics.map((m, i) => (
          <div
            key={m.label}
            style={{
              background: i % 2 === 0 ? 'var(--primary-dark)' : 'var(--primary)',
              borderRadius: 16,
              padding: 18,
              textAlign: 'center',
            }}
          >
            <div style={{ fontSize: 28, fontWeight: 900, color: 'var(--yellow)' }}>{m.value}</div>
            <div style={{ fontSize: 11, color: 'var(--white)', opacity: 0.85 }}>{m.label}</div>
          </div>
        ))}
      </div>
      <div style={{ background: 'var(--gray-light)', borderRadius: 16, padding: 20, maxWidth: 560 }}>
        <div style={{ fontSize: 13, fontWeight: 700, marginBottom: 14 }}>Sistema implementado:</div>
        <ul style={{ listStyle: 'none', display: 'flex', flexDirection: 'column', gap: 8 }}>
          {systemItems.map((item) => (
            <li key={item} style={{ display: 'flex', alignItems: 'flex-start', gap: 8 }}>
              <span
                style={{
                  width: 16,
                  height: 16,
                  borderRadius: '50%',
                  background: 'var(--yellow)',
                  flexShrink: 0,
                  marginTop: 2,
                }}
              />
              <span style={{ fontSize: 12, color: 'var(--gray)' }}>{item}</span>
            </li>
          ))}
        </ul>
      </div>
    </section>
  );
}
