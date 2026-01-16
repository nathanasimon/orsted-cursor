# Push to GitHub

## Create Repository on GitHub

1. Go to https://github.com/new
2. Create repository: `orsted-cursor`
3. **Don't** initialize with README (we already have files)

## Push to GitHub

```bash
cd /Users/nathansimon/orsted-marketplace-1/orsted-cursor-repo
git remote add origin https://github.com/yourusername/orsted-cursor.git
git branch -M main
git push -u origin main
```

## Update README

After pushing, update the GitHub URLs in:
- `README.md` - Replace `yourusername` with your actual GitHub username
