import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  // Necesario en desarrollo: el servidor corre en el VPS y se accede desde
  // fuera a través de Nginx con este dominio, no desde localhost.
  allowedDevOrigins: ["visionhub.juncopineiro.com"],
  cacheComponents: true,
  partialPrefetching: true,
  turbopack: {
    rules: {
      "*.css": {
        loaders: ["@tailwindcss/turbopack"],
        as: "*.css",
      },
    },
  },
};

export default nextConfig;
