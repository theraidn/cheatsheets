# Git Cheatsheet

Practical git commands and workflow recommendations.

Workflow:
- Create feature branches: `git checkout -b feat/short-description`
- Keep commits atomic and focused.
- Use `git rebase -i` to clean history before merging.

Useful commands:
```bash
git log --oneline --graph --decorate --all
git status --porcelain=v1
git add -p    # stage hunks interactively
```

Commit message guideline: `Type: Short description` (e.g., `Fix: handle nil response`).

Alternative: Use server-side CI checks and protected branches for merges.
