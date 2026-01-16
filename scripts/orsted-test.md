# Orsted Test

Run a comprehensive test to verify Orsted is installed and working correctly.

## What This Does

1. Checks if all hook scripts are installed and executable
2. Validates hooks.json configuration
3. Verifies templates are available
4. Checks dependencies (jq)
5. Scans current workspace for .orsted folders

## Usage

Run this command and review the test results. If all tests pass, Orsted should be working correctly.

## Manual Test

After running this test, try:
1. Edit a file in any directory
2. Submit a prompt to the AI
3. Check if `.orsted/` folder was created/updated in that directory
