#!/bin/bash

# Orsted: Capture user prompt before it's processed
# Also auto-initializes workspace root .orsted folder on first use

INPUT=$(cat)

# Extract prompt, workspace root, and conversation_id
if command -v jq >/dev/null 2>&1; then
  PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')
  WORKSPACE_ROOT=$(echo "$INPUT" | jq -r '.workspace_roots[0] // empty')
  CONV_ID=$(echo "$INPUT" | jq -r '.conversation_id // "current"' | tr -d '/')
else
  PROMPT=$(echo "$INPUT" | awk -F'"prompt":' '{print $2}' | awk -F'"' '{print $2}')
  WORKSPACE_ROOT=$(echo "$INPUT" | awk -F'"workspace_roots":' '{print $2}' | awk -F'"' '{print $2}')
  CONV_ID=$(echo "$INPUT" | awk -F'"conversation_id":' '{print $2}' | awk -F'"' '{print $2}' | tr -d '/')
fi

if [ -z "$WORKSPACE_ROOT" ] || [ ! -d "$WORKSPACE_ROOT" ]; then
  WORKSPACE_ROOT="${PWD:-$HOME}"
fi

if [ -n "$PROMPT" ] && [ -n "$CONV_ID" ]; then
  # Store prompt in temp file
  PROMPT_FILE="/tmp/orsted_prompt_${CONV_ID}.txt"
  echo "$PROMPT" > "$PROMPT_FILE"
fi

# Auto-initialize workspace root .orsted folder on first use
ORSTED_DIR="$WORKSPACE_ROOT/.orsted"
if [ ! -d "$ORSTED_DIR" ] && [ -d "$WORKSPACE_ROOT" ]; then
  # First time in this workspace - initialize .orsted
  mkdir -p "$ORSTED_DIR"
  
  # Copy templates or create default files
  TEMPLATE_DIR="$HOME/.cursor/orsted-templates"
  TODAY=$(date +%Y-%m-%d)
  
  if [ -d "$TEMPLATE_DIR" ]; then
    for template in "$TEMPLATE_DIR"/*.template; do
      if [ -f "$template" ]; then
        basename="${template%.template}"
        target_name=$(basename "$basename")
        sed "s/YYYY-MM-DD/$TODAY/g" "$template" > "$ORSTED_DIR/$target_name" 2>/dev/null || true
      fi
    done
  fi
  
  # If no templates, create minimal claude.md
  if [ ! -f "$ORSTED_DIR/claude.md" ]; then
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
| ${TODAY} | Initialized Orsted | Project setup |

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
fi

# Always allow the prompt to proceed
echo '{"continue": true}'
