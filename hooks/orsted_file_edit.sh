#!/bin/bash

# ORSTED: Track file edits to know which folders were worked in
# Stores folder paths for the stop hook to process

INPUT=$(cat)

# Extract file path from afterFileEdit input
# Try jq first, fallback to awk
if command -v jq >/dev/null 2>&1; then
  FILE_PATH=$(echo "$INPUT" | jq -r '.file_path // empty')
else
  FILE_PATH=$(echo "$INPUT" | awk -F'"file_path":' '{print $2}' | awk -F'"' '{print $2}')
fi

# Extract conversation_id for consistent temp file naming
if command -v jq >/dev/null 2>&1; then
  CONV_ID=$(echo "$INPUT" | jq -r '.conversation_id // "current"' | tr -d '/')
else
  CONV_ID=$(echo "$INPUT" | awk -F'"conversation_id":' '{print $2}' | awk -F'"' '{print $2}' | tr -d '/')
fi

if [ -n "$FILE_PATH" ]; then
  # Extract directory path
  DIR_PATH=$(dirname "$FILE_PATH")
  
  # Extract detailed edit information
  if command -v jq >/dev/null 2>&1; then
    # Get all edits with old_string and new_string
    EDITS_JSON=$(echo "$INPUT" | jq -c '.edits // []')
    # Store as JSON for later parsing
    EDIT_COUNT=$(echo "$EDITS_JSON" | jq 'length')
  else
    EDITS_JSON="[]"
    EDIT_COUNT=0
  fi
  
  # Store directory and edit details in temp file
  if [ -n "$CONV_ID" ]; then
    UPDATED_DIRS="/tmp/orsted_dirs_${CONV_ID}.txt"
    EDITS_FILE="/tmp/orsted_edits_${CONV_ID}.txt"
  else
    UPDATED_DIRS="/tmp/orsted_dirs_current.txt"
    EDITS_FILE="/tmp/orsted_edits_current.txt"
  fi
  
  echo "$DIR_PATH" >> "$UPDATED_DIRS"
  # Store file path and edit details as JSON line
  echo "{\"file\":\"$FILE_PATH\",\"edits\":$EDITS_JSON,\"edit_count\":$EDIT_COUNT}" >> "$EDITS_FILE"
fi

exit 0
