# Dotfiles (chezmoi)

## Quick Start

```bash
chezmoi init --apply <repo-url>   # New machine
chezmoi apply                     # Sync all
chezmoi apply ~/.config/lazygit   # Sync one module
chezmoi diff ~/.config/nvim       # Preview changes
chezmoi add ~/.config/ghostty     # Update source after editing
```

## Modules

### Terminals

| Module | Path | Sync command |
|--------|------|-------------|
| Ghostty | `~/.config/ghostty` | `chezmoi apply ~/.config/ghostty` |
| WezTerm | `~/.config/wezterm` | `chezmoi apply ~/.config/wezterm` |
| Alacritty | `~/.config/alacritty` | `chezmoi apply ~/.config/alacritty` |

### Editors

| Module | Path | Sync command |
|--------|------|-------------|
| Neovim | `~/.config/nvim` | `chezmoi apply ~/.config/nvim` |
| Helix | `~/.config/helix` | `chezmoi apply ~/.config/helix` |
| Zed | `~/.config/zed` | `chezmoi apply ~/.config/zed` |

### Prompt & Shells

| Module | Path | Sync command |
|--------|------|-------------|
| Starship | `~/.config/starship.toml` `starship-compact.toml` `starship-plain.toml` | `chezmoi apply ~/.config/starship*` |
| Zsh | `~/.zshrc` `~/.zshenv` `~/.zprofile` | `chezmoi apply ~/.zshrc ~/.zshenv ~/.zprofile` |
| Bash | `~/.bashrc` `~/.bash_profile` `~/.profile` | `chezmoi apply ~/.bashrc ~/.bash_profile ~/.profile` |
| Fish | `~/.config/fish` | `chezmoi apply ~/.config/fish` |
| Nushell | `~/.config/nushell` | `chezmoi apply ~/.config/nushell` |

### Multiplexers

| Module | Path | Sync command |
|--------|------|-------------|
| tmux | `~/.config/tmux` | `chezmoi apply ~/.config/tmux` |
| Zellij | `~/.config/zellij` | `chezmoi apply ~/.config/zellij` |

### TUI Tools

| Module | Path | Sync command |
|--------|------|-------------|
| lazygit | `~/.config/lazygit` | `chezmoi apply ~/.config/lazygit` |
| lazydocker | `~/.config/lazydocker` | `chezmoi apply ~/.config/lazydocker` |
| Yazi | `~/.config/yazi` | `chezmoi apply ~/.config/yazi` |
| btop | `~/.config/btop` | `chezmoi apply ~/.config/btop` |

### Dev Tools

| Module | Path | Sync command |
|--------|------|-------------|
| Git | `~/.config/git` | `chezmoi apply ~/.config/git` |
| GitHub CLI | `~/.config/gh` | `chezmoi apply ~/.config/gh` |
| Maven | `~/.config/maven` | `chezmoi apply ~/.config/maven` |

### Apps & System

| Module | Path | Sync command |
|--------|------|-------------|
| Claude Code | `~/.claude` | `chezmoi apply ~/.claude` |
| SSH | `~/.ssh` | `chezmoi apply ~/.ssh` |
| Rime | `~/Library/Rime` | `chezmoi apply ~/Library/Rime` |
| catppuccin-watcher | `~/.local/bin/catppuccin-watcher*` | `chezmoi apply ~/.local/bin` |
| LaunchAgent | `~/Library/LaunchAgents` | `chezmoi apply ~/Library/LaunchAgents` |

## Theme System (Catppuccin)

All tools auto-switch between **Frappe** (dark) and **Latte** (light):

| Tool | Mechanism |
|------|-----------|
| Ghostty | Built-in `dark:/light:` |
| Yazi, Neovim | Terminal background detection (OSC) |
| tmux | `client-focus-in` hook |
| fzf | `FZF_DEFAULT_OPTS` env var at shell startup |
| CotEditor, Helix, btop | LaunchAgent (`catppuccin-watcher`) |
| lazygit, lazydocker | Shell wrapper (`lg`, `lzd`) |

## Conditional Install

`.chezmoiignore` skips configs for software not installed (`lookPath`).
`run_once_macos_defaults.sh.tmpl` guards all commands with existence checks.

## Notes

- tmux plugins managed by TPM, not chezmoi (`run_once_` installs TPM on new machines)
- `~/.config/env.secrets` contains 1Password-sourced secrets
- Compiled binary `catppuccin-watcher` is recompiled from `.swift` source via `run_once_`
