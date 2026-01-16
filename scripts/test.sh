#!/bin/bash

# Orsted Test Script
# Tests if Orsted is properly installed and working

echo "=========================================="
echo "Orsted Test"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS_COUNT=0
FAIL_COUNT=0

# Test 1: Check if hooks directory exists
echo "Test 1: Checking hooks directory..."
if [ -d "$HOME/.cursor/hooks" ]; then
    echo -e "${GREEN}✓${NC} Hooks directory exists: ~/.cursor/hooks"
    ((PASS_COUNT++))
else
    echo -e "${RED}✗${NC} Hooks directory missing: ~/.cursor/hooks"
    ((FAIL_COUNT++))
fi

# Test 2: Check if hook scripts exist
echo ""
echo "Test 2: Checking hook scripts..."
HOOKS=("orsted_before_prompt.sh" "orsted_file_edit.sh" "orsted_after_response.sh")
for hook in "${HOOKS[@]}"; do
    if [ -f "$HOME/.cursor/hooks/$hook" ]; then
        if [ -x "$HOME/.cursor/hooks/$hook" ]; then
            echo -e "${GREEN}✓${NC} $hook exists and is executable"
            ((PASS_COUNT++))
        else
            echo -e "${YELLOW}⚠${NC} $hook exists but is not executable"
            ((FAIL_COUNT++))
        fi
    else
        echo -e "${RED}✗${NC} $hook missing"
        ((FAIL_COUNT++))
    fi
done

# Test 3: Check if hooks.json exists and is valid
echo ""
echo "Test 3: Checking hooks.json configuration..."
if [ -f "$HOME/.cursor/hooks.json" ]; then
    if command -v jq >/dev/null 2>&1; then
        if jq empty "$HOME/.cursor/hooks.json" 2>/dev/null; then
            echo -e "${GREEN}✓${NC} hooks.json exists and is valid JSON"
            ((PASS_COUNT++))
            
            # Check if Orsted hooks are registered
            if jq -e '.hooks.beforeSubmitPrompt[] | select(.command | contains("orsted"))' "$HOME/.cursor/hooks.json" >/dev/null 2>&1; then
                echo -e "${GREEN}✓${NC} beforeSubmitPrompt hook registered"
                ((PASS_COUNT++))
            else
                echo -e "${RED}✗${NC} beforeSubmitPrompt hook not registered"
                ((FAIL_COUNT++))
            fi
            
            if jq -e '.hooks.afterFileEdit[] | select(.command | contains("orsted"))' "$HOME/.cursor/hooks.json" >/dev/null 2>&1; then
                echo -e "${GREEN}✓${NC} afterFileEdit hook registered"
                ((PASS_COUNT++))
            else
                echo -e "${RED}✗${NC} afterFileEdit hook not registered"
                ((FAIL_COUNT++))
            fi
            
            if jq -e '.hooks.afterAgentResponse[] | select(.command | contains("orsted"))' "$HOME/.cursor/hooks.json" >/dev/null 2>&1; then
                echo -e "${GREEN}✓${NC} afterAgentResponse hook registered"
                ((PASS_COUNT++))
            else
                echo -e "${RED}✗${NC} afterAgentResponse hook not registered"
                ((FAIL_COUNT++))
            fi
        else
            echo -e "${RED}✗${NC} hooks.json exists but is invalid JSON"
            ((FAIL_COUNT++))
        fi
    else
        echo -e "${YELLOW}⚠${NC} hooks.json exists but jq not installed (can't validate)"
        ((PASS_COUNT++))
    fi
else
    echo -e "${RED}✗${NC} hooks.json missing"
    ((FAIL_COUNT++))
fi

# Test 4: Check if templates exist
echo ""
echo "Test 4: Checking templates..."
TEMPLATES=("claude.md.template" "project_info.md.template" "critical_mistakes.md.template" "full_context.md.template")
TEMPLATE_DIR="$HOME/.cursor/orsted-templates"
if [ -d "$TEMPLATE_DIR" ]; then
    echo -e "${GREEN}✓${NC} Templates directory exists: $TEMPLATE_DIR"
    ((PASS_COUNT++))
    
    for template in "${TEMPLATES[@]}"; do
        if [ -f "$TEMPLATE_DIR/$template" ]; then
            echo -e "${GREEN}✓${NC} $template exists"
            ((PASS_COUNT++))
        else
            echo -e "${YELLOW}⚠${NC} $template missing (will use fallback)"
        fi
    done
else
    echo -e "${YELLOW}⚠${NC} Templates directory missing (will use fallback templates)"
fi

# Test 5: Check if jq is available (optional but recommended)
echo ""
echo "Test 5: Checking dependencies..."
if command -v jq >/dev/null 2>&1; then
    echo -e "${GREEN}✓${NC} jq is installed (recommended for better JSON parsing)"
    ((PASS_COUNT++))
else
    echo -e "${YELLOW}⚠${NC} jq not installed (optional, but recommended)"
fi

# Test 6: Check current workspace for .orsted folders
echo ""
echo "Test 6: Checking current workspace..."
if [ -n "$1" ] && [ -d "$1" ]; then
    WORKSPACE="$1"
else
    WORKSPACE="${PWD:-$HOME}"
fi

echo "Scanning workspace: $WORKSPACE"
ORSTED_COUNT=$(find "$WORKSPACE" -type d -name ".orsted" 2>/dev/null | wc -l | tr -d ' ')
if [ "$ORSTED_COUNT" -gt 0 ]; then
    echo -e "${GREEN}✓${NC} Found $ORSTED_COUNT .orsted folder(s) in workspace"
    ((PASS_COUNT++))
    
    # Check if they have required files
    COMPLETE_COUNT=0
    find "$WORKSPACE" -type d -name ".orsted" 2>/dev/null | while read -r dir; do
        if [ -f "$dir/claude.md" ] && [ -f "$dir/project_info.md" ] && [ -f "$dir/critical_mistakes.md" ] && [ -f "$dir/full_context.md" ]; then
            ((COMPLETE_COUNT++))
        fi
    done
    
    if [ "$COMPLETE_COUNT" -gt 0 ]; then
        echo -e "${GREEN}✓${NC} $COMPLETE_COUNT .orsted folder(s) have all required files"
        ((PASS_COUNT++))
    fi
else
    echo -e "${YELLOW}⚠${NC} No .orsted folders found (may need to trigger initialization)"
fi

# Summary
echo ""
echo "=========================================="
echo "Test Summary"
echo "=========================================="
echo -e "Passed: ${GREEN}$PASS_COUNT${NC}"
echo -e "Failed: ${RED}$FAIL_COUNT${NC}"
echo ""

if [ $FAIL_COUNT -eq 0 ]; then
    echo -e "${GREEN}✓ All critical tests passed!${NC}"
    echo ""
    echo "To verify Orsted is working:"
    echo "1. Make a file edit in any directory"
    echo "2. Submit a prompt to the AI"
    echo "3. Check if .orsted/ folder was created/updated"
    exit 0
else
    echo -e "${RED}✗ Some tests failed. Please check the installation.${NC}"
    echo ""
    echo "To reinstall Orsted:"
    echo "  cd /path/to/orsted-cursor-repo"
    echo "  ./install.sh"
    exit 1
fi
