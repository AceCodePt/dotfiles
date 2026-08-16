import { type Plugin } from "@opencode-ai/plugin";
import { type Event } from "@opencode-ai/sdk";

const PHONE_USER = "u0_a409";
const PHONE_PORT = "8022";
const PHONE_HOST = "galaxy-s24-ultra";

const OMARCHY_USER = "sagi";
const OMARCHY_PORT = "22";
const OMARCHY_HOST = "omarchy";

const SOUNDS = {
  permission: "/usr/share/sounds/freedesktop/stereo/message-new-instant.oga",
  done: "/usr/share/sounds/freedesktop/stereo/complete.oga",
} as const;

type Peer = { ip: string | null; online: boolean };

type Shell = {
  (strings: TemplateStringsArray, ...expr: unknown[]): Shell;
  quiet(): Shell;
  nothrow(): Shell;
  text(encoding?: BufferEncoding): Promise<string>;
};

async function resolvePeers($: Shell): Promise<Map<string, Peer>> {
  const out = new Map<string, Peer>();
  try {
    const text = await $`tailscale status --json`.quiet().nothrow().text();
    const parsed = JSON.parse(text);
    for (const peer of Object.values(parsed.Peer ?? {})) {
      const p = peer as {
        DNSName: string;
        TailscaleIPs?: string[];
        Online?: boolean;
      };
      const name = (p.DNSName || "").split(".")[0];
      if (!name) {
        continue;
      }
      out.set(name, {
        ip: Array.isArray(p.TailscaleIPs) && p.TailscaleIPs.length
          ? p.TailscaleIPs[0]
          : null,
        online: !!p.Online,
      });
    }
  } catch {
    // tailscale unavailable: no targets to notify
  }
  return out;
}

export const NotificationPlugin: Plugin = async ({ $, directory, client }) => {
  const esc = (s: string) => s.replace(/["\\]/g, "\\$&");

  const notify = async (message: string, color: string, sound: string) => {
    const folder = directory.split("/").at(-1)!;
    const label = folder && folder !== "." ? folder : "opencode";
    const text = `${label}: ${message}`;
    const peers = await resolvePeers($);

    const phone = peers.get(PHONE_HOST);
    if (phone?.online && phone.ip) {
      const termux = `termux-notification --title "OpenCode" --content "${esc(text)}" --sound`;
      const remote = `export XDG_RUNTIME_DIR=/run/user/$(id -u); if [ -x /data/data/com.termux/files/usr/bin/termux-notification ]; then ${termux}; fi`;
      $`ssh -p ${PHONE_PORT} -o BatchMode=yes -o ConnectTimeout=3 ${PHONE_USER}@${phone.ip} ${remote}`
        .quiet().nothrow().catch(() => {});
    }

    const omarchy = peers.get(OMARCHY_HOST);
    if (omarchy?.online && omarchy.ip) {
      const remote =
        `export XDG_RUNTIME_DIR=/run/user/$(id -u); ` +
        `if command -v notify-send >/dev/null 2>&1; then ` +
        `notify-send "OpenCode" "${esc(text)}"; ` +
        `else echo "${esc(text)}" >> ~/.orch-notifications.log; fi`;
      $`ssh -p ${OMARCHY_PORT} -o BatchMode=yes -o ConnectTimeout=3 ${OMARCHY_USER}@${omarchy.ip} ${remote}`
        .quiet().nothrow().catch(() => {});
    }
  };

  return {
    event: async ({
      event,
    }: {
      event:
        | Event
        | {
            type: "permission.asked";
            properties: { sessionID: string };
          };
    }) => {
      if (event.type !== "permission.asked" && event.type !== "session.idle") {
        return;
      }

      // Fetch the session details to check if it belongs to a subagent
      const sessionId = event.properties.sessionID;
      let isSubagent = false;
      try {
        const session = await client.session.get({ path: { id: sessionId } });
        isSubagent = !!session.data?.parentID;
      } catch {
        // Fail gracefully if the session data can't be fetched
        return;
      }

      const folder = directory.split("/").at(-1)!;
      const label = folder && folder !== "." ? folder : "opencode";

      // Notify when the AI is waiting for your permission
      if (event.type === "permission.asked") {
        await notify(`Permission Required in ${label}`, "rgb(ff5555)", SOUNDS.permission);
        return;
      }

      // Notify on session completion
      if (!isSubagent) {
        await notify(`${label} task done!`, "rgb(50fa7b)", SOUNDS.done);
      }
    },
  };
};