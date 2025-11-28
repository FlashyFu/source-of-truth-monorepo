# Git Cheatsheet

Practical day-to-day Git commands and workflows.

## Basic Commands

```bash
# Clone a repository
git clone <repo>

# Check status
git status

# Add files to staging
git add <file>
git add .

# Commit changes
git commit -m "message"

# Push changes
git push origin <branch>

# Pull latest changes
git pull origin <branch>
```

## Branching

```bash
# Create a new branch
git checkout -b <branch-name>

# Switch to a branch
git checkout <branch-name>

# List branches
git branch

# Delete a branch
git branch -d <branch-name>

# Force delete a branch
git branch -D <branch-name>
```

## Merging

```bash
# Merge a branch into current branch
git merge <branch-name>

# Abort a merge
git merge --abort
```

## Stashing

```bash
# Stash changes
git stash

# List stashes
git stash list

# Apply last stash
git stash pop

# Apply specific stash
git stash apply stash@{n}
```

## Viewing History

```bash
# View commit history
git log

# View commit history with graph
git log --oneline --graph --all

# View changes in a commit
git show <commit-hash>

# View diff
git diff
git diff --staged
```

## Undoing Changes

```bash
# Discard changes in working directory
git checkout -- <file>

# Unstage a file
git reset HEAD <file>

# Amend last commit
git commit --amend

# Reset to previous commit (soft - keeps changes)
git reset --soft HEAD~1

# Reset to previous commit (hard - discards changes)
git reset --hard HEAD~1
```

## Remote Operations

```bash
# Add remote
git remote add origin <url>

# View remotes
git remote -v

# Fetch from remote
git fetch origin

# Push new branch to remote
git push -u origin <branch-name>
```

## Tags

```bash
# Create a tag
git tag v1.0.0

# Create annotated tag
git tag -a v1.0.0 -m "Version 1.0.0"

# Push tags
git push origin --tags

# List tags
git tag -l
```

## Configuration

```bash
# Set global username
git config --global user.name "Your Name"

# Set global email
git config --global user.email "you@example.com"

# View config
git config --list
```

## Common Workflows

### Feature Branch Workflow

```bash
# Create feature branch
git checkout -b feature/my-feature

# Make changes and commit
git add .
git commit -m "feat: add new feature"

# Push to remote
git push -u origin feature/my-feature

# Create PR and merge, then clean up
git checkout main
git pull origin main
git branch -d feature/my-feature
```

### Rebasing

```bash
# Rebase current branch onto main
git rebase main

# Interactive rebase last n commits
git rebase -i HEAD~n

# Continue after resolving conflicts
git rebase --continue

# Abort rebase
git rebase --abort
```
