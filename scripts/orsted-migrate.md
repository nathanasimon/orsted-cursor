# Orsted Migrate Templates

Safely update existing `.orsted/` files to match new template structure while preserving all your data.

## What This Does

- Finds all `.orsted/` folders in your workspace
- Compares existing files with new templates
- Creates missing files from templates
- Preserves all existing data (doesn't overwrite)

## When to Use

- After updating Orsted templates
- When template structure changes
- To add new template files to existing projects

## Usage

Run this command to migrate templates in your current workspace.

## Manual Migration

For more control, you can:

1. **Backup your .orsted folders:**
   ```bash
   find . -type d -name ".orsted" -exec cp -r {} {}.backup \;
   ```

2. **Review template changes:**
   ```bash
   diff .orsted/claude.md ~/.cursor/orsted-templates/claude.md.template
   ```

3. **Manually merge new sections** if template structure changed

## Important

This script **preserves existing files**. If template structure changed significantly, you may need to manually merge new sections into your existing files.
