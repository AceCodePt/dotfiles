# Lazygit Scripts

Custom scripts for lazygit workflows.

## `delete-branch-with-worktree`

Deletes a git branch and its associated worktree with optional project-specific cleanup.

### Usage

Configured in `~/.config/lazygit/config.yml` to run when pressing `D` on a branch.

### What it does

1. **Runs pre-branch-delete hook** - Calls `<project-root>/hooks/pre-branch-delete` if it exists
2. **Removes worktree** - Automatically detects and removes the worktree for the branch
3. **Deletes the branch** - Removes the git branch
4. **Runs post-branch-delete hook** - Calls `<project-root>/hooks/post-branch-delete` if it exists

### Project-specific hooks

#### Pre-delete hook (cleanup before deletion)

Create: `<project-root>/hooks/pre-branch-delete`

**Use for:** Database cleanup, resource deallocation, etc.

**Environment variables provided:**

- `BRANCH_NAME` - The branch being deleted
- `WORKTREE_PATH` - Path to the worktree (if found)

**Example:**

```bash
#!/bin/bash
# hooks/pre-branch-delete

# Delete task-specific database
DB_NAME="myproject_${BRANCH_NAME//-/_}"
docker exec postgres psql -U postgres -c "DROP DATABASE ${DB_NAME};"
```

#### Post-delete hook (tasks after deletion)

Create: `<project-root>/hooks/post-branch-delete`

**Use for:** Notifications, logging, cleanup verification, etc.

**Environment variables provided:**

- `BRANCH_NAME` - The branch that was deleted
- `WORKTREE_PATH` - Path where the worktree was (now removed)

**Example:**

```bash
#!/bin/bash
# hooks/post-branch-delete

# Log the deletion
echo "$(date): Deleted branch $BRANCH_NAME" >> .git/branch-deletions.log
```

### Benefits

- **Simple** - One script, no complex hook system
- **Generic** - Works with any git repository
- **Extensible** - Add project-specific cleanup via hooks
- **Clean** - Handles worktree removal automatically
