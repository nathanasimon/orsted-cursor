# Orsted for Cursor

**Persistent context system for Cursor IDE** — automatically tracks what you do, why you did it, and what failed.

## Quick Install

```bash
git clone https://github.com/nathanasimon/orsted.git
cd orsted/cursor
chmod +x install.sh
./install.sh
```

Then **restart Cursor**.

## What It Does

Orsted creates a `.orsted/` folder in each directory where you work, containing:

- **`claude.md`** — Working memory (current focus, work log, decisions)
- **`project_info.md`** — Project overview (tech stack, structure, conventions)
- **`critical_mistakes.md`** — Error prevention (learn from mistakes)
- **`full_context.md`** — Complete audit trail (auto-updated, rarely read)

All files update automatically after every agent response. No manual work required.

## How It Works

Uses Cursor's hook system:
1. **`beforeSubmitPrompt` hook** — Captures your request
2. **`afterFileEdit` hook** — Tracks which files were edited
3. **`afterAgentResponse` hook** — Updates `.orsted/` files automatically

Everything runs silently in the background. No notifications, no interruptions.

## Requirements

- **Cursor IDE** (not Claude Code)
- Bash shell
- `jq` (optional, for better JSON parsing)

## Installation

See `INSTALL.md` for detailed instructions.

## Uninstall

```bash
rm -rf ~/.cursor/hooks/orsted*.sh
rm -f ~/.cursor/hooks.json
rm -rf ~/.cursor/orsted-templates
```

## For Claude Code Users

If you're using **Claude Code** (not Cursor), see the `../orsted-claude-code/` directory.
