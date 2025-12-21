import type { Metadata, Viewport } from "next";
import { Inter, Instrument_Serif } from "next/font/google";
import "./globals.css";

const inter = Inter({
  subsets: ["latin"],
  variable: "--font-inter",
  display: "swap",
});

const instrumentSerif = Instrument_Serif({
  weight: "400",
  subsets: ["latin"],
  variable: "--font-instrument-serif",
  display: "swap",
  style: ["normal", "italic"],
});

export const metadata: Metadata = {
  title: "FlowDown - AI That Works Even Without Us",
  description:
    "You can OWN a blazing fast and smooth Agent app. Switch between your AI services or use local models on your device.",
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
    "FlowDown",
    "Agent",
    "Swift",
    "Apple Silicon",
  ],
  authors: [{ name: "FlowDown Team" }],
  openGraph: {
    title: "FlowDown - AI That Works Even Without Us",
    description:
      "You can OWN a blazing fast and smooth Agent app. Switch between your AI services or use local models on your device.",
    type: "website",
    locale: "en_US",
  },
  twitter: {
    card: "summary_large_image",
    title: "FlowDown - AI That Works Even Without Us",
    description:
      "You can OWN a blazing fast and smooth Agent app. Switch between your AI services or use local models on your device.",
  },
  robots: {
    index: true,
    follow: true,
  },
};

export const viewport: Viewport = {
  width: "device-width",
  initialScale: 1,
  themeColor: "#f6f6f6",
};

export default function RootLayout({
  children,
}: Readonly<{
  children: React.ReactNode;
}>) {
  return (
    <html
      lang="en"
      suppressHydrationWarning
      className={`${inter.variable} ${instrumentSerif.variable}`}
    >
      <body className="min-h-screen antialiased">{children}</body>
    </html>
  );
}
