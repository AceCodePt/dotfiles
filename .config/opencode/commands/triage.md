---
description: Review the drafted task specs in tasks/ and move each to agent-ready, back to the requester, or out of scope.
---


# Triage

Incoming work arrives as **drafted task specs** — `tasks/<name>/task.md` files an `orch task draft` agent wrote but nobody has committed yet. Triage is a **review pass over that draft queue**: approve a spec so it is agent-ready, send one back for more information, or drop it.

Triage is only for work **you didn't create** — bug reports, incoming feature requests, anything that arrives raw. Slices that `orch task draft` produced from a grilling session are already agent-ready, so **don't triage them**.

Everything below reads `orch task list` for the project's task states. A spec that is not committed is **not declared** — it exists in the working tree only, which is exactly what makes it the review queue.

## Reference

- The task lifecycle is git-derived: uncommitted spec = review queue, committed spec = declared, branch exists = claimed, spec moved to `archive/` = closed.

## Roles

There are no triage labels any more. The two decisions triage makes are:

- **Agent-ready** — the committed spec is complete and `hitl` is set the way the work needs (a human-picked task keeps `hitl: true`; scheduler-eligible work is `hitl: false`). Commit it, or adjust it and commit.
- **Needs info** — the spec is missing the evidence or a decision to be actioned; it goes back to the requester, uncommitted, with the specific question.
- **Wontfix** — the work is not going to happen; the spec is deleted or moved out of the review queue.

## Invocation

The maintainer invokes `/triage` and describes what they want in natural language. Interpret the request and act. Examples:

- "Show me anything that needs my attention"
- "Let's look at the draft queue"
- "Review the `fix-auth` spec"

## Show what needs attention

Run `orch task list` (and `orch doctor`) and present the draft queue: uncommitted specs under `tasks/` that nobody has reviewed. Show them oldest first, one line each, and let the maintainer pick. Flag any spec whose `dependencies:` names a task that is neither declared nor archived — `orch doctor` already warns on those; they can never dispatch.

## Triage a specific spec

1. **Gather context.** Read the spec and its `dependencies:` edges. Explore the codebase using the project's domain glossary, respecting ADRs in the area. Run two checks: (a) **redundancy** — search for an existing implementation of the requested behavior by domain concept (not just the request's wording) and report where you looked; if found, it's already built — recommend wontfix. (b) **prior rejection** — read `.out-of-scope/*.md` if present and surface anything resembling this request.
2. **Recommend.** Tell the maintainer your recommendation — agent-ready, needs-info, or wontfix — with reasoning and a brief codebase summary, including whether it's already implemented. Wait for direction.
3. **Verify the claim.** Before any grilling, check that the claim holds up. For a bug, reproduce it from the spec's steps. Report what happened: confirmed (with code path), failed, or insufficient detail (a strong needs-info signal).
4. **Grill (if needed).** If the request needs fleshing out, run the `/grilling` and `/domain-modeling` skills together — grill it into shape a round of questions at a time, sharpening domain terms and updating `CONTEXT.md`/ADRs inline as decisions land.
5. **Apply the outcome:**
   - **Agent-ready** — review the spec, fix anything that violates the task template (a runnable Verification, no file paths, behaviour over procedure), set `hitl` correctly, then commit it. The task now shows as declared `todo`; the scheduler or `orch task start` picks it up once its dependencies are archived.
   - **Needs-info** — leave the spec uncommitted and reply to the requester with the specific gaps (use the notes section of the spec or a direct reply).
   - **Wontfix** — move the spec out of the queue (delete the `tasks/<name>/` dir or `orch task reset` if it was ever claimed). For a rejected enhancement, write `.out-of-scope/<concept>.md` recording the decision, reasoning, and the spec that requested it; point the requester at it.

## Resuming a previous session

If prior triage notes exist on the spec, read them, check whether the requester answered, and present an updated picture before continuing. Don't re-ask resolved questions.

User's arguments: $ARGUMENTS

<!-- Source: ~/.config/opencode/flows/triage/SKILL.md -->
