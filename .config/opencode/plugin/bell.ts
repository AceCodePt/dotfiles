import { Plugin } from "@opencode-ai/plugin";

export const NotificationPlugin: Plugin = async ({ $, directory }) => {
  return {
    event: async ({ event }) => {
      const folder = directory.split("/").at(-1)!;

      // 1. Notify when the AI is waiting for your permission
      if (event.type === "permission.asked" as any) {
        await $`hyprctl notify 1 10000 "rgb(ff5555)" "fontsize:35 OpenCode: Permission Required in ${folder}" && paplay /usr/share/sounds/freedesktop/stereo/message-new-instant.oga`;
      }

      // 2. Notify on session completion (your original logic)
      if (event.type === "session.idle") {
        await $`hyprctl notify 1 10000 "rgb(50fa7b)" "fontsize:35 OpenCode: ${folder} task done!" && paplay /usr/share/sounds/freedesktop/stereo/complete.oga`;
      }
    },
  };
};
