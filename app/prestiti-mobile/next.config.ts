import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // Configure for standalone deployment
  output: 'standalone',
  
  // Allow rewrite to CAP server for API calls in development
  async rewrites() {
    return [
      {
        source: '/rest/:path*',
        destination: 'http://localhost:4004/rest/:path*',
      },
    ];
  },
};

export default nextConfig;
