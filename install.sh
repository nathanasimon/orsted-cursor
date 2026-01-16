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

# Install Cursor command for testing
echo "Installing Cursor command..."
mkdir -p "$HOME/.cursor/commands"
if [ -f "$SCRIPT_DIR/scripts/orsted-test.md" ]; then
    cp "$SCRIPT_DIR/scripts/orsted-test.md" "$HOME/.cursor/commands/orsted-test.md"
    echo "Cursor command installed: ~/.cursor/commands/orsted-test.md"
elif [ -f "$SCRIPT_DIR/../orsted-cursor-repo/scripts/orsted-test.md" ]; then
    # Fallback: check if command file exists in repo
    cp "$SCRIPT_DIR/../orsted-cursor-repo/scripts/orsted-test.md" "$HOME/.cursor/commands/orsted-test.md" 2>/dev/null || true
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
