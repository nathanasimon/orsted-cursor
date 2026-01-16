#!/bin/bash

# Orsted Update Script
# Updates Orsted to the latest version

set -e

echo "Orsted Update"
echo "============="
echo ""

# Check if installed
if [ ! -f "$HOME/.cursor/hooks/orsted_before_prompt.sh" ]; then
    echo "Error: Orsted is not installed."
    echo ""
    echo "To install Orsted, run:"
    echo "  git clone https://github.com/nathanasimon/orsted-cursor.git"
    echo "  cd orsted-cursor"
    echo "  ./install.sh"
    exit 1
fi

# Get the directory where this script is located
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Check if we're in a git repo
if [ -d "$REPO_DIR/.git" ]; then
    echo "Updating from git repository..."
    cd "$REPO_DIR"
    
    # Check for updates
    git fetch origin
    
    LOCAL=$(git rev-parse @)
    REMOTE=$(git rev-parse @{u})
    
    if [ "$LOCAL" = "$REMOTE" ]; then
        echo "✓ Already up to date!"
        exit 0
    fi
    
    echo "New version available. Pulling latest changes..."
    git pull origin main
    
    echo ""
    echo "Reinstalling with latest version..."
    ./install.sh
    
    echo ""
    echo "✓ Orsted updated successfully!"
    echo ""
    echo "Restart Cursor for changes to take effect."
else
    echo "Not in a git repository. Manual update required."
    echo ""
    echo "To update:"
    echo "1. cd /path/to/orsted-cursor-repo"
    echo "2. git pull"
    echo "3. ./install.sh"
    exit 1
fi
