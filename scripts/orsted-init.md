# Orsted Init

Initialize Orsted in the current workspace.

## What This Does

Creates `.orsted/` folder with all context files in the current workspace root.

## Usage

Run this command if `.orsted` doesn't exist after installing hooks, or to manually initialize Orsted in a workspace.

## What Gets Created

- `claude.md` - Working memory
- `project_info.md` - Project overview
- `critical_mistakes.md` - Error tracking
- `full_context.md` - Complete audit trail

## Manual Alternative

You can also run from terminal:
```bash
~/.cursor/hooks/orsted_init.sh /path/to/workspace
```
