# Lazygit Scripts

Custom scripts for lazygit workflows.

## `delete-branch-with-worktree`

Deletes a git branch and its associated worktree with optional project-specific cleanup.

### Usage

Configured in `~/.config/lazygit/config.yml` to run when pressing `D` on a branch.

### What it does

1. **Finds and removes worktree** - Automatically detects and removes the worktree for the branch
2. **Runs project cleanup** - Calls `<project-root>/hooks/pre-branch-delete` if it exists
3. **Deletes the branch** - Removes the git branch

### Project-specific cleanup

To add custom cleanup (e.g., database deletion), create:

```bash
<project-root>/hooks/pre-branch-delete
```

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

### Benefits

- **Simple** - One script, no complex hook system
- **Generic** - Works with any git repository
- **Extensible** - Add project-specific cleanup via hooks
- **Clean** - Handles worktree removal automatically
