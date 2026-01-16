# Orsted for Cursor

**Persistent context system for Cursor IDE** — automatically tracks what you do, why you did it, and what failed.

## Installation

### Quick Install

1. **Clone the repository:**
   ```bash
   git clone https://github.com/nathanasimon/orsted-cursor.git
   cd orsted-cursor
   ```

2. **Run the install script:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. **Restart Cursor** for hooks to take effect.

That's it! Orsted will now automatically track context in your projects.

### What Gets Installed

The install script sets up:
- ✅ Hook scripts in `~/.cursor/hooks/`
- ✅ Hook configuration in `~/.cursor/hooks.json`
- ✅ Templates in `~/.cursor/orsted-templates/`
- ✅ Test script (`orsted_test.sh`)
- ✅ Cursor command (`/orsted-test`)

### Verify Installation

After installing, test that everything works:

```bash
~/.cursor/hooks/orsted_test.sh
```

Or use the Cursor command: type `/orsted-test` in chat.

### Project Setup (Optional)

To customize templates for a specific project:

1. Copy `.cursorrules` to your project root (tells AI to read `.orsted/` files)
2. Create `.orsted/` folder in project root
3. Copy templates from `~/.cursor/orsted-templates/` to `.orsted/` if you want custom templates

Orsted will work automatically without this setup, but custom templates give you more control.

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
- `jq` (optional, but recommended for better JSON parsing)

For detailed installation instructions, see [INSTALL.md](INSTALL.md).

## Testing

After installation, verify everything is working:

**Option 1: Run the test script**
```bash
~/.cursor/hooks/orsted_test.sh
```

**Option 2: Use the Cursor command**
- Type `/orsted-test` in the Cursor chat

The test verifies:
- ✓ Hook scripts are installed and executable
- ✓ hooks.json is configured correctly
- ✓ Templates are available
- ✓ Dependencies (jq) are installed
- ✓ .orsted folders exist in workspace

**Option 3: Manual test**
1. Edit a file in any directory
2. Submit a prompt to the AI
3. Check if `.orsted/` folder was created/updated

## Uninstall

```bash
rm -rf ~/.cursor/hooks/orsted*.sh
rm -f ~/.cursor/hooks.json
rm -rf ~/.cursor/orsted-templates
```

## Future Goals

### Visual Indicators
- **Discreet status indicators** — System to show users that Orsted is working (every prompt or at start)
- **Non-intrusive notifications** — Visual feedback that context is being updated without interrupting workflow
- **Status badges** — Optional indicators showing Orsted activity status

## For Claude Code Users

If you're using **Claude Code** (not Cursor), see [orsted-claude-code](https://github.com/nathanasimon/orsted-claude-code).
