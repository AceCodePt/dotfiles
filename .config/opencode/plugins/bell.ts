// No import: OpenCode 2 accepts a plugin as a plain default-exported
// `{ id, setup }` object, and neither `@opencode/plugin` nor `@opencode-ai/sdk`
// is resolvable from this install's config dir. Written against the raw
// context, with a small shell helper over Bun.spawn in place of V1's `$`.

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

const decoder = new TextDecoder();

// V1 injected a Bun shell (`$`); V2 does not, so run the few commands we need
// directly and never let a failure throw into the event loop.
async function run(command: string[]): Promise<string> {
  try {
    const proc = Bun.spawn(command, { stdout: "pipe", stderr: "pipe" });
    const out = await new Response(proc.stdout).text();
    await proc.exited;
    return out;
  } catch {
    return "";
  }
}

async function resolvePeers(): Promise<Map<string, Peer>> {
  const out = new Map<string, Peer>();
  const text = await run(["tailscale", "status", "--json"]);
  if (!text) {
    return out;
  }
  try {
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

export default {
  id: "bell",
  async setup(ctx: {
    location: { directory: string };
    session: { get: (input: { sessionID: string }) => Promise<any> };
    event: { subscribe: (opts?: { signal?: AbortSignal }) => AsyncIterable<any> };
  }) {
    const directory = ctx.location.directory;
    const esc = (s: string) => s.replace(/["\\]/g, "\\$&");

    const notify = async (message: string, _color: string, _sound: string) => {
      const folder = directory.split("/").at(-1)!;
      const label = folder && folder !== "." ? folder : "opencode";
      const text = `${label}: ${message}`;
      const peers = await resolvePeers();

      const phone = peers.get(PHONE_HOST);
      if (phone?.online && phone.ip) {
        const termux =
          `termux-notification --title "OpenCode" --content "${esc(text)}" --sound &`;
        const remote =
          `export XDG_RUNTIME_DIR=/run/user/$(id -u); if [ -x /data/data/com.termux/files/usr/bin/termux-notification ]; then ${termux}; fi`;
        void run([
          "ssh", "-p", PHONE_PORT, "-o", "BatchMode=yes",
          "-o", "ConnectTimeout=3", `${PHONE_USER}@${phone.ip}`, remote,
        ]);
      }

      const omarchy = peers.get(OMARCHY_HOST);
      if (omarchy?.online && omarchy.ip) {
        const remote =
          `export XDG_RUNTIME_DIR=/run/user/$(id -u); ` +
          `if command -v notify-send >/dev/null 2>&1; then ` +
          `notify-send "OpenCode" "${esc(text)}"; ` +
          `else echo "${esc(text)}" >> ~/.orch-notifications.log; fi`;
        void run([
          "ssh", "-p", OMARCHY_PORT, "-o", "BatchMode=yes",
          "-o", "ConnectTimeout=3", `${OMARCHY_USER}@${omarchy.ip}`, remote,
        ]);
      }
    };

    const controller = new AbortController();
    const handle = async (event: { type?: string; data?: { sessionID?: string } }) => {
      if (event.type !== "permission.asked" && event.type !== "session.idle") {
        return;
      }
      // V2 puts the event payload on `data`; V1 used `properties`.
      const sessionId = event.data?.sessionID;
      if (!sessionId) {
        return;
      }

      let isSubagent = false;
      try {
        const session = await ctx.session.get({ sessionID: sessionId });
        const info = session?.data ?? session;
        isSubagent = !!info?.parentID;
      } catch {
        // Fail gracefully if the session data can't be fetched
        return;
      }

      const folder = directory.split("/").at(-1)!;
      const label = folder && folder !== "." ? folder : "opencode";

      if (event.type === "permission.asked") {
        await notify(`Permission Required in ${label}`, "rgb(ff5555)", SOUNDS.permission);
        return;
      }
      if (!isSubagent) {
        await notify(`${label} task done!`, "rgb(50fa7b)", SOUNDS.done);
      }
    };

    void (async () => {
      for await (const event of ctx.event.subscribe({ signal: controller.signal })) {
        void handle(event).catch((e) => {
          console.error(decoder.decode(new TextEncoder().encode(`bell: ${e}`)));
        });
      }
    })();

    return () => controller.abort();
  },
};
