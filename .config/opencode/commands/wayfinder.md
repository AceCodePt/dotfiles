---
description: Plan a huge chunk of work — more than one agent session can hold — as a shared map of decision tasks in the project's tasks/, and resolve them one at a time until the way to the destination is clear.
---


A loose idea has arrived — too big for one agent session, and wrapped in fog: the way from here to the **destination** isn't visible yet. Wayfinding is about finding that way, not charging at the destination. This skill charts the way as a **shared map** in the project's `tasks/`, then works its **decision tasks** — questions whose resolution is a decision, not slices of a build to execute — one at a time until the route is clear.

The destination varies per effort, and naming it is the first act of charting — it shapes every task. It might be a spec to hand off and iterate on, a decision to lock before planning starts, or a change made in place like a data-structure migration. The map is domain-agnostic — engineering work, course content, whatever fits the shape.

## Plan, don't do

Wayfinder is **planning** by default: each task resolves a decision, and the map is done when the way is clear — nothing left to decide before someone goes and does the thing. The pull to just do the work is usually the signal you've reached the edge of the map and it's time to hand off. An effort can override this in its **Notes** — carrying execution into the map itself — but absent that, produce decisions, not deliverables.

## Refer by name

Every map and task has a **name** — its `tasks/<slug>/` slug, or its title. In everything the human reads — narration, the map's Decisions-so-far — refer to it by that name, never by a bare id or number. The slug rides _inside_ the name as a link (`[<title>](~/.config/opencode/flows/wayfinder/tasks/<slug>/task.md)`), never standing in for it.

## The Map

The map is a **spec task**: `tasks/<feature>/task.md` with `hitl: true` — the anchor the effort builds around. It is **never dispatched and never "done"**; it closes by convention when all its decision tasks are archived. Its child decision tasks live at `tasks/<feature>-<slug>/task.md`, each declaring `dependencies: [<feature>]` plus the earlier tasks that genuinely gate it.

The map is an **index**, not a store. It lists the decisions made and points at the tasks that hold their detail; a decision lives in exactly one place — its task — so the map never restates it, only gists it and links.

### The map body

The whole map at low resolution, loaded once per session. Open tasks are **not** listed — they are found by `orch task list`.

```markdown
## Destination

<what reaching the end of this map looks like — the spec, decision, or change this effort is finding its way to. One or two lines; every session orients to it before choosing a task.>

## Notes

<domain; skills every session should consult; standing preferences for this effort>

## Decisions so far

<!-- the index — one line per resolved task: enough to judge relevance, then zoom the link for the detail the task holds -->

- [<resolved task title>](~/.config/opencode/flows/wayfinder/tasks/<slug>/task.md) — <one-line gist of the answer>

## Not yet specified

<!-- see "Fog of war": in-scope fog you can't yet task; graduates as the frontier advances -->

## Out of scope

<!-- see "Out of scope": work ruled beyond the destination; never graduates -->
```

### Tasks

Each decision task is a `tasks/<feature>-<slug>/task.md` file, sized to one 100K token agent session, whose body is the question. The type is a `wayfinder:<type>` marker in the task (see [Task Types](~/.config/opencode/flows/wayfinder/#task-types)):

```markdown
## Question

<the decision or investigation this task resolves>
```

A session **claims** a task by starting it — `orch task start <slug>` creates the branch that *is* the claim — **first**, before any work, so concurrent sessions skip it. An unclaimed, declared task is `todo`.

Blocking uses the `dependencies:` front matter. A task is **unblocked** when every dependency is **archived**; the **frontier** is the open, unblocked, unclaimed declared tasks — the edge of the known. The scheduler dispatches exactly that set when a project opts in; `orch task list` renders it either way.

The answer isn't part of the body — it's recorded on resolution (see [Work through the map](~/.config/opencode/flows/wayfinder/#work-through-the-map)). Assets created while resolving a task are linked from it, not pasted in.

## Task Types

Every task is either **HITL** — human in the loop, worked _with_ a human who speaks for themselves — or **AFK**, driven by the agent alone. A HITL task only resolves through that live exchange; the agent never stands in for the human's side of it (a grilling agent that answers its own questions has broken this). In `task.md` terms: HITL tasks are `hitl: true` (started by a human via `orch task start`), AFK tasks are `hitl: false` (scheduler-eligible).

- **Research** (AFK): Reading documentation, third-party APIs, or local resources like knowledge bases to surface a fact a decision waits on. Resolved by a `/research` **subagent**. Use when knowledge outside the current working directory is required.
- **Prototype** (HITL): Raise the fidelity of the discussion by making a cheap, rough, concrete artifact to react to — an outline, a rough take, a stub, or UI/logic code via the /prototype skill. Links the prototype as an asset. Use when "how should it look" or "how should it behave" is the key question.
- **Grilling** (HITL): Conversation. The default case. Always invoke the /grilling and /domain-modeling skills.
- **Task** (HITL or AFK): Manual work that must happen before a _decision_ can be made — nothing to decide, prototype, or research, but the discussion is blocked until it's done. Signing up for a service so its API can be judged, provisioning access, moving data so its shape can be seen. This is the one type that _does_ rather than decides — and it earns its place by unblocking a decision, not by delivering the destination. The agent drives it alone where it can (AFK); otherwise it hands the human a precise checklist (HITL). Resolved when the work is done; the answer records what was done and any resulting facts (credentials location, new URLs, row counts) later tasks depend on.

## Fog of war

The map is _deliberately_ incomplete: don't chart what you can't yet see. Beyond the live tasks lies the **fog of war** — the dim view of decisions and investigations you can tell are coming but can't yet pin down, because they hang on questions still open. Resolving a task clears the fog ahead of it, graduating whatever's now specifiable into fresh tasks — one at a time, until the way to the destination is clear and no tasks remain.

The map's **Not yet specified** section is where that dim view is written down: the suspected question, the area to revisit later. It's the undiscovered frontier _toward_ the destination — everything here is in scope, just not sharp enough to task. Write as loosely or as fully as the view allows; it doubles as a signpost for collaborators reading where the effort is headed.

**Fog or task?** The test is whether you can state the question precisely now — _not_ whether you can answer it now.

- **Task when** the question is already sharp — even if it's blocked and you can't act on it yet.
- **Not yet specified when** you can't yet phrase it that sharply. Don't pre-slice the fog into task-sized pieces: it's coarser than a task, and one patch may graduate into several tasks, or none, once the frontier reaches it.

**Not yet specified** excludes what's already decided (Decisions so far), what's already a live task, and what's out of scope (the next section).

## Out of scope

Fog only ever gathers _toward_ the destination. The destination fixes the scope, so work beyond it is **out of scope** — it isn't fog, and it doesn't belong in **Not yet specified**. It gets its own **Out of scope** section on the map: work you've consciously ruled out of _this_ effort. Scope, not sharpness, lands it here.

Out-of-scope work never graduates — the frontier stops at the destination — so it returns only if the destination is redrawn, and then as a fresh effort, not a resumption.

Ruling something out of scope is a scoping act, not a step on the route. When a task that already exists turns out to sit past the destination — mis-scoped in while charting, or exposed by a resolution — **reset it** (`orch task reset`, which drops the branch and worktree) and leave one line in the **Out of scope** section: the gist plus why it's out of scope. It stays out of **Decisions so far**, which records the route actually walked — a scope boundary isn't a step on it.

## Invocation

Two modes. Either way, **never resolve more than one task per session** — with the exception of research tasks.

### Chart the map

User invokes with a loose idea.

1. **Name the destination.** Run a `/grilling` and `/domain-modeling` session to pin down what this map is finding its way to — the spec, decision, or change. The destination fixes the scope, so it's settled first.
2. **Map the frontier.** Grill again, **breadth-first** this time: fan out across the whole space rather than deep on any one thread, surfacing the open decisions and the first steps takeable now. **If this surfaces no fog** — the way to the destination is already clear, the whole journey small enough for one session — you don't need a map. Stop and ask the user how they'd like to proceed.
3. **Create the map task** `tasks/<feature>/task.md` (`hitl: true`): Destination and Notes filled in, Decisions-so-far empty, the fog sketched into **Not yet specified**. Commit it.
4. **Create the tasks you can specify now** — `tasks/<feature>-<slug>/task.md` files — then wire the `dependencies:` edges in a **second pass** (names exist before edges can reference them). Wiring sorts them into the frontier and the blocked; everything you can't yet specify stays in the fog — the **Not yet specified** section. Commit them.
5. **Fire the research subagents.** For each `research` task you just created, spin up a `/research` subagent to resolve it in parallel, capturing its findings on a throwaway `research/<name>` branch with a context pointer from the task.
6. Stop — charting is one session's work; it hand-resolves nothing.

### Work through the map

User invokes with a map (a task name or slug). A task is **optional** — without one, you pick the next decision, not the user.

1. Load the **map** — the low-res view, not every task body.
2. Choose the task. If the user named one, use it. Otherwise take the first frontier task in order (`orch task list` shows it). **Claim it**: `orch task start <slug>` before any work — the branch is the claim.
3. Resolve it — **zoom as needed**: fetch the full body of any related or resolved task on demand; invoke the skills the `## Notes` block names. If in doubt, use `/grilling` and `/domain-modeling`.
4. Record the resolution: the decision lands as the task's committed deliverable (or, for a write-up, appended under the task's answer and committed), the branch is merged and the task **archived** by the gate/daemon, and the map's Decisions-so-far gains a one-line gist with a link.
5. Add newly-surfaced tasks (create-then-wire); graduate any fog the answer has made specifiable, clearing each graduated patch from **Not yet specified** so it lives only as its new task. If the answer reveals a task — this one or another — sits beyond the destination, **rule it out of scope** rather than resolving it on the route. If the decision invalidates other parts of the map, update or delete those tasks.

The user may run unblocked tasks in parallel, so expect other sessions to be editing the tasks/ tree concurrently.

User's arguments: $ARGUMENTS

<!-- Source: ~/.config/opencode/flows/wayfinder/SKILL.md -->
