"use client";

import { useEffect, useRef, useState } from "react";

// Hito 1: solo comprobar que la cámara funciona en directo. Sin IA,
// sin overlays, sin guardado — eso llega en hitos posteriores.
export default function CameraPage() {
  const videoRef = useRef<HTMLVideoElement>(null);
  const [error, setError] = useState<string | null>(null);
  const [ready, setReady] = useState(false);

  useEffect(() => {
    let stream: MediaStream | null = null;

    async function start() {
      try {
        stream = await navigator.mediaDevices.getUserMedia({
          video: { facingMode: "environment" },
          audio: false,
        });
        if (videoRef.current) {
          videoRef.current.srcObject = stream;
          setReady(true);
        }
      } catch {
        setError(
          "No se pudo acceder a la cámara. Comprueba los permisos del navegador."
        );
      }
    }

    start();

    return () => {
      stream?.getTracks().forEach((track) => track.stop());
    };
  }, []);

  return (
    <main className="flex min-h-screen flex-col items-center justify-center gap-4 p-4">
      <h1 className="text-lg font-semibold">Inspección — vista de cámara</h1>
      {error && <p className="text-sm text-red-600">{error}</p>}
      <video
        ref={videoRef}
        autoPlay
        playsInline
        muted
        className="max-h-[80vh] w-full max-w-md rounded bg-black"
      />
      {!error && !ready && <p className="text-sm text-gray-500">Abriendo cámara…</p>}
    </main>
  );
}
