#!/bin/bash

# Orsted Template Structure Updater
# Updates existing .orsted files to match new template structure
# Intelligently merges new sections while preserving existing content

set -e

TEMPLATE_FILE="$1"
TARGET_FILE="$2"

if [ -z "$TEMPLATE_FILE" ] || [ -z "$TARGET_FILE" ]; then
    echo "Usage: $0 <template_file> <target_file>"
    echo "Example: $0 ~/.cursor/orsted-templates/full_context.md.template .orsted/full_context.md"
    exit 1
fi

if [ ! -f "$TEMPLATE_FILE" ]; then
    echo "Error: Template file not found: $TEMPLATE_FILE"
    exit 1
fi

if [ ! -f "$TARGET_FILE" ]; then
    echo "Error: Target file not found: $TARGET_FILE"
    exit 1
fi

# Create backup
cp "$TARGET_FILE" "${TARGET_FILE}.backup"
echo "Backup created: ${TARGET_FILE}.backup"

# Extract sections from template
TEMPLATE_SECTIONS=$(grep -E "^## " "$TEMPLATE_FILE" | sed 's/^## //')

# Extract sections from existing file
EXISTING_SECTIONS=$(grep -E "^## " "$TARGET_FILE" | sed 's/^## //')

echo ""
echo "Template sections:"
echo "$TEMPLATE_SECTIONS" | sed 's/^/  - /'
echo ""
echo "Existing sections:"
echo "$EXISTING_SECTIONS" | sed 's/^/  - /'
echo ""

# Check for new sections in template
NEW_SECTIONS=""
while IFS= read -r section; do
    if ! echo "$EXISTING_SECTIONS" | grep -q "^${section}$"; then
        NEW_SECTIONS="${NEW_SECTIONS}${section}\n"
    fi
done <<< "$TEMPLATE_SECTIONS"

if [ -n "$NEW_SECTIONS" ]; then
    echo "New sections found in template:"
    echo -e "$NEW_SECTIONS" | sed 's/^/  + /'
    echo ""
    echo "These sections will be added to your file."
    echo "Review the backup if needed: ${TARGET_FILE}.backup"
else
    echo "No new sections found. File structure matches template."
fi

# For now, preserve existing file
# TODO: Implement smart merging that:
# 1. Adds new sections from template
# 2. Preserves existing content
# 3. Updates section order if needed
# 4. Merges metadata (dates, etc.)

echo ""
echo "Note: This is a preview. Actual merging logic needs to be implemented."
echo "For now, manually compare:"
echo "  Template: $TEMPLATE_FILE"
echo "  Existing: $TARGET_FILE"
echo "  Backup:   ${TARGET_FILE}.backup"
