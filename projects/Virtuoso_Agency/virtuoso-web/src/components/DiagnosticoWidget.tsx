'use client';

import { useEffect, useRef, useState } from 'react';

const WEBHOOK_URL = 'https://virtuoso-api.vercel.app/api/diagnostico';
const CALENDAR_URL = 'https://api.leadconnectorhq.com/widget/booking/5hYa6Cr3fljN8H6R5CXa';

type Resultado = {
  titulo: string;
  problema: string;
  solucion_nombre: string;
  solucion: string;
  por_que: string;
};

type Step = 'input' | 'loading' | 'result';

export default function DiagnosticoWidget() {
  const [step, setStep] = useState<Step>('input');
  const [idea, setIdea] = useState('');
  const [errMsg, setErrMsg] = useState<string | null>(null);
  const [resultado, setResultado] = useState<Resultado | null>(null);
  const [litSteps, setLitSteps] = useState<boolean[]>([false, false, false]);
  const timers = useRef<ReturnType<typeof setTimeout>[]>([]);

  useEffect(() => {
    if (step !== 'loading') return;
    timers.current = [
      setTimeout(() => setLitSteps([true, false, false]), 400),
      setTimeout(() => setLitSteps([true, true, false]), 1400),
      setTimeout(() => setLitSteps([true, true, true]), 2600),
    ];
    return () => timers.current.forEach(clearTimeout);
  }, [step]);

  async function handleAnalizar() {
    const trimmed = idea.trim();
    if (trimmed.length < 20) {
      setErrMsg('Por favor describe tu situación antes de continuar (mínimo 20 caracteres).');
      return;
    }
    setErrMsg(null);
    setLitSteps([false, false, false]);
    setStep('loading');

    try {
      const r = await fetch(WEBHOOK_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ idea: trimmed }),
      });
      if (!r.ok) throw new Error(`HTTP ${r.status}`);
      const data = await r.json();
      const result = Array.isArray(data) ? data[0] : data;

      if (result?.fuera_de_alcance) {
        setStep('input');
        setErrMsg(result.mensaje || 'Este diagnóstico analiza situaciones de negocio. Cuéntanos qué negocio tienes y qué problema quieres resolver.');
        return;
      }
      setResultado({
        titulo: result?.titulo || 'Diagnóstico completado',
        problema: result?.problema || '',
        solucion_nombre: result?.solucion_nombre || '',
        solucion: result?.solucion || '',
        por_que: result?.por_que || '',
      });
      setStep('result');
    } catch (e) {
      console.error('Virtuoso diagnóstico error:', e);
      setStep('input');
      setErrMsg('No pudimos conectar con el sistema en este momento. Escríbenos directamente por WhatsApp o inténtalo en unos minutos.');
    }
  }

  function handleRestart() {
    setIdea('');
    setResultado(null);
    setErrMsg(null);
    setStep('input');
  }

  return (
    <div id="vp-diagnostico">
      <style>{`
        #vp-diagnostico {
          --bg: #0a0c14; --panel: #111527; --panel-2: #161c35; --text: #ffffff;
          --muted: #8892a4; --border: rgba(255,255,255,0.1);
          --yellow: #dee800; --cyan: #5CD4E6; --blue: #1e0a80; --blue-dark: #1a1a2e;
          --cyan-glow: rgba(92,212,230,0.15); --yellow-glow: rgba(222,232,0,0.12);
          font-family: var(--font-body, 'Raleway', sans-serif);
          background: var(--bg); display: flex; flex-direction: column;
          align-items: center; justify-content: center; padding: 40px 20px; box-sizing: border-box;
        }
        #vp-diagnostico * { box-sizing: border-box; }
        .vp-wrap { width: 100%; max-width: 680px; }
        .vp-brand { display: flex; align-items: center; gap: 10px; margin-bottom: 36px; }
        .vp-brand-dot { width: 28px; height: 28px; background: var(--cyan); border-radius: 6px; display: flex; align-items: center; justify-content: center; }
        .vp-brand-dot svg { width: 16px; height: 16px; fill: var(--blue-dark); }
        .vp-brand-name { font-family: var(--font-display, 'Poppins', sans-serif); font-weight: 800; font-size: 16px; color: var(--text); letter-spacing: -0.3px; }
        .vp-brand-name span { color: var(--cyan); }
        .vp-steps { display: flex; align-items: center; gap: 8px; margin-bottom: 32px; }
        .vp-step-pill { font-family: var(--font-body, 'Raleway', sans-serif); font-size: 11px; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase; color: var(--muted); padding: 4px 12px; border: 1px solid var(--border); border-radius: 20px; transition: all .3s; }
        .vp-step-pill.active { color: var(--cyan); border-color: var(--cyan); background: var(--cyan-glow); }
        .vp-step-pill.done { color: var(--yellow); border-color: var(--yellow); background: var(--yellow-glow); }
        .vp-step-sep { width: 20px; height: 1px; background: var(--border); }
        .vp-panel { background: var(--panel); border: 1px solid var(--border); border-radius: 20px; padding: 40px; position: relative; overflow: hidden; }
        .vp-panel::before { content: ''; position: absolute; top: -60px; right: -60px; width: 180px; height: 180px; background: radial-gradient(circle, rgba(92,212,230,0.08) 0%, transparent 70%); pointer-events: none; }
        .vp-label { font-size: 11px; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: var(--cyan); margin-bottom: 16px; display: block; }
        .vp-headline { font-family: var(--font-display, 'Poppins', sans-serif); font-weight: 800; font-size: clamp(22px, 4vw, 30px); color: var(--text); line-height: 1.2; margin-bottom: 12px; letter-spacing: -0.5px; }
        .vp-sub { font-size: 15px; color: var(--muted); line-height: 1.6; margin-bottom: 28px; }
        .vp-textarea { width: 100%; min-height: 130px; background: var(--panel-2); border: 1.5px solid var(--border); border-radius: 12px; padding: 16px 18px; font-family: var(--font-body, 'Raleway', sans-serif); font-size: 15px; color: var(--text); resize: vertical; outline: none; transition: border-color .2s, box-shadow .2s; line-height: 1.6; }
        .vp-textarea::placeholder { color: var(--muted); }
        .vp-textarea:focus { border-color: var(--cyan); box-shadow: 0 0 0 3px rgba(92,212,230,0.08); }
        .vp-hint { font-size: 12px; color: var(--muted); margin-top: 10px; margin-bottom: 24px; display: flex; align-items: center; gap: 6px; }
        .vp-hint::before { content: '→'; color: var(--cyan); font-size: 13px; }
        .vp-btn { display: inline-flex; align-items: center; justify-content: center; gap: 8px; background: var(--yellow); color: var(--blue-dark); font-family: var(--font-display, 'Poppins', sans-serif); font-weight: 700; font-size: 15px; padding: 14px 32px; border-radius: 10px; border: none; cursor: pointer; transition: opacity .2s, transform .1s; letter-spacing: -0.2px; }
        .vp-btn:hover { opacity: 0.9; }
        .vp-btn:active { transform: scale(0.98); }
        .vp-btn-icon { width: 18px; height: 18px; }
        .vp-loading-wrap { display: flex; flex-direction: column; align-items: center; padding: 20px 0; gap: 20px; text-align: center; }
        .vp-spinner { width: 48px; height: 48px; border: 3px solid var(--border); border-top-color: var(--cyan); border-radius: 50%; animation: vp-spin .8s linear infinite; }
        @keyframes vp-spin { to { transform: rotate(360deg); } }
        .vp-loading-text { font-size: 15px; color: var(--muted); line-height: 1.6; }
        .vp-loading-steps { display: flex; flex-direction: column; gap: 10px; width: 100%; max-width: 320px; }
        .vp-ls-item { display: flex; align-items: center; gap: 10px; font-size: 13px; color: var(--muted); opacity: 0.4; transition: opacity .4s; }
        .vp-ls-item.lit { opacity: 1; color: var(--text); }
        .vp-ls-dot { width: 6px; height: 6px; border-radius: 50%; background: var(--border); flex-shrink: 0; transition: background .4s; }
        .vp-ls-item.lit .vp-ls-dot { background: var(--cyan); }
        .vp-result-tag { display: inline-flex; align-items: center; gap: 6px; background: rgba(222,232,0,0.12); border: 1px solid rgba(222,232,0,0.3); color: var(--yellow); font-size: 11px; font-weight: 700; letter-spacing: 1.5px; text-transform: uppercase; padding: 4px 12px; border-radius: 20px; margin-bottom: 20px; }
        .vp-result-headline { font-family: var(--font-display, 'Poppins', sans-serif); font-weight: 800; font-size: clamp(18px, 3.5vw, 24px); color: var(--text); line-height: 1.25; margin-bottom: 20px; letter-spacing: -0.4px; }
        .vp-result-block { background: var(--panel-2); border: 1px solid var(--border); border-radius: 12px; padding: 20px; margin-bottom: 12px; }
        .vp-result-block-label { font-size: 10px; font-weight: 700; letter-spacing: 2px; text-transform: uppercase; color: var(--cyan); margin-bottom: 8px; }
        .vp-result-block-text { font-size: 14px; color: #cdd5e0; line-height: 1.7; }
        .vp-solution-name { font-family: var(--font-display, 'Poppins', sans-serif); font-weight: 700; font-size: 17px; color: var(--cyan); margin-bottom: 6px; }
        .vp-divider { height: 1px; background: var(--border); margin: 24px 0; }
        .vp-cta-block { text-align: center; }
        .vp-cta-pre { font-size: 13px; color: var(--muted); margin-bottom: 16px; line-height: 1.5; }
        .vp-btn-demo { display: inline-flex; align-items: center; justify-content: center; gap: 8px; background: var(--yellow); color: var(--blue-dark); font-family: var(--font-display, 'Poppins', sans-serif); font-weight: 700; font-size: 15px; padding: 15px 36px; border-radius: 10px; text-decoration: none; transition: opacity .2s, transform .1s; letter-spacing: -0.2px; cursor: pointer; border: none; }
        .vp-btn-demo:hover { opacity: 0.9; }
        .vp-btn-ghost { display: inline-flex; align-items: center; font-size: 13px; color: var(--muted); background: none; border: none; cursor: pointer; margin-top: 14px; gap: 4px; font-family: var(--font-body, 'Raleway', sans-serif); text-decoration: underline; padding: 0; transition: color .2s; }
        .vp-btn-ghost:hover { color: var(--text); }
        .vp-trust { display: flex; align-items: center; justify-content: center; gap: 20px; margin-top: 20px; flex-wrap: wrap; }
        .vp-trust-item { display: flex; align-items: center; gap: 6px; font-size: 12px; color: var(--muted); }
        .vp-trust-dot { color: var(--cyan); font-size: 14px; }
        .vp-error { background: rgba(255,80,80,0.08); border: 1px solid rgba(255,80,80,0.25); color: #ff9090; border-radius: 10px; padding: 14px 18px; font-size: 14px; margin-top: 16px; line-height: 1.5; }
        @media (max-width: 480px) { .vp-panel { padding: 28px 20px; } .vp-brand { margin-bottom: 24px; } }
      `}</style>

      <div className="vp-wrap">
        <div className="vp-brand">
          <div className="vp-brand-dot">
            <svg viewBox="0 0 24 24"><path d="M12 2L2 7l10 5 10-5-10-5zM2 17l10 5 10-5M2 12l10 5 10-5" /></svg>
          </div>
          <div className="vp-brand-name">Virtuoso <span>IA</span></div>
        </div>

        <div className="vp-steps">
          <div className={`vp-step-pill${step === 'input' ? ' active' : ' done'}`}>Tu necesidad</div>
          <div className="vp-step-sep" />
          <div className={`vp-step-pill${step === 'loading' ? ' active' : step === 'result' ? ' done' : ''}`}>Analizando</div>
          <div className="vp-step-sep" />
          <div className={`vp-step-pill${step === 'result' ? ' active' : ''}`}>Tu diagnóstico</div>
        </div>

        <div className="vp-panel">
          {step === 'input' && (
            <div>
              <span className="vp-label">Diagnóstico gratuito · 60 segundos</span>
              <h2 className="vp-headline">¿Qué problema quieres resolver en tu negocio?</h2>
              <p className="vp-sub">Describe con tus palabras qué está pasando. Nuestro sistema analiza tu situación y te dice exactamente qué solución aplica — y por qué.</p>
              <textarea
                className="vp-textarea"
                value={idea}
                onChange={(e) => setIdea(e.target.value)}
                placeholder="Ej: Tengo un restaurante y pierdo reservas porque nadie responde WhatsApp en la noche. Quiero automatizar eso y que no se me escape ningún cliente..."
                required
              />
              <p className="vp-hint">Sé específico: industria, problema principal, qué has intentado.</p>
              <button className="vp-btn" onClick={handleAnalizar}>
                Analizar mi situación
                <svg className="vp-btn-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M5 12h14M12 5l7 7-7 7" /></svg>
              </button>
              {errMsg && <div className="vp-error">{errMsg}</div>}
            </div>
          )}

          {step === 'loading' && (
            <div className="vp-loading-wrap">
              <div className="vp-spinner" />
              <div className="vp-loading-text">Analizando tu situación...</div>
              <div className="vp-loading-steps">
                <div className={`vp-ls-item${litSteps[0] ? ' lit' : ''}`}><div className="vp-ls-dot" />Leyendo tu necesidad</div>
                <div className={`vp-ls-item${litSteps[1] ? ' lit' : ''}`}><div className="vp-ls-dot" />Cruzando con el portafolio Virtuoso</div>
                <div className={`vp-ls-item${litSteps[2] ? ' lit' : ''}`}><div className="vp-ls-dot" />Generando tu diagnóstico</div>
              </div>
            </div>
          )}

          {step === 'result' && resultado && (
            <div>
              <div className="vp-result-tag">✦ Tu diagnóstico Virtuoso IA</div>
              <h3 className="vp-result-headline">{resultado.titulo}</h3>

              <div className="vp-result-block">
                <div className="vp-result-block-label">El problema que detectamos</div>
                <div className="vp-result-block-text">{resultado.problema}</div>
              </div>

              <div className="vp-result-block">
                <div className="vp-result-block-label">Solución recomendada</div>
                <div className="vp-solution-name">{resultado.solucion_nombre}</div>
                <div className="vp-result-block-text">{resultado.solucion}</div>
              </div>

              <div className="vp-result-block">
                <div className="vp-result-block-label">Por qué aplica a tu caso</div>
                <div className="vp-result-block-text">{resultado.por_que}</div>
              </div>

              <div className="vp-divider" />

              <div className="vp-cta-block">
                <p className="vp-cta-pre">En una demo de 20 minutos te mostramos el sistema funcionando en vivo — con datos reales de tu industria.</p>
                <button className="vp-btn-demo" onClick={() => window.open(CALENDAR_URL, '_blank')}>
                  Agendar mi demo gratis
                  <svg width="16" height="16" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.5"><path d="M5 12h14M12 5l7 7-7 7" /></svg>
                </button>
                <br />
                <button className="vp-btn-ghost" onClick={handleRestart}>← Analizar otra situación</button>
              </div>

              <div className="vp-trust">
                <div className="vp-trust-item"><span className="vp-trust-dot">✦</span>Sin compromiso</div>
                <div className="vp-trust-item"><span className="vp-trust-dot">✦</span>20 minutos en vivo</div>
                <div className="vp-trust-item"><span className="vp-trust-dot">✦</span>Caso real de tu industria</div>
              </div>
            </div>
          )}
        </div>
      </div>
    </div>
  );
}
