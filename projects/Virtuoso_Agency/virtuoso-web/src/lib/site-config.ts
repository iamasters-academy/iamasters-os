export type NicheCard = {
  slug: string;
  label: string;
  description: string;
  live: boolean; // true = ruta ya construida, enlaza; false = "próximamente", sin link
};

export const NICHES: NicheCard[] = [
  { slug: 'restaurantes', label: 'Restaurantes', description: 'Reservas, WhatsApp y CRM en un solo sistema.', live: true },
  { slug: 'hoteles', label: 'Hoteles', description: 'Agente de reservas conversacional 24/7.', live: true },
  { slug: 'colegios', label: 'Colegios', description: 'Admisiones automatizadas con IA.', live: true },
  { slug: 'inmobiliarias', label: 'Inmobiliarias', description: 'Inventario, WhatsApp y CRM sincronizados.', live: true },
];

export type CapabilityCard = {
  slug: string;
  label: string;
  description: string;
  live: boolean;
};

export const CAPABILITIES: CapabilityCard[] = [
  { slug: 'reputacion-ia', label: 'Gestión de Reputación con IA', description: 'Responde reseñas y aumenta tu credibilidad online.', live: true },
  { slug: 'sitios-web-seo-geo-aeo', label: 'Sitios Web SEO/GEO/AEO', description: 'Te encuentran en Google y te recomiendan ChatGPT, Gemini y Perplexity.', live: true },
  { slug: 'automatizacion-financiera', label: 'Automatización Financiera', description: 'Cierre de caja y control financiero sin hojas de cálculo.', live: true },
  { slug: 'menus-digitales', label: 'Menús Digitales', description: 'Se actualiza en tiempo real y también vende.', live: true },
];

export const METRICS = [
  { value: '+40%', label: 'ventas en 30 días (caso Al Bat)' },
  { value: '38%', label: 'mejor conversión en admisiones (caso Colegio Boston)' },
  { value: '<2 min', label: 'tiempo de respuesta promedio' },
  { value: '24/7', label: 'atención sin intervención manual' },
];

export const NAV_LINKS = [
  { href: '/soluciones', label: 'Soluciones' },
  { href: '/diagnostico', label: 'Diagnóstico gratuito' },
  { href: '/sesion-crecimiento', label: 'Sesión de Crecimiento' },
  { href: '/contacto', label: 'Contacto' },
];
