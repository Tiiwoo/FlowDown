import type { Metadata } from "next";

export const metadata: Metadata = {
  title: {
    template: "%s | FlowDown Docs",
    default: "FlowDown Documentation",
  },
  description: "FlowDown documentation - Learn how to use FlowDown, a privacy-first AI workspace for iOS and macOS.",
  openGraph: {
    title: "FlowDown Documentation",
    description: "FlowDown documentation - Learn how to use FlowDown, a privacy-first AI workspace for iOS and macOS.",
    type: "website",
  },
};

export default function DocsRootLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return <>{children}</>;
}

