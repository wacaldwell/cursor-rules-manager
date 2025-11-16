# DevOps Rules Management - Quick Reference Card

## 🚀 **Daily Commands**

### Making Rule Changes
```bash
# Start new feature
git flow feature start my-rule-change

# Make changes, then commit
git add .
git commit -m "Description of changes"

# Finish feature (merge to develop)
git flow feature finish my-rule-change
```

### Deploying to Production
```bash
# Create release
git flow release start v1.x.x

# Update version and changelog
echo "1.x.x" > VERSION
# Edit CHANGELOG.md

# Commit and deploy
git add VERSION CHANGELOG.md
git commit -m "Prepare release v1.x.x: Description"

# Finish release with inline tag message (avoids editor prompt)
# ⚠️ macOS: Use hyphens instead of spaces in message (BSD getopt limitation)
git flow release finish -m "Release-v1.x.x-Description" v1.x.x

# Alternative: Set EDITOR to true to skip tag message prompt entirely
# GIT_EDITOR=true git flow release finish v1.x.x

# Push to GitHub
git push origin main && git push origin develop && git push --tags
```

**⚠️ Important Notes**:
- Always use `-m "message"` flag to avoid editor prompts
- **macOS Users**: Replace spaces with hyphens in messages (BSD getopt limitation)
- **Alternative**: Use `GIT_EDITOR=true git flow release finish v1.x.x` to skip tag message entirely

### Emergency Fixes
```bash
# Hotfix from main
git flow hotfix start v1.x.x
# Make fixes, commit
git add .
git commit -m "Hotfix: Description of fix"

# Finish hotfix with inline tag message (avoids editor prompt)
# ⚠️ macOS: Use hyphens instead of spaces (BSD getopt limitation)
git flow hotfix finish -m "Hotfix-v1.x.x-Description" v1.x.x

# Push immediately
git push origin main && git push origin develop && git push --tags
```

## 🛠 **Tools**

| Command | Purpose |
|---------|---------|
| `./tools/validate-rules.sh` | Check rule consistency |
| `./tools/sync-rules.sh` | Deploy rules manually |
| `./tools/backup-current-rules.sh` | Backup existing rules |

## 📂 **Key Locations**

| Location | Purpose |
|----------|---------|
| `/Volumes/para/resources/devops/devops-rules/` | Rules repository |
| `/Volumes/para/resources/devops/scripts/.cursorrules` | Active scripts rules |
| `/Volumes/para/resources/devops/projects/.cursorrules` | Active projects rules |
| `/Volumes/para/resources/devops/logs/` | All automation logs |

## 🔄 **Git Flow Branches**

| Branch | Purpose | Auto-Sync |
|--------|---------|-----------|
| `main` | Production | ✅ Yes |
| `develop` | Integration | ❌ No |
| `feature/*` | Development | ❌ No |
| `release/*` | Preparing | ❌ No |
| `hotfix/*` | Emergency | ✅ Yes |

## ⚠️ **Important Rules**

- **MCP Servers**: Consult for guidance (not execute through)
- **Logging**: Single continuous file per script, not timestamped
- **Validation**: Must pass before commits are allowed
- **Sync**: Only happens on main branch (production releases)

## 🆘 **Troubleshooting**

```bash
# Check what's wrong
./tools/validate-rules.sh

# Check logs
ls -la /Volumes/para/resources/devops/logs/

# Fix permissions
chmod +x tools/*.sh .git/hooks/*

# Manual sync if needed
./tools/sync-rules.sh
```