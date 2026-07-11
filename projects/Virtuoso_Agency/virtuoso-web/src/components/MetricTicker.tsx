import { METRICS } from '@/lib/site-config';

export default function MetricTicker() {
  return (
    <section style={{ background: 'var(--primary)', padding: '40px 0' }}>
      <div
        className="container"
        style={{ display: 'flex', flexWrap: 'wrap', justifyContent: 'center', gap: 40 }}
      >
        {METRICS.map((m) => (
          <div key={m.label} style={{ textAlign: 'center', color: 'var(--white)' }}>
            <div style={{ fontSize: 32, fontWeight: 900, color: 'var(--yellow)' }}>{m.value}</div>
            <div style={{ fontSize: 12, opacity: 0.8, maxWidth: 160 }}>{m.label}</div>
          </div>
        ))}
      </div>
    </section>
  );
}
