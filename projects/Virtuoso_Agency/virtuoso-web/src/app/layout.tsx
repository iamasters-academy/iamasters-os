import type { Metadata } from 'next';
import { Poppins, Raleway } from 'next/font/google';
import Nav from '@/components/Nav';
import Footer from '@/components/Footer';
import { SITE, orgJsonLd, JsonLd } from '@/lib/seo';
import './globals.css';

const display = Poppins({
  subsets: ['latin'],
  weight: ['700', '800'],
  variable: '--font-display',
  display: 'swap',
});

const body = Raleway({
  subsets: ['latin'],
  weight: ['400', '600', '700'],
  variable: '--font-body',
  display: 'swap',
});

export const metadata: Metadata = {
  metadataBase: new URL(SITE.url),
  title: {
    default: 'Virtuoso IA · Sistemas de IA especializados por industria',
    template: '%s | Virtuoso IA',
  },
  description: SITE.description,
  alternates: { canonical: '/' },
  openGraph: {
    type: 'website',
    locale: 'es_MX',
    siteName: SITE.name,
    title: 'Virtuoso IA · Sistemas de IA especializados por industria',
    description: SITE.description,
    images: [{ url: SITE.ogImage, width: 1200, height: 630, alt: SITE.name }],
  },
  robots: { index: true, follow: true },
};

export default function RootLayout({ children }: { children: React.ReactNode }) {
  return (
    <html lang="es" className={`${display.variable} ${body.variable}`}>
      <body>
        <JsonLd data={orgJsonLd()} />
        <Nav />
        <main>{children}</main>
        <Footer />
      </body>
    </html>
  );
}
