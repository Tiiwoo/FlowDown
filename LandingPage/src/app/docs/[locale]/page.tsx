import { Metadata } from "next";
import Link from "next/link";
import { getDocsConfig } from "@/lib/docs-config";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}): Promise<Metadata> {
  const { locale } = await params;
  const isZh = locale === "zh";

  return {
    title: isZh ? "FlowDown 文档" : "FlowDown Documentation",
    description: isZh
      ? "FlowDown 文档 - 学习如何使用 FlowDown，一个注重隐私的 iOS 和 macOS AI 工作空间。"
      : "FlowDown documentation - Learn how to use FlowDown, a privacy-first AI workspace for iOS and macOS.",
    alternates: {
      canonical: `/docs/${locale}`,
      languages: {
        en: "/docs/en",
        zh: "/docs/zh",
      },
    },
  };
}

export default async function DocsHomePage({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  const config = getDocsConfig(locale);
  const isZh = locale === "zh";

  return (
    <div>
      <h1 className="font-['Instrument_Serif'] text-4xl text-[#242424] tracking-[-0.5px] mb-3">
        {isZh ? "FlowDown 文档" : "FlowDown Documentation"}
      </h1>
      <p className="text-lg text-[#828282] mb-10">
        {isZh
          ? "欢迎使用 FlowDown 文档。选择一个主题开始吧。"
          : "Welcome to the FlowDown documentation. Choose a topic to get started."}
      </p>

      <div className="grid gap-4 md:grid-cols-2">
        {config.sidebarNav.map((section, idx) => (
          <div
            key={idx}
            className="bg-[#ebebeb] rounded-xl p-5 border border-[#e6e6e6] hover:border-[#d0d0d0] transition-colors"
          >
            <h2 className="font-semibold text-[#242424] mb-3 text-base">
              {section.title}
            </h2>
            {section.items && (
              <ul className="space-y-1.5">
                {section.items.slice(0, 4).map((item, itemIdx) => (
                  <li key={itemIdx}>
                    <Link
                      href={item.href || "#"}
                      className="text-[#454545] hover:text-[#242424] text-sm transition-colors"
                    >
                      {item.title}
                    </Link>
                  </li>
                ))}
                {section.items.length > 4 && (
                  <li className="text-[#9d9d9d] text-sm">
                    +{section.items.length - 4} more...
                  </li>
                )}
              </ul>
            )}
          </div>
        ))}
      </div>
    </div>
  );
}
