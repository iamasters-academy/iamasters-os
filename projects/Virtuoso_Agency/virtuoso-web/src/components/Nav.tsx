import Link from 'next/link';
import { NAV_LINKS } from '@/lib/site-config';

export default function Nav() {
  return (
    <header
      style={{
        position: 'sticky',
        top: 0,
        zIndex: 50,
        background: 'rgba(255,255,255,0.95)',
        backdropFilter: 'blur(10px)',
        borderBottom: '1px solid var(--border)',
      }}
    >
      <div
        className="container"
        style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '14px 24px' }}
      >
        <Link href="/" style={{ fontWeight: 900, fontSize: 18, color: 'var(--primary)' }}>
          VIRTUOSO <span style={{ color: 'var(--cyan)' }}>IA</span>
        </Link>
        <nav style={{ display: 'flex', gap: 20 }}>
          {NAV_LINKS.map((link) => (
            <Link key={link.href} href={link.href} style={{ fontSize: 14, fontWeight: 600 }}>
              {link.label}
            </Link>
          ))}
        </nav>
      </div>
    </header>
  );
}
