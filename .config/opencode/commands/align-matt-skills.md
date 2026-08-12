---
description: Align a mattpocock/skills checkout to this opencode setup (user-invoked -> /commands, model-invoked -> skills).
---

You are aligning a checkout of Matt Pocock's skills (https://github.com/mattpocock/skills) to this repo's opencode layout.

## The rule — everything hangs on this

Read each `SKILL.md` frontmatter. One axis, no exceptions:

- `disable-model-invocation: true` -> **USER-INVOKED** flow. In opencode it becomes a `/command` the user types. Its folder lives under `flows/` (NOT a discovery path, so the model never sees it), and the model is denied access to it.
- otherwise -> **MODEL-INVOKED** skill. Stays a plain skill under `skills/` the model can reach for.

Never override the flag based on references or prose — this setup follows Matt's taxonomy exactly. A user-invoked skill is never kept model-visible, even if a model-invoked skill mentions it. The flip side: a model-invoked skill that mentions a user-invoked skill is telling the user to run that command, not loading it.

## Steps

### 1. Run the align script

Run with the bash tool (defaults: source `~/.agents/skills`, dest `~/.config/opencode`):

    python3 ~/.config/opencode/scripts/align-matt-skills.py <source> [<dest>]

The script:
- copies model-invoked folders to `<dest>/skills/<name>/`
- copies user-invoked folders to `<dest>/flows/<name>/`
- writes `<dest>/commands/<name>.md` per user-invoked skill: `description` from the SKILL.md frontmatter, full body, relative support-file links rewritten to `~/.config/opencode/flows/<name>/...`, ending with `User's arguments: $ARGUMENTS`
- sets `permission.skill[<name>] = "deny"` in `<dest>/opencode.json` for every user-invoked skill
- prints a report: counts, handoff references, and anything in `<dest>` it didn't touch

### 2. Rephrase handoffs in model-invoked skills

The script lists every place a model-invoked skill mentions a user-invoked skill. The agent cannot invoke commands, and those skills are denied — so any phrase that reads as "the agent loads / runs / hands off to `/X`" must become a recommendation to the user:

- "hand off to the `/X` skill with the specifics" -> "recommend the user run `/X`, passing on the specifics"
- "run `/X` if Y is missing" -> "tell the user to run `/X` if Y is missing"
- Mere mentions ("used by `/X`", "`/X` reads this flag", label vocabulary) stay as-is.

### 3. Verify

- every `disable-model-invocation: true` skill: folder in `flows/`, command in `commands/`, NOT in `skills/`, entry `"deny"` in `opencode.json`.
- every unflagged skill: folder in `skills/`, no command wrapper, no permission entry.
- each command wrapper's support-file links resolve under `~/.config/opencode/flows/<name>/`.
- `opencode.json` is valid JSON; nothing in it changed except the skill permissions.
- no references to `~/.agents` anywhere in the config.

Report the final counts (skills / flows / commands) and any orphan entries you chose not to delete.

User's arguments: $ARGUMENTS

<!-- Source: aligned from mattpocock/skills -->
