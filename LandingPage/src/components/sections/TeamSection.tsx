import { FadeIn, StaggerContainer, StaggerItem } from "@/components/animations";

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
    <div className="bg-white border border-[#e6e6e6] rounded-xl p-6 flex flex-col justify-between min-h-[220px] h-full">
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

export default function TeamSection() {
  return (
    <section className="px-6 mt-[120px] max-w-[1280px] mx-auto">
      <FadeIn>
        <h2 className="font-['Instrument_Serif'] text-[42px] text-[#242424] tracking-[-0.84px] mb-10">
          MEET THE TEAM
        </h2>
      </FadeIn>

      {/* Team cards row 1 */}
      <StaggerContainer className="flex gap-6 mb-6">
        <StaggerItem className="flex-1">
          <TeamCard
            quote="We build with passion and love."
            name="Name"
            role="Description"
            avatarColor="bg-orange-400"
          />
        </StaggerItem>
        <StaggerItem className="flex-1">
          <TeamCard
            quote="Core developer of FlowDown, shipping cutting-edge features."
            name="Name"
            role="Description"
            avatarColor="bg-purple-400"
          />
        </StaggerItem>
        <StaggerItem className="flex-1">
          <TeamCard
            quote="Core developer of FlowDown Text Rendering Engine."
            name="Name"
            role="Description"
            avatarColor="bg-blue-400"
          />
        </StaggerItem>
      </StaggerContainer>

      {/* Team cards row 2 */}
      <StaggerContainer className="flex gap-6" delay={0.2}>
        <StaggerItem className="flex-1">
          <TeamCard
            quote="Build our beautiful websites."
            name="Name"
            role="Description"
            avatarColor="bg-orange-400"
          />
        </StaggerItem>
        <StaggerItem className="flex-1">
          <TeamCard
            quote="Architecting state-of-the-art solutions, driven by passion."
            name="Name"
            role="Description"
            avatarColor="bg-purple-400"
          />
        </StaggerItem>
        <StaggerItem className="flex-1">
          <TeamCard
            quote="Design the beautiful icons for FlowDown."
            name="Name"
            role="Description"
            avatarColor="bg-blue-400"
          />
        </StaggerItem>
      </StaggerContainer>
    </section>
  );
}

