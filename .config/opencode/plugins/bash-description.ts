// No import: OpenCode 2 accepts a plugin as a plain default-exported
// `{ id, setup }` object, and importing `@opencode/plugin` is not resolvable on
// every install. Written against the raw context so it loads everywhere.

const SCRATCH_GUIDANCE = `Temporary and scratch work (throwaway files, quick experiments, aggressive testing) must be done inside the current worktree, for example in a scratch/ directory, and removed after use. Do not use the shared temporary directory for scratch work or aggressive testing.`;

type ToolEditor = {
  list: () => readonly { id: string; description?: string }[];
  get: (id: string) => { description?: string } | undefined;
  update: (id: string, update: (tool: { description?: string }) => void) => void;
};

export default {
  id: "bash-description",
  async setup(ctx: { tool: { transform: (cb: (editor: ToolEditor) => void) => Promise<unknown> } }) {
    // V1's `tool.definition` hook becomes a tool transform in V2. The shell
    // tool is named `shell`; V1 called it `bash`.
    await ctx.tool.transform((editor) => {
      const target = editor.get("shell") ?? editor.list().find((t) => t.id === "shell");
      if (!target) {
        return;
      }
      editor.update("shell", (tool) => {
        if (typeof tool.description !== "string") {
          return;
        }
        tool.description = tool.description
          .replace(
            /Use\s+`[^`]+`\s+for temporary work outside the workspace\.?\s*[^]*?pre-approved for external directory access\.?\s*/,
            "",
          )
          .replace(/\n{3,}/g, "\n\n");
        tool.description = `${tool.description.trim()}\n\n${SCRATCH_GUIDANCE}`;
      });
    });
  },
};
