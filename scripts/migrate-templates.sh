#!/bin/bash

# Orsted Template Migration Script
# Safely updates existing .orsted files to match new template structure
# Preserves all existing data

set -e

WORKSPACE="${1:-$PWD}"
TEMPLATE_DIR="$HOME/.cursor/orsted-templates"

if [ ! -d "$WORKSPACE" ]; then
    echo "Error: Directory does not exist: $WORKSPACE"
    exit 1
fi

if [ ! -d "$TEMPLATE_DIR" ]; then
    echo "Error: Templates not found at $TEMPLATE_DIR"
    echo "Run install.sh first to install templates."
    exit 1
fi

echo "Orsted Template Migration"
echo "========================"
echo ""
echo "Workspace: $WORKSPACE"
echo ""

# Find all .orsted directories
ORSTED_DIRS=$(find "$WORKSPACE" -type d -name ".orsted" 2>/dev/null)

if [ -z "$ORSTED_DIRS" ]; then
    echo "No .orsted folders found in $WORKSPACE"
    exit 0
fi

echo "Found $(echo "$ORSTED_DIRS" | wc -l | tr -d ' ') .orsted folder(s)"
echo ""

for ORSTED_DIR in $ORSTED_DIRS; do
    echo "Processing: $ORSTED_DIR"
    
    # For each template file
    for template_file in "$TEMPLATE_DIR"/*.template; do
        if [ ! -f "$template_file" ]; then
            continue
        fi
        
        template_name=$(basename "$template_file" .template)
        target_file="$ORSTED_DIR/${template_name}.md"
        
        if [ ! -f "$target_file" ]; then
            # File doesn't exist - create from template
            TODAY=$(date +%Y-%m-%d)
            sed "s/YYYY-MM-DD/$TODAY/g" "$template_file" > "$target_file"
            echo "  ✓ Created ${template_name}.md (new file)"
        else
            # File exists - check if migration needed
            # For now, we'll preserve existing files and just note them
            echo "  - ${template_name}.md exists (preserved)"
            
            # TODO: Add smart merging logic here
            # - Compare structure
            # - Merge new sections
            # - Preserve existing content
        fi
    done
    
    echo ""
done

echo "✓ Migration complete!"
echo ""
echo "Note: Existing files were preserved. To update structure:"
echo "1. Backup your .orsted folders"
echo "2. Review template changes"
echo "3. Manually merge new sections if needed"
