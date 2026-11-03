import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  /* config options here */
  // Necesario en desarrollo: el servidor corre en el VPS y se accede desde
  // fuera a través de Nginx con este dominio, no desde localhost.
  allowedDevOrigins: ["visionhub.juncopineiro.com"],
  // Desactivado: todas las páginas dependen de la sesión del usuario
  // (nada es realmente estático), así que esta función experimental de
  // Next.js 16 solo añadía complejidad sin aportar nada todavía.
  cacheComponents: false,
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
