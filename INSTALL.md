# Installation Guide

## Quick Install

1. **Clone the repository:**
   ```bash
   git clone https://github.com/nathanasimon/orsted-cursor.git
   cd orsted-cursor
   ```

2. **Run the install script:**
   ```bash
   chmod +x install.sh
   ./install.sh
   ```

3. **Restart Cursor** for hooks to take effect.

The install script will:
- Install hook scripts to `~/.cursor/hooks/`
- Configure hooks in `~/.cursor/hooks.json`
- Copy templates to `~/.cursor/orsted-templates/`
- Install test script (`orsted_test.sh`)
- Install Cursor command (`/orsted-test`)

After installation, verify with:
```bash
~/.cursor/hooks/orsted_test.sh
```

## Manual Install

If you prefer to install manually:

### 1. Create Hooks Directory

```bash
mkdir -p ~/.cursor/hooks
```

### 2. Copy Hook Scripts

```bash
cp hooks/orsted_before_prompt.sh ~/.cursor/hooks/
cp hooks/orsted_file_edit.sh ~/.cursor/hooks/
cp hooks/orsted_after_response.sh ~/.cursor/hooks/
chmod +x ~/.cursor/hooks/orsted*.sh
```

### 3. Install Hooks Configuration

```bash
cp hooks/hooks.json ~/.cursor/hooks.json
```

### 4. Copy Templates (Optional)

```bash
mkdir -p ~/.cursor/orsted-templates
cp templates/*.template ~/.cursor/orsted-templates/
```

### 5. Restart Cursor

Restart Cursor for hooks to take effect.

## Project Setup

After installation, set up Orsted in your project:

1. **Copy `.cursorrules`** to your project root
2. **Create `.orsted/` folder** in your project root
3. **Copy templates** to `.orsted/` folder:
   ```bash
   mkdir -p .orsted
   cp templates/*.template .orsted/
   ```
4. **Fill in `project_info.md`** with your project details

## Verification

After installation, verify hooks are working:

```bash
# Check hooks are installed
ls -la ~/.cursor/hooks/orsted*.sh

# Check hooks.json exists
cat ~/.cursor/hooks.json

# Test hook script
echo '{"loop_count": 0}' | ~/.cursor/hooks/orsted_after_response.sh
```

## Troubleshooting

### Hooks not firing
- Make sure Cursor was restarted after installation
- Check `~/.cursor/hooks.json` exists and is valid JSON
- Verify scripts are executable: `chmod +x ~/.cursor/hooks/orsted*.sh`

### Templates not found
- Templates are copied to `~/.cursor/orsted-templates/` for reference
- Copy them to your project's `.orsted/` folder to use them

### Permission denied
```bash
chmod +x ~/.cursor/hooks/orsted*.sh
```
