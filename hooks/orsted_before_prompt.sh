#!/bin/bash

# Orsted: Capture user prompt before it's processed
# Stores the prompt for full_context.md logging

INPUT=$(cat)

# Extract prompt and conversation_id
if command -v jq >/dev/null 2>&1; then
  PROMPT=$(echo "$INPUT" | jq -r '.prompt // empty')
  CONV_ID=$(echo "$INPUT" | jq -r '.conversation_id // "current"' | tr -d '/')
else
  PROMPT=$(echo "$INPUT" | awk -F'"prompt":' '{print $2}' | awk -F'"' '{print $2}')
  CONV_ID=$(echo "$INPUT" | awk -F'"conversation_id":' '{print $2}' | awk -F'"' '{print $2}' | tr -d '/')
fi

if [ -n "$PROMPT" ] && [ -n "$CONV_ID" ]; then
  # Store prompt in temp file
  PROMPT_FILE="/tmp/orsted_prompt_${CONV_ID}.txt"
  echo "$PROMPT" > "$PROMPT_FILE"
fi

# Always allow the prompt to proceed
echo '{"continue": true}'
