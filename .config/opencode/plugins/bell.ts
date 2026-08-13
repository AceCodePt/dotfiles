import { type Plugin } from "@opencode-ai/plugin";
import { type Event } from "@opencode-ai/sdk";

const REMOTE_TARGET = "u0_a409@100.99.127.99";
const REMOTE_PORT = "8022";
const TERMUX_BIN = "/data/data/com.termux/files/usr/bin/termux-notification";

const SOUNDS = {
  permission: "/usr/share/sounds/freedesktop/stereo/message-new-instant.oga",
  done: "/usr/share/sounds/freedesktop/stereo/complete.oga",
} as const;

export const NotificationPlugin: Plugin = async ({ $, directory, client }) => {
  const isRemote = !!process.env.SSH_CLIENT;

  const notify = (message: string, color: string, sound: string) => {
    const esc = (s: string) => s.replace(/["\\]/g, "\\$&");
    const termux = `termux-notification --title "OpenCode" --content "${esc(message)}" --sound`;
    const hyprland = `HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/$(id -u)/hypr 2>/dev/null | head -n1) hyprctl notify 1 10000 "${color}" "fontsize:35 OpenCode: ${esc(message)}" && paplay ${sound}`;
    const script = `export XDG_RUNTIME_DIR=/run/user/$(id -u); if [ -x ${TERMUX_BIN} ]; then ${termux}; else ${hyprland}; fi`;
    const run = isRemote
      ? $`ssh -p ${REMOTE_PORT} -o BatchMode=yes -o ConnectTimeout=3 ${REMOTE_TARGET} ${script}`
      : $`sh -c ${script}`;
    return run.quiet().nothrow().catch(() => {});
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
      const label = isRemote ? `ssh:${folder}` : folder;

      // Notify when the AI is waiting for your permission
      if (event.type === "permission.asked") {
        notify(
          `Permission Required in ${label}`,
          "rgb(ff5555)",
          SOUNDS.permission,
        );
        return;
      }

      // Notify on session completion
      if (!isSubagent) {
        notify(`${label} task done!`, "rgb(50fa7b)", SOUNDS.done);
      }
    },
  };
};
