# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This is a Chezmoi-managed dotfiles repository targeting macOS (Apple Silicon), Ubuntu, and devcontainers. Chezmoi maps files from this repo to the home directory using its naming conventions (e.g., `dot_zshrc.tmpl` → `~/.zshrc`).

## Chezmoi Commands

```bash
chezmoi apply              # Apply changes to home directory
chezmoi apply --force      # Apply, overwriting external modifications
chezmoi diff               # Preview what would change
chezmoi execute-template < home/file.tmpl  # Test template rendering
chezmoi add ~/.<file>      # Add a dotfile to be managed
chezmoi secret keyring set --service chezmoi --user <key>  # Store a secret
```

## Repository Structure

The `.chezmoiroot` file sets `home/` as the source root. All managed dotfiles go under `home/` using Chezmoi naming conventions:

- `dot_` prefix → `.` (dotfile)
- `private_` prefix → `0600` permissions
- `.tmpl` suffix → Go template
- See [Chezmoi reference](https://www.chezmoi.io/reference/source-state-attributes/) for full naming rules

### Managed Files

| Source | Target | Purpose |
|--------|--------|---------|
| `home/dot_zshenv.tmpl` | `~/.zshenv` | Universal env vars (every zsh invocation) |
| `home/dot_zprofile.tmpl` | `~/.zprofile` | Login shell: PATH, env vars, tool environments |
| `home/dot_zshrc.tmpl` | `~/.zshrc` | Interactive shell: completions, plugins, aliases, prompt |
| `home/dot_tmux.conf.tmpl` | `~/.tmux.conf` | tmux: prefix, panes, vi keys, TPM plugins |
| `home/dot_config/mise/config.toml` | `~/.config/mise/config.toml` | mise tool versions (starship, kubectl, ruby) |
| `home/dot_config/starship.toml` | `~/.config/starship.toml` | Starship prompt configuration |
| `home/private_Library/.../private_Code/User/settings.json` | `~/Library/.../Code/User/settings.json` | VS Code user settings |
| `home/private_Library/.../private_Code/User/keybindings.json` | `~/Library/.../Code/User/keybindings.json` | VS Code keybindings |
| `home/private_Library/.../private_Code/User/snippets/ruby.json` | `~/Library/.../Code/User/snippets/ruby.json` | VS Code Ruby snippets |
| `home/run_onchange_after_install-vscode-extensions.sh.tmpl` | _(run script)_ | Install VS Code extensions |
| `home/run_once_after_cleanup-vscode-profiles.sh.tmpl` | _(run script)_ | One-time profile cleanup |

### Zsh File Semantics

- **`.zshenv`** — Runs for every zsh invocation (including scripts). Must be fast, no side effects. Only truly universal env vars.
- **`.zprofile`** — Login shells only, before `.zshrc`. PATH setup, `brew shellenv`, env var exports.
- **`.zshrc`** — Interactive shells only. Aliases, completions, prompt, plugins, key bindings.

## Template Variables

All `.tmpl` files share a common preamble:

```
{{- $isDarwin := eq .chezmoi.os "darwin" -}}
{{- $isLinux := eq .chezmoi.os "linux" -}}
{{- $isDevcontainer := or (env "REMOTE_CONTAINERS") (env "CODESPACES") -}}
{{- $brewPrefix := "/opt/homebrew" (darwin) | "/home/linuxbrew/.linuxbrew" (linux) -}}
```

## Secrets

The 1Password account ID is stored in the system keyring, not in plaintext:

```bash
chezmoi secret keyring set --service chezmoi --user op-account
```

This must be set before `chezmoi apply` on non-devcontainer machines. In devcontainers, the `OP_ACCOUNT` block is skipped via the `$isDevcontainer` conditional.

## Multi-Platform Considerations

This repo targets three environments: macOS (Apple Silicon), Ubuntu, and devcontainers. Use Chezmoi's templating to handle platform differences:

- **OS detection:** `{{ if $isDarwin }}` / `{{ if $isLinux }}`
- **Devcontainer detection:** `{{ if $isDevcontainer }}` (checks `REMOTE_CONTAINERS` / `CODESPACES` env vars)
- **Homebrew paths:** Use `$brewPrefix` variable, not hardcoded paths
- **macOS-only blocks:** 1Password SSH agent, Docker Desktop, Ghostty/Zed tmux sockets, Tailscale alias, GNU coreutils PATH
- **Skipped in devcontainers:** `OP_ACCOUNT`, `SSH_AUTH_SOCK`

## Key Configuration Details

- **Prompt:** Starship, installed via mise (not Homebrew)
- **Editor:** Neovim (`nvim`), set in `.zshenv`
- **SSH:** 1Password agent (`SSH_AUTH_SOCK`)
- **Runtime management:** mise (polyglot version manager)
- **Docker:** Binaries symlinked from Docker.app to `~/.docker/bin`, completions from `~/.docker/completions`
- **Terminal multiplexing:** tmux with per-terminal sockets (Ghostty, Zed, VS Code)
- **PATH:** GNU coreutils/sed/tar/curl prioritized over BSD defaults via Homebrew (macOS only)
