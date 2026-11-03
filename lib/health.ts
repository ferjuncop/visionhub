import { prisma } from "@/lib/prisma";

export type HealthResult = { ok: boolean; database: boolean; error?: string };

export async function checkHealth(): Promise<HealthResult> {
  try {
    await prisma.$queryRaw`SELECT 1`;
    return { ok: true, database: true };
  } catch (err) {
    return { ok: false, database: false, error: (err as Error).message };
  }
}
