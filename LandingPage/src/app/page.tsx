import {
  Navigation,
  HeroSection,
  FeaturesSection,
  FAQSection,
  TestimonialsSection,
  TeamSection,
  Footer,
} from "@/components/sections";

export default function LandingPage() {
  return (
    <div className="bg-[#f6f6f6] relative min-h-screen overflow-x-hidden">
      <Navigation />
      <HeroSection />
      <FeaturesSection />
      <FAQSection />
      <TestimonialsSection />
      <TeamSection />
      <Footer />

      {/* Decorative pigeon at bottom right */}
      <div className="fixed bottom-6 right-6 w-[100px] h-[100px] opacity-30 pointer-events-none">
        <span className="text-[80px]">🕊️</span>
      </div>
    </div>
  );
}
