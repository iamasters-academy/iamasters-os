import type { Metadata } from 'next';
import { SITE } from '@/lib/seo';

export const metadata: Metadata = {
  title: 'Aviso de Privacidad',
  description: 'Aviso de privacidad de Virtuoso IA conforme a la Ley Federal de Protección de Datos Personales en Posesión de los Particulares (LFPDPPP).',
  alternates: { canonical: '/aviso-de-privacidad' },
  robots: { index: true, follow: true },
};

export default function AvisoPrivacidadPage() {
  return (
    <section className="container" style={{ padding: '96px 24px', maxWidth: 760 }}>
      <h1 style={{ fontSize: 'clamp(26px, 3.5vw, 38px)', marginBottom: 8 }}>Aviso de Privacidad</h1>
      <p style={{ fontSize: 13, color: 'var(--gray)', marginBottom: 8 }}>Última actualización: julio de 2026</p>
      <p style={{ fontSize: 13, color: 'var(--gray)', marginBottom: 40, fontStyle: 'italic' }}>
        Este aviso sigue la estructura estándar de la LFPDPPP. No sustituye una revisión legal formal antes de tratar datos personales a mayor escala.
      </p>

      <div style={{ display: 'flex', flexDirection: 'column', gap: 28, fontSize: 15, lineHeight: 1.8, color: 'var(--primary-dark)' }}>
        <div>
          <h2 style={{ fontSize: 18, marginBottom: 8 }}>Responsable del tratamiento de datos</h2>
          <p>
            {SITE.name}, con domicilio en México, es responsable del uso y protección de tus datos personales conforme a la
            Ley Federal de Protección de Datos Personales en Posesión de los Particulares (LFPDPPP). Puedes contactarnos en{' '}
            <a href={`mailto:${SITE.email}`} style={{ color: 'var(--primary)', fontWeight: 700 }}>{SITE.email}</a>.
          </p>
        </div>

        <div>
          <h2 style={{ fontSize: 18, marginBottom: 8 }}>Datos personales que recabamos</h2>
          <p>Dependiendo de cómo interactúes con nuestro sitio, podemos recabar:</p>
          <ul style={{ paddingLeft: 20, marginTop: 8, display: 'flex', flexDirection: 'column', gap: 4 }}>
            <li>La descripción de tu situación de negocio que escribes en el <strong>Diagnóstico gratuito</strong> (herramienta en /diagnostico).</li>
            <li>Nombre, correo electrónico, teléfono, nombre de tu negocio y mensaje, cuando llenas el formulario de <strong>Contacto</strong> o agendas una <strong>Sesión de Crecimiento</strong>.</li>
            <li>Datos técnicos básicos (dirección IP, origen de la solicitud) con fines de seguridad y prevención de abuso.</li>
          </ul>
        </div>

        <div>
          <h2 style={{ fontSize: 18, marginBottom: 8 }}>Finalidades del tratamiento</h2>
          <p>Usamos tus datos personales para:</p>
          <ul style={{ paddingLeft: 20, marginTop: 8, display: 'flex', flexDirection: 'column', gap: 4 }}>
            <li>Generar el diagnóstico automatizado que solicitas y mostrártelo en pantalla.</li>
            <li>Contactarte para agendar una demo o Sesión de Crecimiento, y darle seguimiento comercial a tu solicitud.</li>
            <li>Mejorar nuestros servicios a partir de las solicitudes que recibimos.</li>
          </ul>
          <p style={{ marginTop: 8 }}>No usamos tus datos para fines distintos a los aquí descritos sin tu consentimiento adicional.</p>
        </div>

        <div>
          <h2 style={{ fontSize: 18, marginBottom: 8 }}>Transferencias y encargados</h2>
          <p>
            Para operar estas herramientas, tus datos se procesan a través de proveedores de servicios que actúan como encargados
            de tratamiento: Airtable (almacenamiento del registro de leads) y Anthropic (generación del texto del diagnóstico,
            sin que tu texto se use para entrenar modelos según los términos vigentes de esa API). No vendemos ni compartimos
            tus datos con terceros para fines de mercadotecnia ajenos a Virtuoso IA.
          </p>
        </div>

        <div>
          <h2 style={{ fontSize: 18, marginBottom: 8 }}>Derechos ARCO</h2>
          <p>
            Tienes derecho a Acceder, Rectificar, Cancelar u Oponerte (derechos ARCO) al tratamiento de tus datos personales,
            así como a revocar tu consentimiento. Para ejercer cualquiera de estos derechos, escríbenos a{' '}
            <a href={`mailto:${SITE.email}`} style={{ color: 'var(--primary)', fontWeight: 700 }}>{SITE.email}</a> describiendo
            tu solicitud; te responderemos en un plazo razonable.
          </p>
        </div>

        <div>
          <h2 style={{ fontSize: 18, marginBottom: 8 }}>Cambios a este aviso</h2>
          <p>
            Podemos actualizar este aviso de privacidad. Cualquier cambio se publicará en esta misma página con su fecha de
            actualización.
          </p>
        </div>
      </div>
    </section>
  );
}
