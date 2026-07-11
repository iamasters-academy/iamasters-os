import Hero from '@/components/Hero';
import NicheSelectorGrid from '@/components/NicheSelectorGrid';
import MetricTicker from '@/components/MetricTicker';
import CTASection from '@/components/CTASection';

export default function HomePage() {
  return (
    <>
      <Hero />
      <NicheSelectorGrid />
      <MetricTicker />
      <CTASection />
    </>
  );
}
