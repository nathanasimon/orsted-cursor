#!/bin/bash

# Orsted Installation Script
# Installs Orsted hooks and templates to ~/.cursor/

set -e

echo "Orsted Installation"
echo "======================"
echo ""

# Check if Cursor directory exists
if [ ! -d "$HOME/.cursor" ]; then
    echo "Creating ~/.cursor directory..."
    mkdir -p "$HOME/.cursor"
fi

# Create hooks directory
echo "Creating hooks directory..."
mkdir -p "$HOME/.cursor/hooks"

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Copy hook scripts
echo "Installing hook scripts..."
if [ -f "$SCRIPT_DIR/hooks/orsted_before_prompt.sh" ]; then
    cp "$SCRIPT_DIR/hooks/orsted_before_prompt.sh" "$HOME/.cursor/hooks/"
    chmod +x "$HOME/.cursor/hooks/orsted_before_prompt.sh"
fi
if [ -f "$SCRIPT_DIR/hooks/orsted_file_edit.sh" ]; then
    cp "$SCRIPT_DIR/hooks/orsted_file_edit.sh" "$HOME/.cursor/hooks/"
    chmod +x "$HOME/.cursor/hooks/orsted_file_edit.sh"
fi
if [ -f "$SCRIPT_DIR/hooks/orsted_after_response.sh" ]; then
    cp "$SCRIPT_DIR/hooks/orsted_after_response.sh" "$HOME/.cursor/hooks/"
    chmod +x "$HOME/.cursor/hooks/orsted_after_response.sh"
fi

# Copy test script if it exists
if [ -f "$SCRIPT_DIR/scripts/test.sh" ]; then
    cp "$SCRIPT_DIR/scripts/test.sh" "$HOME/.cursor/hooks/orsted_test.sh"
    chmod +x "$HOME/.cursor/hooks/orsted_test.sh"
    echo "Test script installed: ~/.cursor/hooks/orsted_test.sh"
fi

# Copy init script if it exists
if [ -f "$SCRIPT_DIR/scripts/init.sh" ]; then
    cp "$SCRIPT_DIR/scripts/init.sh" "$HOME/.cursor/hooks/orsted_init.sh"
    chmod +x "$HOME/.cursor/hooks/orsted_init.sh"
    echo "Init script installed: ~/.cursor/hooks/orsted_init.sh"
fi

# Copy update script if it exists
if [ -f "$SCRIPT_DIR/scripts/update.sh" ]; then
    cp "$SCRIPT_DIR/scripts/update.sh" "$HOME/.cursor/hooks/orsted_update.sh"
    chmod +x "$HOME/.cursor/hooks/orsted_update.sh"
    echo "Update script installed: ~/.cursor/hooks/orsted_update.sh"
fi

# Install Cursor commands
echo "Installing Cursor commands..."
mkdir -p "$HOME/.cursor/commands"
if [ -f "$SCRIPT_DIR/scripts/orsted-test.md" ]; then
    cp "$SCRIPT_DIR/scripts/orsted-test.md" "$HOME/.cursor/commands/orsted-test.md"
    echo "Cursor command installed: ~/.cursor/commands/orsted-test.md"
fi
if [ -f "$SCRIPT_DIR/scripts/orsted-init.md" ]; then
    cp "$SCRIPT_DIR/scripts/orsted-init.md" "$HOME/.cursor/commands/orsted-init.md"
    echo "Cursor command installed: ~/.cursor/commands/orsted-init.md"
fi
if [ -f "$SCRIPT_DIR/scripts/orsted-update.md" ]; then
    cp "$SCRIPT_DIR/scripts/orsted-update.md" "$HOME/.cursor/commands/orsted-update.md"
    echo "Cursor command installed: ~/.cursor/commands/orsted-update.md"
fi
if [ ! -f "$HOME/.cursor/commands/orsted-test.md" ]; then
    # Create a basic command file if template doesn't exist
    cat > "$HOME/.cursor/commands/orsted-test.md" << 'EOF'
# Orsted Test

Run a comprehensive test to verify Orsted is installed and working correctly.

## What This Does

1. Checks if all hook scripts are installed and executable
2. Validates hooks.json configuration
3. Verifies templates are available
4. Checks dependencies (jq)
5. Scans current workspace for .orsted folders

## Usage

Run this command and review the test results. If all tests pass, Orsted should be working correctly.

## Manual Test

After running this test, try:
1. Edit a file in any directory
2. Submit a prompt to the AI
3. Check if `.orsted/` folder was created/updated in that directory
EOF
    echo "Cursor command created: ~/.cursor/commands/orsted-test.md"
fi

# Install hooks.json
echo "Installing hooks configuration..."
if [ -f "$SCRIPT_DIR/hooks/hooks.json" ]; then
    cp "$SCRIPT_DIR/hooks/hooks.json" "$HOME/.cursor/hooks.json"
else
    echo "Warning: hooks.json not found, creating default..."
    cat > "$HOME/.cursor/hooks.json" << EOF
{
  "version": 1,
  "hooks": {
    "beforeSubmitPrompt": [
      {
        "command": "~/.cursor/hooks/orsted_before_prompt.sh"
      }
    ],
    "afterFileEdit": [
      {
        "command": "~/.cursor/hooks/orsted_file_edit.sh"
      }
    ],
    "afterAgentResponse": [
      {
        "command": "~/.cursor/hooks/orsted_after_response.sh"
      }
    ]
  }
}
EOF
fi

# Copy templates to a templates directory (for reference)
echo "Installing templates..."
mkdir -p "$HOME/.cursor/orsted-templates"
if [ -d "$SCRIPT_DIR/templates" ]; then
    cp "$SCRIPT_DIR/templates"/*.template "$HOME/.cursor/orsted-templates/" 2>/dev/null || true
fi

echo ""
echo "✅ Orsted installed successfully!"
echo ""
echo "Next steps:"
echo "1. Restart Cursor for hooks to take effect"
echo "2. Copy .cursorrules to your project root (optional)"
echo "3. Copy templates from ~/.cursor/orsted-templates/ to your project's .orsted/ folder"
echo ""
echo "For more information, see README.md"
