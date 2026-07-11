export default function Hero() {
  return (
    <section className="container" style={{ padding: '96px 24px 64px', textAlign: 'center' }}>
      <h1 style={{ fontSize: 'clamp(32px, 5vw, 56px)', letterSpacing: '-1.5px', lineHeight: 1.1, marginBottom: 20 }}>
        El problema no es falta de datos.
        <br />
        <span style={{ color: 'var(--primary)' }}>Es falta de un sistema que los use.</span>
      </h1>
      <p style={{ fontSize: 18, color: 'var(--gray)', maxWidth: '60ch', margin: '0 auto' }}>
        Sistemas de inteligencia artificial especializados por industria: agentes de WhatsApp,
        automatización financiera, reputación y sitios web que te encuentran en Google y te
        recomiendan ChatGPT, Gemini y Perplexity.
      </p>
    </section>
  );
}
