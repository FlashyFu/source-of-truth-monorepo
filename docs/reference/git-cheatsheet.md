# Git Cheatsheet

> Practical day-to-day Git commands and workflows

**Type**: Reference
**Audience**: All developers
**Last Updated**: 2025-11-28

---

## Basic Commands

```bash
# Clone a repository
git clone <repo>

# Check status of working directory
git status

# Stage a file for commit
git add <file>

# Commit staged changes with message
git commit -m "message"

# Create and switch to a new feature branch
git checkout -b feature/short-description

# Push branch to remote and set upstream
git push -u origin feature/short-description

# Pull changes from remote and rebase
git pull --rebase
```

---

## Feature Branch Flow

Standard workflow for developing new features:

```bash
# 1. Create a new feature branch
git checkout -b feature/xyz

# 2. Work and commit locally
git add .
git commit -m "feat: implement xyz feature"

# 3. Rebase onto main before pushing
git fetch origin && git rebase origin/main

# 4. Push your branch
git push origin HEAD
```

**Note**: Always rebase onto the latest `main` before creating a pull request to minimize merge conflicts.

---

## Merge vs Rebase

### When to Use Merge

- Use merge to preserve history and show merge commits
- Best for long-running branches or releases
- Creates a merge commit showing when branches were integrated

```bash
git checkout main
git merge feature/xyz
```

### When to Use Rebase

- Use rebase to keep linear history for small feature branches
- Makes history cleaner and easier to follow
- **Caution**: Never rewrite public/shared history

```bash
git checkout feature/xyz
git rebase main
```

---

## Undo Mistakes

```bash
# Restore a file from index or HEAD (discard local changes)
git restore <file>

# Unstage a file (keep changes in working directory)
git restore --staged <file>

# Safe revert - creates a new commit that undoes changes
git revert <commit>

# Undo last commit, keep changes staged
git reset --soft HEAD~1

# Destructive - discard last commit and all changes
git reset --hard HEAD~1
```

**Warning**: `git reset --hard` is destructive and cannot be undone. Use with caution.

---

## Stash

Temporarily save changes without committing:

```bash
# Stash current changes with a message
git stash push -m "WIP"

# List all stashes
git stash list

# Apply a specific stash (keeps it in stash list)
git stash apply stash@{0}

# Remove a specific stash
git stash drop stash@{0}

# Apply and remove stash in one command
git stash pop stash@{0}
```

---

## Interactive Rebase

Clean up commits before sharing:

```bash
# Interactively rebase last N commits
git rebase -i HEAD~N
```

### Squash Commits Before PR

```bash
# Squash all commits since branching from main
git rebase -i origin/main
```

**Common operations in interactive rebase**:

- `pick` - Keep the commit as-is
- `reword` - Keep commit but edit message
- `squash` - Combine with previous commit
- `fixup` - Combine with previous, discard message
- `drop` - Remove the commit

---

## Cherry-pick

Apply a specific commit from another branch:

```bash
git cherry-pick <commit>
```

**Use case**: Apply a specific bug fix from one branch to another without merging the entire branch.

---

## Tags & Releases

```bash
# Create an annotated tag
git tag -a v1.2.3 -m "release notes"

# Push a specific tag to remote
git push origin v1.2.3

# Push all tags to remote
git push origin --tags

# List all tags
git tag -l

# Delete a local tag
git tag -d v1.2.3

# Delete a remote tag
git push origin --delete v1.2.3
```

---

## Useful Configuration

```bash
# Set your name
git config --global user.name "Your Name"

# Set your email
git config --global user.email "you@example.com"

# Set VS Code as default editor
git config --global core.editor "code --wait"

# Enable helpful colorization
git config --global color.ui auto

# Set default branch name
git config --global init.defaultBranch main
```

---

## Hooks & CI

### Pre-commit Hooks

Use [pre-commit](https://pre-commit.com/) for linting and formatting checks:

```bash
# Install pre-commit
pip install pre-commit

# Install hooks from .pre-commit-config.yaml
pre-commit install

# Run hooks on all files
pre-commit run --all-files
```

### Husky (Node.js)

This repository uses Husky for Git hooks. Hooks are configured in `.husky/` directory.

---

## Security

### Preventing Secret Commits

Use [git-secrets](https://github.com/awslabs/git-secrets) or commit hooks to prevent accidental commits of secrets:

```bash
# Install git-secrets
brew install git-secrets  # macOS
apt install git-secrets   # Debian/Ubuntu

# Initialize in repository
git secrets --install

# Add AWS patterns
git secrets --register-aws

# Scan history for secrets
git secrets --scan-history
```

### Gitleaks

This repository uses [gitleaks](https://github.com/gitleaks/gitleaks) for secret scanning in CI.

---

## Quick Reference

| Action                  | Command                          |
| ----------------------- | -------------------------------- |
| Clone repo              | `git clone <repo>`               |
| Check status            | `git status`                     |
| Stage file              | `git add <file>`                 |
| Stage all               | `git add .`                      |
| Commit                  | `git commit -m "message"`        |
| Create branch           | `git checkout -b <branch>`       |
| Switch branch           | `git checkout <branch>`          |
| Push branch             | `git push -u origin <branch>`    |
| Pull with rebase        | `git pull --rebase`              |
| View log                | `git log --oneline`              |
| View diff               | `git diff`                       |
| Stash changes           | `git stash push -m "WIP"`        |
| Apply stash             | `git stash pop`                  |
| Undo uncommitted change | `git restore <file>`             |
| Unstage file            | `git restore --staged <file>`    |
| Undo last commit        | `git reset --soft HEAD~1`        |
| Cherry-pick             | `git cherry-pick <commit>`       |
| Create tag              | `git tag -a v1.0.0 -m "release"` |

---

## See Also

- [CLI Reference](/docs/reference/cli-reference.md) - pnpm and Turbo commands
- [Subtree Synchronization](/docs/reference/subtree-sync.md) - How mirrors are updated
- [Git Subtree Explained](/docs/explanation/git-subtree-explained.md) - Deep dive into Git subtree
- [Contributing Guidelines](/CONTRIBUTING.md) - How to contribute to this repository

---

**Last Updated**: 2025-11-28 | **Maintainer**: @Krosebrook
