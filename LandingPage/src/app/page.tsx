"use client";

import Link from "next/link";
import { useState } from "react";

// Star rating component
function StarRating() {
  return (
    <div className="flex gap-0.5">
      {[...Array(5)].map((_, i) => (
        <svg key={i} className="w-4 h-4" viewBox="0 0 24 24" fill="#FFB800">
          <path d="M12 2l3.09 6.26L22 9.27l-5 4.87 1.18 6.88L12 17.77l-6.18 3.25L7 14.14 2 9.27l6.91-1.01L12 2z" />
        </svg>
      ))}
    </div>
  );
}

// Glass icon component for feature cards
function GlassIcon({ children }: { children: React.ReactNode }) {
  return (
    <div className="relative">
      {/* Shadow ellipse */}
      <div className="absolute w-[40px] h-[42px] left-[30px] top-[50px] bg-[#e0e0e0] rounded-full blur-sm" />
      {/* Glass container */}
      <div className="relative w-[100px] h-[100px] rounded-full border-2 border-white glass-icon flex items-center justify-center">
        <span className="text-[60px] text-[#242424] font-extralight leading-none">
          {children}
        </span>
      </div>
    </div>
  );
}

// Feature card component
function FeatureCard({
  icon,
  title,
  description,
}: {
  icon: React.ReactNode;
  title: string;
  description: React.ReactNode;
}) {
  return (
    <div className="flex-1 min-w-[280px] border border-[rgba(221,221,221,0.42)] rounded-[36px] feature-card-bg overflow-hidden">
      <div className="p-6 flex flex-col items-center justify-between h-[340px]">
        <GlassIcon>{icon}</GlassIcon>
        <div className="w-full flex flex-col gap-2">
          <h3 className="text-lg font-semibold text-[#242424]">{title}</h3>
          <p className="text-sm text-[#828282] leading-relaxed">
            {description}
          </p>
        </div>
      </div>
    </div>
  );
}

// FAQ item component
function FAQItem({
  question,
  answer,
  isOpen,
  onClick,
}: {
  question: string;
  answer?: React.ReactNode;
  isOpen: boolean;
  onClick: () => void;
}) {
  return (
    <div className="flex flex-col w-full">
      <button
        onClick={onClick}
        className={`flex items-center justify-between font-['Instrument_Serif'] text-3xl tracking-[-0.72px] text-left transition-colors duration-300 ${
          isOpen ? "text-black" : "text-[#9d9d9d]"
        } hover:text-black`}
      >
        <span>{question}</span>
        <svg
          className={`w-6 h-6 flex-shrink-0 transition-transform duration-300 ease-out ${
            isOpen ? "rotate-180" : "rotate-0"
          }`}
          fill="none"
          stroke="currentColor"
          viewBox="0 0 24 24"
        >
          <path
            strokeLinecap="round"
            strokeLinejoin="round"
            strokeWidth={2}
            d="M19 9l-7 7-7-7"
          />
        </svg>
      </button>
      <div
        className={`grid transition-all duration-300 ease-out ${
          isOpen ? "grid-rows-[1fr] opacity-100 mt-4" : "grid-rows-[0fr] opacity-0 mt-0"
        }`}
      >
        <div className="overflow-hidden">
          {answer && (
            <div className="text-[#1c1c1c] text-sm leading-relaxed">
              {answer}
            </div>
          )}
        </div>
      </div>
      <div className="h-px bg-[#dddddd] w-full mt-4" />
    </div>
  );
}

// Testimonial component
function Testimonial({
  text,
  author,
  source,
}: {
  text: string;
  author: string;
  source: string;
}) {
  return (
    <div className="flex gap-4">
      <div className="w-0.5 h-12 bg-[#1c1c1c] flex-shrink-0" />
      <div className="flex flex-col gap-2">
        <p className="text-xs leading-5 text-[#1c1c1c] max-w-[480px]">
          {text}
        </p>
        <StarRating />
        <p className="text-xs text-[#1c1c1c]">
          {author} <span className="text-[#b3b3b3]">from {source}</span>
        </p>
      </div>
    </div>
  );
}

// Team card component
function TeamCard({
  quote,
  name,
  role,
  avatarColor,
}: {
  quote: string;
  name: string;
  role: string;
  avatarColor: string;
}) {
  return (
    <div className="flex-1 bg-white border border-[#e6e6e6] rounded-xl p-6 flex flex-col justify-between min-h-[220px]">
      <p className="text-lg font-medium text-black leading-relaxed">{quote}</p>
      <div className="flex items-center gap-3">
        <div
          className={`w-[36px] h-[36px] rounded-full ${avatarColor}`}
          style={{
            background: `linear-gradient(135deg, ${avatarColor === "bg-blue-400" ? "#60a5fa, #3b82f6" : avatarColor === "bg-purple-400" ? "#c084fc, #a855f7" : "#fb923c, #f97316"})`,
          }}
        />
        <div>
          <p className="text-sm font-medium text-black">{name}</p>
          <p className="text-sm font-medium text-[#828282]">{role}</p>
        </div>
      </div>
    </div>
  );
}

export default function LandingPage() {
  const [openFAQ, setOpenFAQ] = useState<number>(1);

  return (
    <div className="bg-[#f6f6f6] relative min-h-screen overflow-x-hidden">
      {/* Navigation */}
      <nav className="fixed top-0 left-0 right-0 bg-[#f6f6f6] z-50 h-[72px]">
        <div className="max-w-[1280px] mx-auto flex items-center justify-between px-6 h-full">
          {/* Logo */}
          <Link href="/" className="flex items-center gap-2">
            <img
              src="/icon-primary.png"
              alt="FlowDown"
              className="w-[38px] h-[38px] rounded-full"
            />
            <span className="text-base font-semibold text-[#242424]">
              FlowDown
            </span>
          </Link>

          {/* Nav items */}
          <div className="flex items-center gap-8">
            <Link
              href="#docs"
              className="text-base font-medium text-[#242424] hover:opacity-70 transition-opacity"
            >
              Documentation
            </Link>
            <Link
              href="https://github.com/aspect-apps/FlowDown"
              target="_blank"
              className="text-base font-medium text-[#242424] hover:opacity-70 transition-opacity"
            >
              Get Source Code
            </Link>
            <Link
              href="#models"
              className="text-base font-medium text-[#242424] hover:opacity-70 transition-opacity"
            >
              Add Models
            </Link>
            <Link
              href="#download"
              className="btn-primary text-white text-sm font-medium px-5 py-2.5 rounded-lg shadow-sm hover:opacity-90 transition-opacity"
            >
              Download
            </Link>
          </div>
        </div>
      </nav>

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

      {/* Why Choose FlowDown Section */}
      <section className="px-6 mt-[120px] max-w-[1280px] mx-auto" id="features">
        <h2 className="font-['Instrument_Serif'] text-[42px] text-[#242424] tracking-[-0.84px] mb-4">
          Why Choose FlowDown
        </h2>

        {/* Feature cards row 1 */}
        <div className="flex flex-wrap gap-6 mt-8">
          <FeatureCard
            icon="􀼔"
            title="Privacy First"
            description={
              <>
                Your conversations and API keys never leave your device.{" "}
                <strong>
                  All data is stored locally or synced via your private iCloud
                </strong>
                . We collect nothing.
              </>
            }
          />
          <FeatureCard
            icon="􀫊"
            title="Native Performance"
            description={
              <>
                Built with <strong>Swift</strong>, FlowDown is lightweight and
                incredibly fast. No web wrappers, just a seamless,{" "}
                <strong>native experience</strong> on iOS and macOS.
              </>
            }
          />
          <FeatureCard
            icon="􂮢"
            title="Universal Compatibility"
            description={
              <>
                Connect to any{" "}
                <strong>
                  OpenAI-compatible API, including self-hosted models
                </strong>
                , giving you complete freedom and control.
              </>
            }
          />
        </div>

        {/* Powerful Workflows Card */}
        <div className="mt-8 bg-white rounded-[36px] border border-[rgba(221,221,221,0.42)] overflow-hidden h-[580px] relative">
          {/* Blurred background */}
          <div
            className="absolute inset-0 bg-gradient-to-br from-sky-200/40 via-blue-100/30 to-teal-100/40 blur-sm"
            style={{
              backgroundImage:
                "linear-gradient(135deg, rgba(125,211,252,0.3) 0%, rgba(186,230,253,0.2) 50%, rgba(153,246,228,0.3) 100%)",
            }}
          />

          {/* Content */}
          <div className="absolute left-[40px] top-[40px] z-10">
            <h3 className="text-3xl font-semibold text-black mb-1">
              Powerful Workflows
            </h3>
            <p className="text-lg text-[#828282]">
              Vision Support: Interact with vision-capable models.
            </p>
          </div>

          {/* iPhone mockups */}
          <div className="absolute left-1/2 -translate-x-1/2 top-[240px] flex gap-6">
            {[1, 2, 3, 4].map((i) => (
              <div
                key={i}
                className="w-[200px] h-[430px] bg-white rounded-[32px] border-6 border-[#d5d5d5] overflow-hidden shadow-xl"
              >
                {/* iPhone notch */}
                <div className="h-6 bg-black flex justify-center items-end pb-0.5">
                  <div className="w-16 h-4 bg-black rounded-b-lg" />
                </div>
                {/* Screen content placeholder */}
                <div className="h-full bg-gradient-to-b from-gray-50 to-gray-100 p-3">
                  <div className="space-y-2">
                    <div className="h-3 bg-gray-200 rounded w-3/4" />
                    <div className="h-3 bg-gray-200 rounded w-1/2" />
                    <div className="h-24 bg-blue-100 rounded-lg mt-3" />
                    <div className="h-3 bg-gray-200 rounded w-2/3" />
                    <div className="h-3 bg-gray-200 rounded w-1/2" />
                  </div>
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Feature cards row 2 */}
        <div className="flex flex-wrap gap-6 mt-8">
          <FeatureCard
            icon="􀩾"
            title="Rich User Experience"
            description={
              <>
                Enjoy <strong>full Markdown rendering</strong>, syntax
                highlighting, and a buttery-smooth interface that makes
                interacting with AI a pleasure.
              </>
            }
          />
          <FeatureCard
            icon="􀙸"
            title="iCloud Sync"
            description="Seamlessly syncs your conversations, settings, and custom models across all your Apple devices."
          />
          <FeatureCard
            icon="􀡅"
            title="Open Source Compatibility"
            description="FlowDown is fully open source under the AGPL-3.0 license. We invite you to inspect the code and verify our commitment to privacy and quality."
          />
        </div>
      </section>

      {/* FAQ Section */}
      <section className="px-6 mt-[120px] max-w-[1280px] mx-auto" id="faq">
        <h2 className="font-['Instrument_Serif'] text-[42px] text-[#242424] tracking-[-0.84px] mb-10">
          Frequently Asked Questions
        </h2>

        <div className="flex flex-col gap-10">
          <FAQItem
            question="Which AI models does FlowDown support?"
            isOpen={openFAQ === 0}
            onClick={() => setOpenFAQ(openFAQ === 0 ? -1 : 0)}
            answer={
              <div className="space-y-4">
                <p>
                  FlowDown supports all models compatible with OpenAI API format, including:
                </p>
                <ul className="list-disc ml-6 space-y-1">
                  <li><strong>Built-in free models:</strong> Ready to use without configuration</li>
                  <li><strong>Major service providers:</strong> OpenAI, Claude (via OpenRouter), Alibaba Cloud, ByteDance, etc.</li>
                  <li><strong>Local models:</strong> Support for Ollama and MLX local deployment</li>
                  <li><strong>Custom interfaces:</strong> Any service compatible with OpenAI API</li>
                </ul>
                <Link
                  href="https://flowdown.ai/en-US"
                  target="_blank"
                  className="text-base font-medium text-black inline-block mt-3"
                >
                  LEARN MORE →
                </Link>
                <img src="/q-and-a-1.png" alt="AI Models Support" className="w-full rounded-lg mt-3" />
              </div>
            }
          />

          <FAQItem
            question="Which platforms does FlowDown support?"
            isOpen={openFAQ === 1}
            onClick={() => setOpenFAQ(openFAQ === 1 ? -1 : 1)}
            answer={
              <div className="space-y-4">
                <p>
                  FlowDown provides native app support across all platforms:
                </p>
                <ul className="list-disc ml-6 space-y-1">
                  <li><strong>macOS:</strong> Full-featured desktop application</li>
                  <li><strong>iOS:</strong> Mobile app optimized for iPhone</li>
                  <li><strong>iPadOS:</strong> Tablet app adapted for iPad</li>
                </ul>
                <p>
                  All versions are native applications, not web-based, ensuring
                  optimal performance and user experience
                </p>
                <Link
                  href="https://flowdown.ai/en-US"
                  target="_blank"
                  className="text-base font-medium text-black inline-block mt-3"
                >
                  LEARN MORE →
                </Link>
                <img src="/q-and-a-2.png" alt="Platform Support" className="w-full rounded-lg mt-3" />
              </div>
            }
          />

          <FAQItem
            question="How to use FlowDown's tool calling features?"
            isOpen={openFAQ === 2}
            onClick={() => setOpenFAQ(openFAQ === 2 ? -1 : 2)}
            answer={
              <div className="space-y-4">
                <p>
                  FlowDown supports powerful Tool Call functionality:
                </p>
                <ul className="list-disc ml-6 space-y-1">
                  <li><strong>Web search:</strong> Real-time access to latest information</li>
                  <li><strong>Document processing:</strong> Analyze and process various file types</li>
                </ul>
                <p>
                  We recommend using models like Gemini Flash for the best tool calling experience
                </p>
                <Link
                  href="https://flowdown.ai/en-US"
                  target="_blank"
                  className="text-base font-medium text-black inline-block mt-3"
                >
                  LEARN MORE →
                </Link>
                <img src="/q-and-a-3.png" alt="Tool Calling Features" className="w-full rounded-lg mt-3" />
              </div>
            }
          />

          <FAQItem
            question="How is data security and privacy ensured?"
            isOpen={openFAQ === 3}
            onClick={() => setOpenFAQ(openFAQ === 3 ? -1 : 3)}
            answer={
              <div className="space-y-4">
                <ul className="list-disc ml-6 space-y-1">
                  <li><strong>Local storage:</strong> All conversation data is stored on your device</li>
                  <li><strong>No data collection:</strong> FlowDown does not collect or store your conversation content</li>
                  <li><strong>Direct connection:</strong> Communicates directly with AI service providers without intermediaries</li>
                  <li><strong>Open source transparency:</strong> Code is open source to ensure transparency</li>
                </ul>
                <Link
                  href="https://flowdown.ai/en-US"
                  target="_blank"
                  className="text-base font-medium text-black inline-block mt-3"
                >
                  LEARN MORE →
                </Link>
                <img src="/q-and-a-4.png" alt="Data Security" className="w-full rounded-lg mt-3" />
              </div>
            }
          />

          <FAQItem
            question="How to obtain and configure models?"
            isOpen={openFAQ === 4}
            onClick={() => setOpenFAQ(openFAQ === 4 ? -1 : 4)}
            answer={
              <div className="space-y-4">
                <ul className="list-disc ml-6 space-y-1">
                  <li><strong>Zero configuration:</strong> Built-in free models, ready to use after download</li>
                  <li><strong>Custom configuration:</strong> Support for adding your own API keys</li>
                  <li><strong>Import/Export:</strong> Support for importing and exporting model configurations</li>
                  <li><strong>Technical support:</strong> Provides detailed configuration guides and community support</li>
                </ul>
                <Link
                  href="https://flowdown.ai/en-US"
                  target="_blank"
                  className="text-base font-medium text-black inline-block mt-3"
                >
                  LEARN MORE →
                </Link>
                <img src="/q-and-a-5.png" alt="Model Configuration" className="w-full rounded-lg mt-3" />
              </div>
            }
          />
        </div>
      </section>

      {/* User Testimonials Section */}
      <section className="px-6 mt-[120px] max-w-[1280px] mx-auto">
        <h2 className="font-['Instrument_Serif'] text-[42px] text-[#242424] tracking-[-0.84px] mb-10">
          LOVE FROM OUR USERS
        </h2>

        <div className="flex justify-between gap-12">
          {/* Left column */}
          <div className="flex flex-col gap-8">
            <Testimonial
              text="The performance of FlowDown is amazing! I was truly impressed by the rendering performance, even during the beta testing stage - it's significantly better than the native official ChatGPT app. I also hold a similar attitude with the developer (or project leader), toward the concept of native app & privacy. As someone who has been using this app since literally day one, I can really see the effort the team has put into it. The project leader is active in the Discord group, constantly working to fix bugs and add new features.

That said, there are still a few frustrating issues. I have to admit that the process to add a model from external service provider is way too complicated. I understand this is partly due to Apple's restrictions, but I really hope a more streamlined solution can be found. Also, the macOS app is not 'that' native. While the performance is solid, the user interface doesn't fully align with the desktop experience-especially the right-click menu and the settings page, which feel out of place."
              author="ChrisLloy"
              source="App Store"
            />
            <Testimonial
              text="FlowDown really is the most fluent LLM client I've ever used. The smoothness of the app experience cannot be matched by any other app. Developer's support response is remarkably fast compared to others on Discord. Overall, I do think it has great potential for more additional features in future updates. Truly having a great time with it."
              author="Vcg-Soup"
              source="X.com"
            />
          </div>

          {/* Right column */}
          <div className="flex flex-col gap-8">
            <Testimonial
              text="FlowDown really is the most fluent LLM client I've ever used. The smoothness of the app experience cannot be matched by any other app. Developer's support response is remarkably fast compared to others on Discord. Overall, I do think it has great potential for more additional features in future updates. Truly having a great time with it."
              author="Vcg-Soup"
              source="App Store"
            />
            <Testimonial
              text="好耶 ❤️ ❤️❤️"
              author="Vcg-Soup"
              source="App Store"
            />
            <Testimonial
              text="FlowDown really is the most fluent LLM client I've ever used. The smoothness of the app experience cannot be matched by any other app. Developer's support response is remarkably fast compared to others on Discord. Overall, I do think it has great potential for more additional features in future updates. Truly having a great time with it."
              author="Vcg-Soup"
              source="App Store"
            />
          </div>
        </div>
      </section>

      {/* Team Section */}
      <section className="px-6 mt-[120px] max-w-[1280px] mx-auto">
        <h2 className="font-['Instrument_Serif'] text-[42px] text-[#242424] tracking-[-0.84px] mb-10">
          MEET THE TEAM
        </h2>

        {/* Team cards row 1 */}
        <div className="flex gap-6 mb-6">
          <TeamCard
            quote="We build with passion and love."
            name="Name"
            role="Description"
            avatarColor="bg-orange-400"
          />
          <TeamCard
            quote="Core developer of FlowDown, shipping cutting-edge features."
            name="Name"
            role="Description"
            avatarColor="bg-purple-400"
          />
          <TeamCard
            quote="Core developer of FlowDown Text Rendering Engine."
            name="Name"
            role="Description"
            avatarColor="bg-blue-400"
          />
        </div>

        {/* Team cards row 2 */}
        <div className="flex gap-6">
          <TeamCard
            quote="Build our beautiful websites."
            name="Name"
            role="Description"
            avatarColor="bg-orange-400"
          />
          <TeamCard
            quote="Architecting state-of-the-art solutions, driven by passion."
            name="Name"
            role="Description"
            avatarColor="bg-purple-400"
          />
          <TeamCard
            quote="Design the beautiful icons for FlowDown."
            name="Name"
            role="Description"
            avatarColor="bg-blue-400"
          />
        </div>
      </section>

      {/* Footer */}
      <footer className="bg-white mt-[120px] relative overflow-hidden">
        {/* Grid pattern overlay */}
        <div
          className="absolute inset-0 opacity-10"
          style={{
            backgroundImage: `repeating-linear-gradient(0deg, transparent, transparent 367px, #d9d9d9 367px, #d9d9d9 368px),
                             repeating-linear-gradient(90deg, transparent, transparent 367px, #d9d9d9 367px, #d9d9d9 368px)`,
            mixBlendMode: "darken",
          }}
        />

        <div className="border-t border-[#dddddd]" />

        <div className="max-w-[1280px] mx-auto px-6 py-12 relative">
          <div className="flex justify-between">
            {/* Left side - Logo & info */}
            <div className="flex flex-col gap-2">
              <p className="text-lg text-[#242424]">FlowDown.ai</p>
              <p className="text-sm font-medium text-[#aeaeae]">
                © 2025 FlowDown Team. All rights reserved.
              </p>
              {/* Decorative pigeon */}
              <div className="w-[80px] h-[60px] bg-gradient-to-br from-blue-400 to-purple-500 rounded-[30px] opacity-50 mt-3" />
            </div>

            {/* Center-left - Download links */}
            <div className="flex flex-col gap-4">
              <p className="text-sm font-medium text-[#242424]">Download</p>
              <div className="flex flex-col gap-4 text-sm font-medium text-[#454545]">
                <Link href="#" className="hover:text-[#242424] transition-colors">
                  iOS App Store
                </Link>
                <Link href="#" className="hover:text-[#242424] transition-colors">
                  macOS App Store
                </Link>
                <Link
                  href="https://github.com/aspect-apps/FlowDown"
                  target="_blank"
                  className="hover:text-[#242424] transition-colors"
                >
                  Get Source Code
                </Link>
              </div>
            </div>

            {/* Center - Doc links */}
            <div className="flex flex-col gap-4">
              <p className="text-sm font-medium text-[#242424]">Doc</p>
              <div className="flex flex-col gap-4 text-sm font-medium text-[#454545]">
                <Link href="#" className="hover:text-[#242424] transition-colors">
                  Get Local Models
                </Link>
                <Link href="#" className="hover:text-[#242424] transition-colors">
                  Get Cloud Models
                </Link>
                <Link href="#" className="hover:text-[#242424] transition-colors">
                  Basic Usage
                </Link>
                <Link href="#" className="hover:text-[#242424] transition-colors">
                  FAQ
                </Link>
              </div>
            </div>

            {/* Right - Other links */}
            <div className="flex flex-col gap-4">
              <p className="text-sm font-medium text-[#242424]">Others</p>
              <div className="flex flex-col gap-4 text-sm font-medium text-[#454545]">
                <Link href="#" className="hover:text-[#242424] transition-colors">
                  Price
                </Link>
                <Link href="#" className="hover:text-[#242424] transition-colors">
                  Privacy
                </Link>
                <Link href="#" className="hover:text-[#242424] transition-colors">
                  Terms of Service
                </Link>
              </div>
            </div>
          </div>

          {/* Social icons */}
          <div className="flex gap-2 mt-[120px]">
            {/* GitHub */}
            <Link
              href="https://github.com/aspect-apps/FlowDown"
              target="_blank"
              className="w-10 h-10 flex items-center justify-center rounded hover:bg-gray-100 transition-colors"
            >
              <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                <path d="M12 0c-6.626 0-12 5.373-12 12 0 5.302 3.438 9.8 8.207 11.387.599.111.793-.261.793-.577v-2.234c-3.338.726-4.033-1.416-4.033-1.416-.546-1.387-1.333-1.756-1.333-1.756-1.089-.745.083-.729.083-.729 1.205.084 1.839 1.237 1.839 1.237 1.07 1.834 2.807 1.304 3.492.997.107-.775.418-1.305.762-1.604-2.665-.305-5.467-1.334-5.467-5.931 0-1.311.469-2.381 1.236-3.221-.124-.303-.535-1.524.117-3.176 0 0 1.008-.322 3.301 1.23.957-.266 1.983-.399 3.003-.404 1.02.005 2.047.138 3.006.404 2.291-1.552 3.297-1.23 3.297-1.23.653 1.653.242 2.874.118 3.176.77.84 1.235 1.911 1.235 3.221 0 4.609-2.807 5.624-5.479 5.921.43.372.823 1.102.823 2.222v3.293c0 .319.192.694.801.576 4.765-1.589 8.199-6.086 8.199-11.386 0-6.627-5.373-12-12-12z" />
              </svg>
            </Link>
            {/* Twitter/X */}
            <Link
              href="#"
              className="w-10 h-10 flex items-center justify-center rounded hover:bg-gray-100 transition-colors"
            >
              <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
              </svg>
            </Link>
            {/* Discord */}
            <Link
              href="#"
              className="w-10 h-10 flex items-center justify-center rounded hover:bg-gray-100 transition-colors"
            >
              <svg className="w-6 h-6" fill="currentColor" viewBox="0 0 24 24">
                <path d="M20.317 4.3698a19.7913 19.7913 0 00-4.8851-1.5152.0741.0741 0 00-.0785.0371c-.211.3753-.4447.8648-.6083 1.2495-1.8447-.2762-3.68-.2762-5.4868 0-.1636-.3933-.4058-.8742-.6177-1.2495a.077.077 0 00-.0785-.037 19.7363 19.7363 0 00-4.8852 1.515.0699.0699 0 00-.0321.0277C.5334 9.0458-.319 13.5799.0992 18.0578a.0824.0824 0 00.0312.0561c2.0528 1.5076 4.0413 2.4228 5.9929 3.0294a.0777.0777 0 00.0842-.0276c.4616-.6304.8731-1.2952 1.226-1.9942a.076.076 0 00-.0416-.1057c-.6528-.2476-1.2743-.5495-1.8722-.8923a.077.077 0 01-.0076-.1277c.1258-.0943.2517-.1923.3718-.2914a.0743.0743 0 01.0776-.0105c3.9278 1.7933 8.18 1.7933 12.0614 0a.0739.0739 0 01.0785.0095c.1202.099.246.1981.3728.2924a.077.077 0 01-.0066.1276 12.2986 12.2986 0 01-1.873.8914.0766.0766 0 00-.0407.1067c.3604.698.7719 1.3628 1.225 1.9932a.076.076 0 00.0842.0286c1.961-.6067 3.9495-1.5219 6.0023-3.0294a.077.077 0 00.0313-.0552c.5004-5.177-.8382-9.6739-3.5485-13.6604a.061.061 0 00-.0312-.0286zM8.02 15.3312c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9555-2.4189 2.157-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.9555 2.4189-2.1569 2.4189zm7.9748 0c-1.1825 0-2.1569-1.0857-2.1569-2.419 0-1.3332.9554-2.4189 2.1569-2.4189 1.2108 0 2.1757 1.0952 2.1568 2.419 0 1.3332-.946 2.4189-2.1568 2.4189Z" />
              </svg>
            </Link>
            {/* Email */}
            <Link
              href="mailto:contact@flowdown.ai"
              className="w-10 h-10 flex items-center justify-center rounded hover:bg-gray-100 transition-colors"
            >
              <svg
                className="w-6 h-6"
                fill="none"
                stroke="currentColor"
                viewBox="0 0 24 24"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M3 8l7.89 5.26a2 2 0 002.22 0L21 8M5 19h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v10a2 2 0 002 2z"
                />
              </svg>
            </Link>
          </div>
        </div>
      </footer>

      {/* Decorative pigeon at bottom right */}
      <div className="fixed bottom-6 right-6 w-[100px] h-[100px] opacity-30 pointer-events-none">
        <span className="text-[80px]">🕊️</span>
      </div>
    </div>
  );
}
