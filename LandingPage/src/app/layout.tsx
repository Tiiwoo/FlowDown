import type { Metadata, Viewport } from "next";
import "./globals.css";

export const metadata: Metadata = {
  title: "FlowDown - Privacy-First AI Chat for iOS & macOS",
  description:
    "A beautiful, privacy-focused AI client for iOS and macOS. Chat with multiple AI models, run local inference with MLX, and keep your data secure.",
  keywords: [
    "AI",
    "Chat",
    "iOS",
    "macOS",
    "Privacy",
    "LLM",
    "MLX",
    "OpenAI",
    "Claude",
    "Local AI",
  ],
  authors: [{ name: "FlowDown Team" }],
  openGraph: {
    title: "FlowDown - Privacy-First AI Chat",
    description:
      "Beautiful AI client for iOS & macOS with local inference support",
    type: "website",
    locale: "en_US",
  },
  twitter: {
    card: "summary_large_image",
    title: "FlowDown - Privacy-First AI Chat",
    description:
      "Beautiful AI client for iOS & macOS with local inference support",
  },
  robots: {
    index: true,
    follow: true,
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: [
    { media: "(prefers-color-scheme: light)", color: "#f8fafc" },
    { media: "(prefers-color-scheme: dark)", color: "#0f172a" },
  ],
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html lang="en" suppressHydrationWarning>
      <body className="min-h-screen antialiased">{children}</body>
    </html>
  );
}

