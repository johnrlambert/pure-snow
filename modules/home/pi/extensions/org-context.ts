import { execFileSync } from "node:child_process";
import * as path from "node:path";
import type { ExtensionAPI } from "@mariozechner/pi-coding-agent";

export default function (pi: ExtensionAPI) {
  pi.on("before_agent_start", async (event) => {
    try {
      const output = execFileSync(path.join(process.env.HOME || "", ".pi/agent/bin/org-context"), {
        encoding: "utf8",
      }).trim();
      if (!output) return;
      return {
        systemPrompt: `${event.systemPrompt}\n\n## Live Org Context\n${output}`,
      };
    } catch {
      return;
    }
  });
}
