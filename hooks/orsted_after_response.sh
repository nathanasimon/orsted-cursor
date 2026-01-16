#!/bin/bash

# Orsted: Automatically update .orsted/ folder files after every agent response
# Creates structured context files in .orsted/ folder per directory

INPUT=$(cat)

# Get workspace root and conversation_id
if command -v jq >/dev/null 2>&1; then
  WORKSPACE_ROOT=$(echo "$INPUT" | jq -r '.workspace_roots[0] // empty')
  CONV_ID=$(echo "$INPUT" | jq -r '.conversation_id // "current"' | tr -d '/')
else
  WORKSPACE_ROOT=$(echo "$INPUT" | awk -F'"workspace_roots":' '{print $2}' | awk -F'"' '{print $2}')
  CONV_ID=$(echo "$INPUT" | awk -F'"conversation_id":' '{print $2}' | awk -F'"' '{print $2}' | tr -d '/')
fi

if [ -z "$WORKSPACE_ROOT" ] || [ ! -d "$WORKSPACE_ROOT" ]; then
  WORKSPACE_ROOT="${PWD:-$HOME}"
fi

if [ -z "$CONV_ID" ]; then
  CONV_ID="current"
fi

# Function to check if directory should be skipped
should_skip_directory() {
  local dir="$1"
  local dir_name=$(basename "$dir")
  
  # Always include root
  if [ "$dir" = "$WORKSPACE_ROOT" ]; then
    return 1  # Don't skip root
  fi
  
  # Skip common ignored directories
  if echo "$dir" | grep -qE "(node_modules|\.git|\.next|dist|build|target|__pycache__|\.venv|venv|\.DS_Store)"; then
    return 0  # Skip
  fi
  
  # Skip hidden directories (except .cursor, .orsted)
  if [[ "$dir_name" =~ ^\. ]] && [[ "$dir_name" != ".cursor" ]] && [[ "$dir_name" != ".orsted" ]]; then
    return 0  # Skip
  fi
  
  # Skip test/temp directories
  if echo "$dir_name" | grep -qiE "(^test|^temp|^tmp|spec|__tests__)"; then
    return 0  # Skip
  fi
  
  # Skip if directory has very few files (likely temporary)
  local file_count=$(find "$dir" -maxdepth 1 -type f 2>/dev/null | wc -l | tr -d ' ')
  if [ "$file_count" -lt 2 ]; then
    return 0  # Skip
  fi
  
  return 1  # Don't skip
}

# Find directories that had file edits
UPDATED_DIRS_FILE="/tmp/orsted_dirs_${CONV_ID}.txt"

if [ -f "$UPDATED_DIRS_FILE" ]; then
  UNIQUE_DIRS=$(cat "$UPDATED_DIRS_FILE" 2>/dev/null | sort -u)
  
  for DIR in $UNIQUE_DIRS; do
    if [ -d "$DIR" ]; then
      # Skip unnecessary directories
      if should_skip_directory "$DIR"; then
        continue
      fi
      
      Orsted_DIR="$DIR/.orsted"
      mkdir -p "$Orsted_DIR"
      TODAY=$(date +%Y-%m-%d)
      NOW=$(date +%Y-%m-%d\ %H:%M:%S)
      FOLDER_NAME=$(basename "$DIR")
      if [ "$DIR" = "$WORKSPACE_ROOT" ]; then
        FOLDER_NAME="Root"
      fi
      
      # 1. Update claude.md (standard context)
      if [ ! -f "$Orsted_DIR/claude.md" ]; then
        # Check if there's a template in project root
        TEMPLATE_FILE="$WORKSPACE_ROOT/.orsted/claude.md.template"
        if [ -f "$TEMPLATE_FILE" ]; then
          # Use template, replacing date placeholder
          TODAY=$(date +%Y-%m-%d)
          sed "s/YYYY-MM-DD/$TODAY/g" "$TEMPLATE_FILE" > "$Orsted_DIR/claude.md"
        else
          # Fallback template
          cat > "$Orsted_DIR/claude.md" << EOF
# Session Context

> **Last updated:** $(date +%Y-%m-%d)  
> **Status:** 🟡 in-progress

## Current Focus
None yet.

---

## Work Log

| Date | What | Why |
|------|------|-----|
| $(date +%Y-%m-%d) | Initialized Orsted | Project setup |

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
      
      # Add detailed work log entry to claude.md
      # Get user prompt and file details
      PROMPT_FILE="/tmp/orsted_prompt_${CONV_ID}.txt"
      USER_PROMPT=""
      if [ -f "$PROMPT_FILE" ]; then
        USER_PROMPT=$(cat "$PROMPT_FILE" 2>/dev/null | head -1 | head -c 150)
      fi
      
      EDITS_FILE="/tmp/orsted_edits_${CONV_ID}.txt"
      FILES_LIST=""
      if [ -f "$EDITS_FILE" ] && command -v jq >/dev/null 2>&1; then
        FILES_LIST=$(grep "\"file\"" "$EDITS_FILE" 2>/dev/null | jq -r '.file' 2>/dev/null | grep "^${DIR}" | xargs -n1 basename | sort -u | tr '\n' ', ' | sed 's/, $//')
      fi
      
      # Only add if today's entry doesn't exist
      if ! grep -q "| ${TODAY} |" "$Orsted_DIR/claude.md"; then
        # Find Work Log table and add row before the closing separator
        if grep -q "## Work Log" "$Orsted_DIR/claude.md"; then
          # Add row to table
          WHAT="${USER_PROMPT:-Files edited}"
          if [ -n "$FILES_LIST" ]; then
            WHAT="${WHAT} (${FILES_LIST})"
          fi
          WHY="See full_context.md for details"
          
          # Insert row after table header, before any existing rows
          sed -i.bak "/^| Date | What | Why |$/a\\
| ${TODAY} | ${WHAT} | ${WHY} |" "$Orsted_DIR/claude.md" 2>/dev/null || \
          # Fallback: append to end if sed fails
          echo "| ${TODAY} | ${WHAT} | ${WHY} |" >> "$Orsted_DIR/claude.md"
        fi
      fi
      
      # Update "Last updated" date
      sed -i.bak "s/\*\*Last updated:\*\* .*/\*\*Last updated:\*\* ${TODAY}/" "$Orsted_DIR/claude.md" 2>/dev/null || true
      rm -f "$Orsted_DIR/claude.md.bak"
      
      # 2. Update full_context.md (maximalist log with full details)
      # Get user prompt
      PROMPT_FILE="/tmp/orsted_prompt_${CONV_ID}.txt"
      USER_PROMPT=""
      if [ -f "$PROMPT_FILE" ]; then
        USER_PROMPT=$(cat "$PROMPT_FILE" 2>/dev/null | head -1)
      fi
      
      # Get detailed file edits for this directory
      EDITS_FILE="/tmp/orsted_edits_${CONV_ID}.txt"
      DETAILED_CHANGES=""
      if [ -f "$EDITS_FILE" ] && command -v jq >/dev/null 2>&1; then
        # Extract all edits for files in this directory
        FILES_IN_DIR=$(grep "\"file\":\"${DIR}/" "$EDITS_FILE" 2>/dev/null || grep "\"file\":\"${DIR}\"" "$EDITS_FILE" 2>/dev/null)
        
        if [ -n "$FILES_IN_DIR" ]; then
          DETAILED_CHANGES=$(echo "$FILES_IN_DIR" | while read -r line; do
            FILE_PATH=$(echo "$line" | jq -r '.file // ""')
            EDIT_COUNT=$(echo "$line" | jq -r '.edit_count // 0')
            EDITS=$(echo "$line" | jq -c '.edits // []')
            
            if [ "$EDIT_COUNT" -gt 0 ]; then
              echo ""
              echo "**File:** \`$FILE_PATH\`"
              echo ""
              echo "$EDITS" | jq -r '.[] | "**Change:**\n```\n\(.old_string // "[new file]")\n```\n→\n```\n\(.new_string // "[deleted]")\n```\n"' | head -c 2000
            else
              echo ""
              echo "**File:** \`$FILE_PATH\` (created or modified)"
            fi
          done)
        fi
      fi
      
      # Get agent response text (full response, not truncated)
      if command -v jq >/dev/null 2>&1; then
        AGENT_RESPONSE=$(echo "$INPUT" | jq -r '.text // ""')
        # Extract key reasoning (first 2000 chars, focusing on explanations)
        AGENT_REASONING=$(echo "$AGENT_RESPONSE" | head -c 2000)
      else
        AGENT_RESPONSE=""
        AGENT_REASONING=""
      fi
      
      # Combine what was done and why into detailed section
      WHAT_AND_WHY=""
      if [ -n "$DETAILED_CHANGES" ]; then
        WHAT_AND_WHY="${DETAILED_CHANGES}"
      else
        # Fallback: list files edited
        if [ -f "$EDITS_FILE" ]; then
          FILES_LIST=$(grep "\"file\"" "$EDITS_FILE" 2>/dev/null | jq -r '.file' 2>/dev/null | grep "^${DIR}" | sort -u | tr '\n' ',' | sed 's/,$//')
          if [ -n "$FILES_LIST" ]; then
            WHAT_AND_WHY="**Files edited:** ${FILES_LIST}"
          fi
        fi
      fi
      
      # Add reasoning
      if [ -n "$AGENT_REASONING" ]; then
        WHAT_AND_WHY="${WHAT_AND_WHY}

**Rationale:** ${AGENT_REASONING}"
      fi
      
      # Create detailed entry using template format
      if [ ! -f "$Orsted_DIR/full_context.md" ]; then
        TEMPLATE_FILE="$WORKSPACE_ROOT/.orsted/full_context.md.template"
        if [ -f "$TEMPLATE_FILE" ]; then
          cp "$TEMPLATE_FILE" "$Orsted_DIR/full_context.md"
          # Remove the example entry
          sed -i.bak '/^## YYYY-MM-DD HH:MM:SS$/,/^---$/d' "$Orsted_DIR/full_context.md" 2>/dev/null || true
          rm -f "$Orsted_DIR/full_context.md.bak"
        else
          cat > "$Orsted_DIR/full_context.md" << EOF
# Full Context Log

> 📜 **Complete history of all changes.** This is an audit trail, not a working document.  
> **AI: Don't read this file unless explicitly asked.** Use \`claude.md\` for current context.

---

## About This File

- **Auto-updated** after every agent response
- **Append-only** — never delete entries
- **For debugging** — when you need to trace what happened

---

## Log

EOF
        fi
      fi
      
      # Append new entry
      cat >> "$Orsted_DIR/full_context.md" << EOF

## ${NOW}

**Action:** ${USER_PROMPT:-[No prompt captured]}  
**Files:** ${FILES_LIST:-[No files captured]}  
**Reasoning:** ${AGENT_REASONING:-[No reasoning captured]}  
**Outcome:** Success

---
EOF
      
      
      # 3. Create project_info.md if doesn't exist
      if [ ! -f "$Orsted_DIR/project_info.md" ]; then
        TEMPLATE_FILE="$WORKSPACE_ROOT/.orsted/project_info.md.template"
        if [ -f "$TEMPLATE_FILE" ]; then
          TODAY=$(date +%Y-%m-%d)
          sed "s/YYYY-MM-DD/$TODAY/g" "$TEMPLATE_FILE" > "$Orsted_DIR/project_info.md"
        else
          # Fallback template
          cat > "$Orsted_DIR/project_info.md" << EOF
# Project Info

> 📖 **Read this first.** Stable reference for project structure and conventions.  
> **Updated:** $(date +%Y-%m-%d)

## What Is This Project?

[Describe the project purpose]

---

## Tech Stack

| Layer | Technology | Version |
|-------|------------|---------|
| Language | — | — |

---

## Project Structure

\`\`\`
[Directory structure]
\`\`\`

---

## Key Files

| File | Purpose | When to Modify |
|------|---------|----------------|
| — | — | — |

---

## Commands

\`\`\`bash
# Development commands here
\`\`\`

---

## Conventions

### Naming
- Files: [convention]
- Components: [convention]

---

## Architecture

[Architecture description]

---

_This file changes rarely. Update when project structure changes._
EOF
        fi
      fi
      
      # 4. Create critical_mistakes.md if doesn't exist
      if [ ! -f "$Orsted_DIR/critical_mistakes.md" ]; then
        TEMPLATE_FILE="$WORKSPACE_ROOT/.orsted/critical_mistakes.md.template"
        if [ -f "$TEMPLATE_FILE" ]; then
          cp "$TEMPLATE_FILE" "$Orsted_DIR/critical_mistakes.md"
        else
          # Fallback template
          cat > "$Orsted_DIR/critical_mistakes.md" << EOF
# Critical Mistakes

> **Purpose:** Learn from corrections. Never repeat the same mistake twice.

## When to Add

- ✅ User corrected you
- ✅ You broke something and had to undo it

## Format

\`\`\`markdown
### YYYY-MM-DD: [Short title]

**Mistake:** [What you did wrong]
**Correction:** [What you should do instead]
**Why it matters:** [Impact]
\`\`\`

---

## Mistakes Log

*No corrections logged yet.*

---
EOF
        fi
      fi
    fi
  done
  
  # Clean up temp files after processing all directories
  rm -f "$UPDATED_DIRS_FILE"
  PROMPT_FILE="/tmp/orsted_prompt_${CONV_ID}.txt"
  EDITS_FILE="/tmp/orsted_edits_${CONV_ID}.txt"
  rm -f "$PROMPT_FILE" "$EDITS_FILE"
fi

# Exit silently - no output needed for afterAgentResponse hook
exit 0
