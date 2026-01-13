import { Plugin } from "@opencode-ai/plugin";

export const NotificationPlugin: Plugin = async ({ $, directory }) => {
  return {
    event: async ({ event }) => {
      // Send notification on session completion
      if (event.type === "session.idle") {
        const folder = directory.split("/").at(-1)!;
        await $`hyprctl notify 1 10000 0 "fontsize:35 OpenCode ${folder} task done!" && paplay /usr/share/sounds/freedesktop/stereo/complete.oga`;
      }
    },
  };
};
