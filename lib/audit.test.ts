import { describe, it, expect, vi } from "vitest";

vi.mock("@/lib/prisma", () => ({
  prisma: { auditEvent: { create: vi.fn().mockRejectedValue(new Error("db caída")) } },
}));

import { recordEvent } from "@/lib/audit";

describe("recordEvent", () => {
  it("nunca lanza error aunque falle el guardado en base de datos", async () => {
    await expect(recordEvent({ type: "test.evento" })).resolves.toBeUndefined();
  });
});
