// Registro de actividad (tabla AuditEvent). Todo lo importante
// (login, publicación, reproducción, error...) deja aquí una línea.
//
// recordEvent NUNCA lanza error: si el registro falla, se anota en el log
// y la acción del usuario sigue adelante. Mismo patrón que Queue Hub.

import { prisma } from "@/lib/prisma";

export type AuditInput = {
  type: string;
  actorId?: string | null;
  payload?: Record<string, unknown>;
  ip?: string | null;
};

export async function recordEvent(e: AuditInput): Promise<void> {
  try {
    await prisma.auditEvent.create({
      data: {
        type: e.type,
        actorId: e.actorId ?? null,
        payload: e.payload,
        ip: e.ip ?? null,
      },
    });
  } catch (err) {
    console.error("[audit] no se pudo registrar el evento", e.type, err);
  }
}
