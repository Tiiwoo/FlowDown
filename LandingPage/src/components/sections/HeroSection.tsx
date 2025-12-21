import Link from "next/link";

export default function HeroSection() {
  return (
    <>
      {/* Hero Section */}
      <section className="pt-[180px] px-6 max-w-[1280px] mx-auto">
        <div className="max-w-[720px]">
          {/* Headline */}
          <h1 className="font-['Instrument_Serif'] text-[48px] text-[#242424] tracking-[-0.96px] leading-tight mb-4">
            AI That Works Even Without Us
          </h1>

          {/* Subheadline */}
          <p className="text-lg text-[rgba(0,0,0,0.75)] leading-relaxed mb-6">
            You can OWN a blazing fast and smooth Agent app. Switch between your
            AI services or use local models on your device.
          </p>

          {/* CTA */}
          <div className="flex flex-col gap-2">
            <Link
              href="#download"
              className="inline-flex bg-[#242424] text-white text-lg font-medium px-6 py-4 rounded-full shadow-sm hover:bg-[#1a1a1a] transition-colors w-fit"
            >
              Download from App Store
            </Link>
            <p className="text-xs text-[#828282]">
              Available on macOS 13.0+ / Supports Apple Silicon & Intel
            </p>
          </div>
        </div>
      </section>

      {/* App Screenshot */}
      <section className="px-6 mt-6 max-w-[1280px] mx-auto">
        <img
          src="/hero-image.png"
          alt="FlowDown App Screenshot"
          className="w-full h-[869px] object-cover rounded-sm"
        />

        {/* Read the User Guide button */}
        <Link
          href="#guide"
          className="inline-flex items-center text-lg font-medium text-[#242424] hover:opacity-70 transition-opacity mt-8"
        >
          Read the User Guide →
        </Link>
      </section>
    </>
  );
}

