# Updating Orsted Templates Safely

This guide explains how to change templates without losing existing data.

## The Problem

When you update a template (like `full_context.md.template`), existing `.orsted/` files in projects won't automatically update. If you just overwrite them, you lose all the user's data.

## Solution: Migration System

Orsted includes tools to safely update existing files while preserving all data.

## How to Change Templates

### Step 1: Update the Template

Edit the template file in `templates/`:

```bash
cd /path/to/orsted-cursor-repo
vim templates/full_context.md.template
# Make your changes
git add templates/full_context.md.template
git commit -m "Update full_context template structure"
git push
```

### Step 2: Update Installed Templates

Users need to update their installed templates:

```bash
# Option 1: Update Orsted (includes templates)
~/.cursor/hooks/orsted_update.sh

# Option 2: Just update templates
cp /path/to/orsted-cursor-repo/templates/*.template ~/.cursor/orsted-templates/
```

### Step 3: Migrate Existing Files

Users run the migration command to update their existing `.orsted/` files:

**Option 1: Cursor command**
- Type `/orsted-migrate` in chat

**Option 2: Script**
```bash
~/.cursor/hooks/orsted_migrate.sh /path/to/workspace
```

## What Migration Does

The migration script:
- ✅ **Preserves existing files** - Never overwrites
- ✅ **Creates missing files** - Adds new template files if they don't exist
- ✅ **Shows what changed** - Reports what needs manual review
- ✅ **Creates backups** - Safe to run multiple times

## Manual Migration for Complex Changes

If template structure changed significantly (e.g., new sections, different format):

### 1. Backup First
```bash
find . -type d -name ".orsted" -exec cp -r {} {}.backup \;
```

### 2. Compare Structure
```bash
# See what changed
diff .orsted/full_context.md ~/.cursor/orsted-templates/full_context.md.template
```

### 3. Merge New Sections

For each file that needs updating:

```bash
# Use the structure updater to see what's new
~/.cursor/hooks/update-template-structure.sh \
  ~/.cursor/orsted-templates/full_context.md.template \
  .orsted/full_context.md
```

This shows:
- What sections are new in the template
- What sections exist in your file
- What needs to be merged

### 4. Manual Merge

Edit your file to:
- Add new sections from template
- Keep existing content
- Update section order if needed
- Preserve all your data

## Example: Updating full_context.md Template

Let's say you want to add a new "Session ID" field to the log format:

### Old Template:
```markdown
## YYYY-MM-DD HH:MM:SS

### User Request
> [prompt]
```

### New Template:
```markdown
## YYYY-MM-DD HH:MM:SS | Session: [conversation_id]

### User Request
> [prompt]
```

### Migration Process:

1. **Update template** in repository
2. **Users update** their installed templates (`orsted_update.sh`)
3. **Users migrate** existing files (`orsted_migrate.sh`)
4. **Migration script**:
   - Sees existing files have old format
   - Notes new format available
   - Preserves existing files
   - Reports what needs manual review
5. **User manually updates** if needed (or waits for auto-append to use new format)

## Best Practices

### For Template Authors

1. **Additive changes** are safest (new sections, optional fields)
2. **Breaking changes** need migration guides
3. **Version templates** if making major changes
4. **Document changes** in commit messages

### For Users

1. **Backup before migrating** if you have important data
2. **Review changes** before accepting
3. **Test migration** on a copy first
4. **Keep backups** until you verify everything works

## Current Limitations

The migration system currently:
- ✅ Preserves existing files
- ✅ Creates missing files
- ⚠️ Doesn't auto-merge new sections (manual step needed)
- ⚠️ Doesn't detect structure changes automatically

**Future improvements:**
- Smart section merging
- Automatic structure detection
- Interactive merge tool
- Version-aware migrations

## Quick Reference

```bash
# Update Orsted (includes templates)
~/.cursor/hooks/orsted_update.sh

# Migrate existing files
~/.cursor/hooks/orsted_migrate.sh /path/to/workspace

# Check what changed in a specific file
~/.cursor/hooks/update-template-structure.sh \
  ~/.cursor/orsted-templates/full_context.md.template \
  .orsted/full_context.md

# Backup before migration
find . -type d -name ".orsted" -exec cp -r {} {}.backup \;
```
