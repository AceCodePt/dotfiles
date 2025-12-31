export const NotificationPlugin = async ({ project, client, $, directory, worktree }) => {
  return {
    event: async ({ event }) => {
      // Send notification on session completion
      if (event.type === "session.idle") {
        await $`hyprctl notify 1 10000 0 "fontsize:35 OpenCode task done\!" && paplay /usr/share/sounds/freedesktop/stereo/complete.oga`
      }
    },
  }
}
