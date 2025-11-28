# Git Cheatsheet

> Practical Git commands and tips for daily workflows

## Table of Contents

- [Configuration](#configuration)
- [Basic Operations](#basic-operations)
- [Branching](#branching)
- [Staging & Committing](#staging--committing)
- [Remote Operations](#remote-operations)
- [Viewing History](#viewing-history)
- [Undoing Changes](#undoing-changes)
- [Stashing](#stashing)
- [Advanced Operations](#advanced-operations)
- [Git Aliases](#git-aliases)
- [Troubleshooting](#troubleshooting)

---

## Configuration

### Initial Setup

```bash
# Set your identity
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# Set default branch name
git config --global init.defaultBranch main

# Set default editor
git config --global core.editor "code --wait"  # VS Code
git config --global core.editor "vim"          # Vim

# Enable color output
git config --global color.ui auto

# Set pull behavior
git config --global pull.rebase true  # Rebase instead of merge

# View all config
git config --list
```

### SSH Key Setup

```bash
# Generate SSH key
ssh-keygen -t ed25519 -C "your@email.com"

# Start SSH agent
eval "$(ssh-agent -s)"

# Add key to agent
ssh-add ~/.ssh/id_ed25519

# Copy public key (add to GitHub/GitLab)
cat ~/.ssh/id_ed25519.pub
```

---

## Basic Operations

### Creating Repositories

```bash
# Initialize new repo
git init

# Clone existing repo
git clone https://github.com/user/repo.git
git clone git@github.com:user/repo.git     # SSH
git clone --depth 1 <url>                   # Shallow clone (faster)
git clone --branch <branch> <url>           # Clone specific branch
```

### Checking Status

```bash
# View status
git status
git status -s  # Short format

# View changes
git diff                    # Unstaged changes
git diff --staged           # Staged changes
git diff branch1..branch2   # Between branches
git diff HEAD~3             # Last 3 commits
```

---

## Branching

### Creating & Switching Branches

```bash
# List branches
git branch              # Local
git branch -r           # Remote
git branch -a           # All

# Create branch
git branch feature-name

# Switch to branch
git checkout feature-name
git switch feature-name     # Modern syntax

# Create and switch
git checkout -b feature-name
git switch -c feature-name  # Modern syntax

# Create branch from specific commit
git checkout -b hotfix abc123
```

### Managing Branches

```bash
# Rename branch
git branch -m old-name new-name

# Delete branch
git branch -d feature-name      # Safe delete
git branch -D feature-name      # Force delete

# Delete remote branch
git push origin --delete feature-name

# Track remote branch
git checkout --track origin/feature-name

# Set upstream branch
git branch -u origin/feature-name
```

---

## Staging & Committing

### Staging Files

```bash
# Stage specific files
git add file.txt
git add src/

# Stage all changes
git add .
git add -A

# Stage parts of a file (interactive)
git add -p file.txt

# Unstage files
git reset HEAD file.txt
git restore --staged file.txt  # Modern syntax
```

### Committing

```bash
# Commit with message
git commit -m "Add new feature"

# Commit with body
git commit -m "Subject line" -m "Body text"

# Stage and commit
git commit -am "Update files"

# Amend last commit
git commit --amend -m "New message"
git commit --amend --no-edit  # Keep message

# Empty commit (useful for triggering CI)
git commit --allow-empty -m "Trigger build"
```

### Conventional Commits

```bash
# Format: type(scope): subject

# Types:
feat: new feature
fix: bug fix
docs: documentation
style: formatting (no code change)
refactor: code restructuring
perf: performance improvement
test: tests
chore: maintenance
ci: CI changes
build: build system

# Examples:
git commit -m "feat(auth): add JWT authentication"
git commit -m "fix(api): handle null response"
git commit -m "docs: update README"
```

---

## Remote Operations

### Managing Remotes

```bash
# View remotes
git remote -v

# Add remote
git remote add origin https://github.com/user/repo.git

# Change remote URL
git remote set-url origin git@github.com:user/repo.git

# Remove remote
git remote remove origin

# Rename remote
git remote rename origin upstream
```

### Syncing

```bash
# Fetch from remote (doesn't merge)
git fetch origin
git fetch --all           # All remotes
git fetch --prune         # Remove deleted remote branches

# Pull (fetch + merge)
git pull origin main
git pull --rebase         # Rebase instead of merge

# Push
git push origin main
git push -u origin main   # Set upstream
git push --force-with-lease  # Safer force push
git push --tags           # Push tags
```

---

## Viewing History

### Log Commands

```bash
# Basic log
git log
git log --oneline
git log -n 5              # Last 5 commits

# Graph view
git log --graph --oneline --all

# Search commits
git log --grep="feature"              # By message
git log --author="John"               # By author
git log --since="2024-01-01"          # By date
git log -- path/to/file               # By file

# Pretty format
git log --pretty=format:"%h %ad | %s%d [%an]" --date=short
```

### Viewing Commits

```bash
# Show commit details
git show abc123
git show HEAD~2           # 2 commits ago
git show main:file.txt    # File from branch

# Blame (who changed what)
git blame file.txt
git blame -L 10,20 file.txt  # Lines 10-20

# File history
git log --follow -p -- file.txt
```

---

## Undoing Changes

### Discarding Changes

```bash
# Discard working directory changes
git checkout -- file.txt
git restore file.txt          # Modern syntax
git restore .                 # All files

# Discard staged changes
git reset HEAD file.txt
git restore --staged file.txt

# Discard all changes (dangerous!)
git reset --hard HEAD
git clean -fd                 # Remove untracked files/dirs
```

### Reverting Commits

```bash
# Create new commit that undoes a commit
git revert abc123
git revert HEAD               # Revert last commit
git revert HEAD~3..HEAD       # Revert last 3 commits

# Reset to previous commit (rewrites history!)
git reset --soft HEAD~1       # Keep changes staged
git reset --mixed HEAD~1      # Keep changes unstaged
git reset --hard HEAD~1       # Discard changes
```

### Recovering

```bash
# View reflog (all HEAD movements)
git reflog

# Recover deleted branch
git checkout -b recovered-branch abc123

# Recover from reset
git reset --hard abc123

# Cherry-pick specific commit
git cherry-pick abc123
```

---

## Stashing

### Basic Stash Operations

```bash
# Stash changes
git stash
git stash save "WIP: feature work"
git stash -u                  # Include untracked
git stash -a                  # Include ignored

# List stashes
git stash list

# Apply stash
git stash pop                 # Apply and remove
git stash apply               # Apply and keep
git stash apply stash@{2}     # Specific stash

# View stash contents
git stash show
git stash show -p             # With diff

# Drop stash
git stash drop stash@{0}
git stash clear               # All stashes
```

---

## Advanced Operations

### Rebasing

```bash
# Rebase current branch
git rebase main

# Interactive rebase
git rebase -i HEAD~5          # Last 5 commits
# Commands: pick, reword, edit, squash, fixup, drop

# Continue after resolving conflicts
git rebase --continue
git rebase --skip
git rebase --abort
```

### Merging

```bash
# Merge branch
git merge feature-branch
git merge --no-ff feature     # No fast-forward

# Squash merge
git merge --squash feature
git commit -m "Add feature"

# Abort merge
git merge --abort
```

### Tags

```bash
# List tags
git tag
git tag -l "v1.*"

# Create tag
git tag v1.0.0
git tag -a v1.0.0 -m "Release 1.0.0"  # Annotated

# Tag specific commit
git tag v1.0.0 abc123

# Push tags
git push origin v1.0.0
git push origin --tags

# Delete tag
git tag -d v1.0.0
git push origin --delete v1.0.0
```

### Submodules

```bash
# Add submodule
git submodule add https://github.com/user/repo.git path/to/submodule

# Initialize submodules
git submodule init
git submodule update --init --recursive

# Update submodules
git submodule update --remote

# Remove submodule
git submodule deinit path/to/submodule
git rm path/to/submodule
```

---

## Git Aliases

Add to `~/.gitconfig`:

```ini
[alias]
    # Shortcuts
    co = checkout
    br = branch
    ci = commit
    st = status -s
    
    # Logs
    lg = log --oneline --graph --all
    last = log -1 HEAD --stat
    
    # Branches
    branches = branch -a
    remotes = remote -v
    
    # Undo
    unstage = reset HEAD --
    undo = reset --soft HEAD~1
    
    # Better diff
    d = diff --color-words
    
    # Cleanup
    cleanup = "!git branch --merged | grep -v '\\*\\|main\\|master' | xargs -n 1 git branch -d"
```

---

## Troubleshooting

### Common Issues

```bash
# Fix "detached HEAD"
git checkout main

# Remove file from history (sensitive data)
git filter-branch --force --index-filter \
  "git rm --cached --ignore-unmatch path/to/file" \
  --prune-empty --tag-name-filter cat -- --all

# Fix line endings
git config --global core.autocrlf input  # Mac/Linux
git config --global core.autocrlf true   # Windows

# Resolve merge conflicts
git status                    # View conflicts
# Edit files, then:
git add <resolved-files>
git commit

# Large file issues
git lfs install
git lfs track "*.psd"
git add .gitattributes
```

### Best Practices

1. **Commit often** - Small, focused commits
2. **Write good messages** - Use conventional commits
3. **Pull before push** - Avoid conflicts
4. **Don't force push shared branches**
5. **Use branches** - Keep main clean
6. **Review before merge** - Use pull requests
7. **Keep .gitignore updated**
8. **Tag releases** - Semantic versioning

---

**Last Updated**: 2024-01-15  
**Maintainer**: FlashFusion Team
