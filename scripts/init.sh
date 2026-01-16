#!/bin/bash
# orsted_init.sh - Manually initialize .orsted in a directory

TARGET_DIR="${1:-$PWD}"
ORSTED_DIR="$TARGET_DIR/.orsted"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Error: Directory does not exist: $TARGET_DIR"
    exit 1
fi

if [ -d "$ORSTED_DIR" ]; then
    echo "✓ .orsted already exists in $TARGET_DIR"
    exit 0
fi

mkdir -p "$ORSTED_DIR"

# Create default files from templates
TEMPLATE_DIR="$HOME/.cursor/orsted-templates"
TODAY=$(date +%Y-%m-%d)

if [ -d "$TEMPLATE_DIR" ]; then
    for template in claude project_info critical_mistakes full_context; do
        if [ -f "$TEMPLATE_DIR/${template}.md.template" ]; then
            sed "s/YYYY-MM-DD/$TODAY/g" "$TEMPLATE_DIR/${template}.md.template" > "$ORSTED_DIR/${template}.md"
            echo "  ✓ Created ${template}.md"
        fi
    done
else
    echo "Warning: Templates not found at $TEMPLATE_DIR"
    echo "Creating minimal claude.md..."
    cat > "$ORSTED_DIR/claude.md" << EOF
# Session Context

> **Last updated:** ${TODAY}  
> **Status:** [IN-PROGRESS]

## Current Focus
None yet.

---

## Work Log

| Date | What | Why |
|------|------|-----|
| ${TODAY} | Initialized Orsted | Manual initialization |

---

## Active Decisions

| Decision | Reasoning | Alternatives Considered |
|----------|-----------|------------------------|
| — | — | — |

---

## What Failed

> None yet.

---

## Blockers

None.

---

## Next Up

1. —

---

_This file is the AI's working memory. Update it every session._
EOF
fi

echo ""
echo "✓ Initialized .orsted in $TARGET_DIR"
echo ""
ls -la "$ORSTED_DIR"
