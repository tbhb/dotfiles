# Claude Code — Global Instructions

## GitHub CLI

Use `gh query` instead of `gh api` for read-only GitHub API calls — it is automatically allowed without a confirmation prompt. `gh query` accepts the same arguments as `gh api` but blocks mutating methods (POST, PUT, PATCH, DELETE) and `--input`.

Use `gh api` (which requires confirmation) only when you actually need to mutate state.
