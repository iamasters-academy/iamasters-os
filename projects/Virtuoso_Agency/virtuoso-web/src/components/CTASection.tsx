export default function CTASection() {
  return (
    <section className="container" style={{ padding: '64px 24px', textAlign: 'center' }}>
      <h2 style={{ fontSize: 28, marginBottom: 16 }}>¿Por dónde empezamos?</h2>
      <p style={{ color: 'var(--gray)', marginBottom: 28 }}>
        Diagnóstico gratuito de 60 segundos, o una Sesión de Crecimiento de 30 minutos con tu equipo.
      </p>
      <div style={{ display: 'flex', gap: 16, justifyContent: 'center', flexWrap: 'wrap' }}>
        <a
          href="/diagnostico"
          style={{
            background: 'var(--yellow)',
            color: 'var(--primary-dark)',
            fontWeight: 700,
            padding: '14px 28px',
            borderRadius: 999,
          }}
        >
          Diagnóstico gratuito
        </a>
        <a
          href="/sesion-crecimiento"
          style={{
            border: '2px solid var(--primary)',
            color: 'var(--primary)',
            fontWeight: 700,
            padding: '12px 26px',
            borderRadius: 999,
          }}
        >
          Sesión de Crecimiento
        </a>
      </div>
    </section>
  );
}
