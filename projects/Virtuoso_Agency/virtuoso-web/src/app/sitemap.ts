import type { MetadataRoute } from 'next';
import { SITE } from '@/lib/seo';

export default function sitemap(): MetadataRoute.Sitemap {
  return [
    { url: SITE.url, changeFrequency: 'weekly', priority: 1 },
    { url: `${SITE.url}/restaurantes`, changeFrequency: 'monthly', priority: 0.9 },
    { url: `${SITE.url}/hoteles`, changeFrequency: 'monthly', priority: 0.9 },
    { url: `${SITE.url}/colegios`, changeFrequency: 'monthly', priority: 0.9 },
    { url: `${SITE.url}/inmobiliarias`, changeFrequency: 'monthly', priority: 0.9 },
    { url: `${SITE.url}/soluciones`, changeFrequency: 'monthly', priority: 0.8 },
    { url: `${SITE.url}/soluciones/reputacion-ia`, changeFrequency: 'monthly', priority: 0.8 },
    { url: `${SITE.url}/soluciones/sitios-web-seo-geo-aeo`, changeFrequency: 'monthly', priority: 0.8 },
    { url: `${SITE.url}/soluciones/automatizacion-financiera`, changeFrequency: 'monthly', priority: 0.8 },
    { url: `${SITE.url}/soluciones/menus-digitales`, changeFrequency: 'monthly', priority: 0.8 },
  ];
}
