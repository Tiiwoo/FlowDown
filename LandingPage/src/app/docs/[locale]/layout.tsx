import Navigation from "@/components/sections/Navigation";
import { Sidebar, MobileNav } from "@/components/docs";
import { getDocsConfig } from "@/lib/docs-config";
import { notFound } from "next/navigation";

const supportedLocales = ["en", "zh"];

export function generateStaticParams() {
  return supportedLocales.map((locale) => ({ locale }));
}

export default async function DocsLayout({
  children,
  params,
}: {
  children: React.ReactNode;
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;

  if (!supportedLocales.includes(locale)) {
    notFound();
  }

  const config = getDocsConfig(locale);

  return (
    <div className="h-screen flex flex-col bg-[#f6f6f6] overflow-hidden">
      {/* Shared Navigation from Landing Page */}
      <Navigation />

      {/* Main layout with sidebar - fixed height below nav */}
      <div className="flex flex-1 pt-[72px] overflow-hidden">
        {/* Desktop sidebar - independent scroll */}
        <div className="hidden lg:block h-full">
          <Sidebar items={config.sidebarNav} locale={locale} />
        </div>

        {/* Main content - independent scroll */}
        <main className="flex-1 min-w-0 overflow-y-auto">
          <div className="max-w-4xl mx-auto px-6 py-10">
            <article className="docs-content">{children}</article>
          </div>
        </main>

        {/* Mobile navigation */}
        <MobileNav items={config.sidebarNav} locale={locale} />
      </div>
    </div>
  );
}
