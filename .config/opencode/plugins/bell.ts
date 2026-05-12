import { type Plugin } from "@opencode-ai/plugin";
import { type Event } from "@opencode-ai/sdk";

export const NotificationPlugin: Plugin = async ({ $, directory, client }) => {
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

      // 2. Fetch the session details to verify its origin directory
      try {
        const session = await client.session.get({ path: { id: sessionId } });

        // This is a subagent running because it has a parentID
        if (session.data?.parentID) {
          return;
        }
      } catch (error) {
        // Fail gracefully if the session data can't be fetched (e.g., it was just deleted)
        return;
      }

      const folder = directory.split("/").at(-1)!;

      // 3. Notify when the AI is waiting for your permission
      if (event.type === ("permission.asked" as any)) {
        await $`hyprctl notify 1 10000 "rgb(ff5555)" "fontsize:35 OpenCode: Permission Required in ${folder}" && paplay /usr/share/sounds/freedesktop/stereo/message-new-instant.oga`;
      }

      // 4. Notify on session completion (your original logic)
      if (event.type === "session.idle") {
        await $`hyprctl notify 1 10000 "rgb(50fa7b)" "fontsize:35 OpenCode: ${folder} task done!" && paplay /usr/share/sounds/freedesktop/stereo/complete.oga`;
      }
    },
  };
};
