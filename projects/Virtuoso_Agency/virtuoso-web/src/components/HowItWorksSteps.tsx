type Step = { title: string; description: string };

export default function HowItWorksSteps({ steps }: { steps: Step[] }) {
  return (
    <section className="container" style={{ padding: '64px 24px' }}>
      <h2 style={{ fontSize: 28, marginBottom: 32, textAlign: 'center' }}>Cómo funciona el sistema</h2>
      <div style={{ display: 'flex', flexDirection: 'column', maxWidth: 640, margin: '0 auto' }}>
        {steps.map((step, i) => (
          <div key={step.title} style={{ display: 'flex', gap: 20, marginBottom: i === steps.length - 1 ? 0 : 28 }}>
            <div
              style={{
                width: 40,
                height: 40,
                borderRadius: '50%',
                background: 'var(--primary)',
                color: 'var(--yellow)',
                display: 'flex',
                alignItems: 'center',
                justifyContent: 'center',
                fontWeight: 900,
                fontSize: 14,
                flexShrink: 0,
              }}
            >
              {String(i + 1).padStart(2, '0')}
            </div>
            <div>
              <div style={{ fontWeight: 700, marginBottom: 4 }}>{step.title}</div>
              <div style={{ fontSize: 13, color: 'var(--gray)' }}>{step.description}</div>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}
