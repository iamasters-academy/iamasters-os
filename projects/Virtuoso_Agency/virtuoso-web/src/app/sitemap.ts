import type { MetadataRoute } from 'next';
import { SITE } from '@/lib/seo';

export default function sitemap(): MetadataRoute.Sitemap {
  return [
    { url: SITE.url, changeFrequency: 'weekly', priority: 1 },
    { url: `${SITE.url}/restaurantes`, changeFrequency: 'monthly', priority: 0.9 },
    { url: `${SITE.url}/colegios`, changeFrequency: 'monthly', priority: 0.9 },
  ];
}
