import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Enable MDX pages
  pageExtensions: ["js", "jsx", "md", "mdx", "ts", "tsx"],

  // Image optimization
  images: {
    remotePatterns: [
      {
        protocol: "https",
        hostname: "**",
      },
    ],
  },

  // Disable turbopack for MDX compatibility
  // MDX plugins are processed via next-mdx-remote in page components
};

export default nextConfig;
