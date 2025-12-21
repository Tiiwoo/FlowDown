import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Enable static exports for Vercel optimization
  // output: 'export', // Uncomment for static export if needed

  // Image optimization
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "**",
      },
    ],
  },
};

export default nextConfig;

