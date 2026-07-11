export default function Footer() {
  return (
    <footer style={{ background: 'var(--primary-dark)', color: 'var(--white)', padding: '48px 24px', marginTop: 64 }}>
      <div className="container" style={{ display: 'flex', justifyContent: 'space-between', flexWrap: 'wrap', gap: 24 }}>
        <div>
          <strong>Virtuoso IA</strong>
          <p style={{ fontSize: 13, opacity: 0.7, marginTop: 8 }}>
            Sistemas de inteligencia artificial especializados por industria.
          </p>
        </div>
        <div style={{ fontSize: 13, opacity: 0.7 }}>
          © {new Date().getFullYear()} Virtuoso IA · Todos los derechos reservados
        </div>
      </div>
    </footer>
  );
}
