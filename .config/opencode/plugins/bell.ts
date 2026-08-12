import { type Plugin } from "@opencode-ai/plugin";
import { type Event } from "@opencode-ai/sdk";

export const NotificationPlugin: Plugin = async ({ $, directory, client }) => {
  const clientIp = process.env.SSH_CLIENT?.split(" ")[0];
  const notify = (cmd: string) => {
    const remotePrefix =
      "export XDG_RUNTIME_DIR=/run/user/$(id -u) && HYPRLAND_INSTANCE_SIGNATURE=$(ls /run/user/$(id -u)/hypr 2>/dev/null | head -n1) ";
    const full = clientIp ? remotePrefix + cmd : cmd;
    const run = clientIp ? $`ssh ${clientIp} ${full}` : $`sh -c ${full}`;
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

      // 1. Extract the session ID from the event payload
      const sessionId = event.properties.sessionID;
      let isSubagent = false;
      // 2. Fetch the session details to verify its origin directory
      try {
        const session = await client.session.get({ path: { id: sessionId } });
        isSubagent = !!session.data?.parentID;
      } catch (error) {
        // Fail gracefully if the session data can't be fetched (e.g., it was just deleted)
        return;
      }


      const folder = directory.split("/").at(-1)!;
      const label = clientIp ? `ssh:${folder}` : folder;

      // 3. Notify when the AI is waiting for your permission
      if (event.type === "permission.asked") {
        notify(`hyprctl notify 1 10000 "rgb(ff5555)" "fontsize:35 OpenCode: Permission Required in ${label}" && paplay /usr/share/sounds/freedesktop/stereo/message-new-instant.oga`);
      }

      // 4. Notify on session completion
      if (event.type === "session.idle" && !isSubagent) {
        notify(`hyprctl notify 1 10000 "rgb(50fa7b)" "fontsize:35 OpenCode: ${label} task done!" && paplay /usr/share/sounds/freedesktop/stereo/complete.oga`);
      }
    },
  };
};
