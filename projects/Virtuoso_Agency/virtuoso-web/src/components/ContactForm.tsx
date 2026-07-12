'use client';

import { useState, FormEvent } from 'react';

const API_URL = 'https://virtuoso-api.vercel.app/api/contacto';

const inputStyle: React.CSSProperties = {
  width: '100%',
  padding: '12px 14px',
  border: '1.5px solid var(--border)',
  borderRadius: 8,
  fontSize: 14,
  color: 'var(--primary-dark)',
  background: 'var(--gray-light)',
  outline: 'none',
  fontFamily: 'inherit',
};

const labelStyle: React.CSSProperties = {
  display: 'block',
  fontSize: 13,
  fontWeight: 700,
  color: 'var(--primary-dark)',
  marginBottom: 6,
};

export default function ContactForm() {
  const [status, setStatus] = useState<'idle' | 'sending' | 'ok' | 'error'>('idle');
  const [errorMsg, setErrorMsg] = useState('');

  async function handleSubmit(e: FormEvent<HTMLFormElement>) {
    e.preventDefault();
    setStatus('sending');
    const form = e.currentTarget;
    const data = new FormData(form);

    try {
      const res = await fetch(API_URL, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          nombre: data.get('nombre'),
          negocio: data.get('negocio'),
          email: data.get('email'),
          telefono: data.get('telefono'),
          mensaje: data.get('mensaje'),
        }),
      });
      const body = await res.json().catch(() => ({}));
      if (res.ok && body.ok) {
        setStatus('ok');
        form.reset();
      } else {
        setErrorMsg(body.error || 'Ocurrió un error al enviar.');
        setStatus('error');
      }
    } catch {
      setErrorMsg('No pudimos conectar con el servidor. Intenta de nuevo en un momento.');
      setStatus('error');
    }
  }

  if (status === 'ok') {
    return (
      <div style={{
        background: '#fff', border: '1px solid var(--border)', borderRadius: 12, padding: 40,
        display: 'flex', flexDirection: 'column', alignItems: 'center', justifyContent: 'center',
        gap: 16, minHeight: 320, textAlign: 'center',
      }}>
        <h3 style={{ fontSize: 22 }}>Mensaje enviado</h3>
        <p style={{ fontSize: 15, color: 'var(--gray)', lineHeight: 1.7, maxWidth: 340 }}>
          Gracias por escribirnos. Te contactamos en menos de 24 horas.
        </p>
        <button
          onClick={() => setStatus('idle')}
          style={{ fontSize: 14, color: 'var(--primary)', background: 'none', border: 'none', cursor: 'pointer', fontWeight: 600 }}
        >
          Enviar otro mensaje
        </button>
      </div>
    );
  }

  return (
    <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: 18, background: '#fff', border: '1px solid var(--border)', borderRadius: 12, padding: 32 }}>
      <div>
        <label style={labelStyle}>Nombre</label>
        <input name="nombre" placeholder="Tu nombre" style={inputStyle} required minLength={2} />
      </div>
      <div>
        <label style={labelStyle}>Negocio</label>
        <input name="negocio" placeholder="Nombre de tu restaurante, hotel, colegio..." style={inputStyle} />
      </div>
      <div>
        <label style={labelStyle}>Correo electrónico</label>
        <input name="email" type="email" placeholder="tu@negocio.com" style={inputStyle} required />
      </div>
      <div>
        <label style={labelStyle}>Teléfono</label>
        <input name="telefono" type="tel" placeholder="+52 55 1234 5678" style={inputStyle} />
      </div>
      <div>
        <label style={labelStyle}>Mensaje</label>
        <textarea name="mensaje" rows={4} placeholder="Cuéntanos qué necesitas..." style={{ ...inputStyle, resize: 'vertical' }} />
      </div>

      {status === 'error' && (
        <p style={{ fontSize: 13, color: '#b91c1c', background: '#fef2f2', padding: '10px 14px', borderRadius: 7 }}>
          {errorMsg}
        </p>
      )}

      <button
        type="submit"
        disabled={status === 'sending'}
        style={{
          background: status === 'sending' ? '#aaa' : 'var(--yellow)',
          color: 'var(--primary-dark)',
          fontWeight: 700,
          padding: '14px 28px',
          borderRadius: 999,
          border: 'none',
          cursor: status === 'sending' ? 'not-allowed' : 'pointer',
          fontFamily: 'inherit',
          fontSize: 15,
        }}
      >
        {status === 'sending' ? 'Enviando...' : 'Enviar mensaje'}
      </button>
    </form>
  );
}
