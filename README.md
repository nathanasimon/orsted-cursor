# Orsted for Cursor

**Persistent context system for Cursor IDE** — automatically tracks what you do, why you did it, and what failed.

## Quick Install

```bash
git clone https://github.com/nathanasimon/orsted-cursor.git
cd orsted-cursor
chmod +x install.sh
./install.sh
```

**Restart Cursor** after installation.

## What It Does

Orsted creates a `.orsted/` folder in your workspace with four context files:

- **`claude.md`** — Working memory (current focus, work log, decisions)
- **`project_info.md`** — Project overview (tech stack, structure, conventions)
- **`critical_mistakes.md`** — Error prevention (learn from mistakes)
- **`full_context.md`** — Complete audit trail (auto-updated, rarely read)

All files update automatically after every agent response. No manual work required.

## How It Works

Uses Cursor's hook system:
1. **`beforeSubmitPrompt`** — Captures your request and auto-initializes `.orsted/` on first use
2. **`afterFileEdit`** — Tracks which files were edited
3. **`afterAgentResponse`** — Updates `.orsted/` files automatically

Everything runs silently in the background.

## Requirements

- **Cursor IDE** (not Claude Code)
- Bash shell
- `jq` (optional, but recommended)

## Commands

### `/orsted-test`
Verify Orsted is installed and working correctly.

### `/orsted-init`
Manually initialize `.orsted/` folder in current workspace.

### `/orsted-update`
Update Orsted to the latest version (pulls from git and reinstalls).

## Testing

After installation, verify everything works:

```bash
~/.cursor/hooks/orsted_test.sh
```

Or use the Cursor command: type `/orsted-test` in chat.

## Updating

To update Orsted to the latest version:

**Option 1: Use the Cursor command**
- Type `/orsted-update` in chat

**Option 2: Run the update script**
```bash
~/.cursor/hooks/orsted_update.sh
```

**Option 3: Manual update**
```bash
cd /path/to/orsted-cursor-repo
git pull
./install.sh
```

Then restart Cursor.

## Uninstall

```bash
rm -rf ~/.cursor/hooks/orsted*.sh
rm -f ~/.cursor/hooks.json
rm -rf ~/.cursor/orsted-templates
rm -rf ~/.cursor/commands/orsted-*.md
```

## Future Goals

- **Discreet status indicators** — Visual feedback that Orsted is working
- **Non-intrusive notifications** — Show activity without interrupting workflow

## For Claude Code Users

If you're using **Claude Code** (not Cursor), see [orsted-claude-code](https://github.com/nathanasimon/orsted-claude-code).
