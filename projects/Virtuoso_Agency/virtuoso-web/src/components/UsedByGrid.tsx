type UsageItem = { name: string; description: string };

export default function UsedByGrid({ items }: { items: UsageItem[] }) {
  return (
    <section className="container" style={{ padding: '64px 24px' }}>
      <h2 style={{ fontSize: 28, marginBottom: 32, textAlign: 'center' }}>Quién ya lo está usando</h2>
      <div style={{ display: 'grid', gridTemplateColumns: 'repeat(auto-fit, minmax(220px, 1fr))', gap: 20 }}>
        {items.map((item) => (
          <div
            key={item.name}
            style={{
              border: '1px solid var(--border)',
              borderRadius: 16,
              padding: 24,
            }}
          >
            <div style={{ fontWeight: 700, marginBottom: 8 }}>{item.name}</div>
            <div style={{ fontSize: 13, color: 'var(--gray)' }}>{item.description}</div>
          </div>
        ))}
      </div>
    </section>
  );
}
