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

export default function FeaturesSection() {
  return (
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
  );
}

