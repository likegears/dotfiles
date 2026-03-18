# Dotfiles (chezmoi)

Cross-platform dotfiles managed by [chezmoi](https://chezmoi.io). Supports **macOS** (primary), **WSL/Linux**, and partial **Windows** with native terminal/SSH support plus WSL integration.

## Setup

### New Machine (macOS / WSL / Linux)

```bash
# 1. Install chezmoi + apply dotfiles
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply likegears

# 2. Install packages (macOS only)
brew bundle install --file=~/.local/share/chezmoi/Brewfile

# 3. Install App Store apps (macOS only)
awk '{print $1}' ~/.local/share/chezmoi/Masfile | xargs mas install
```

### Windows Host + WSL

```powershell
# Windows host only
chezmoi init --apply likegears

# Windows host + one WSL distro
~/.local/bin/sync-dotfiles.ps1
```

Notes:

- `sync-dotfiles.ps1` updates the Windows host first, then updates one WSL distro.
- If you have multiple distros, set `WEZTERM_WSL_DISTRO` or pass `-WslDistro`.
- The WSL distro must have a normal default user, plus `git` and `curl` installed.
- `sync-dotfiles.ps1` repairs missing WSL interop registration on systemd-based distros before syncing.
- In WSL, `~/.local/bin/op` and `~/.local/bin/tailscale` call the Windows `op.exe` and `tailscale.exe` when available.
- In WSL, Git uses `ssh.exe` and a WSL-side `op-ssh-sign-wsl` wrapper so signing/auth flows through the Windows 1Password app.
- Windows should have the 1Password desktop app, the 1Password CLI (`op.exe`), and Tailscale installed.

### Daily Operations

```bash
chezmoi apply                     # Sync all configs to $HOME
chezmoi apply ~/.config/ghostty   # Sync single module
chezmoi diff                      # Preview pending changes
chezmoi add ~/.config/ghostty     # Capture local edits to source
chezmoi re-add                    # Re-add all changed managed files
```

## Cross-Platform Strategy

| Layer | Mechanism | Files |
|-------|-----------|-------|
| **Static configs** | chezmoi templates (`.tmpl`) | ssh/config, git/config, btop.conf |
| **Shell RCs** | Runtime `$OSTYPE` / `uname` checks | zshrc, bashrc, fish, nushell |
| **macOS-only files** | `.chezmoiignore` with `{{ .chezmoi.os }}` | Library/, LaunchAgents, Rime |
| **Software detection** | `lookPath` in `.chezmoiignore` | Skip configs for uninstalled tools |

### What changes per platform

| Item | macOS | WSL / Linux |
|------|-------|-------------|
| 1Password SSH socket | `~/Library/Group Containers/.../agent.sock` | `~/.1password/agent.sock` |
| Git signing program | `/Applications/1Password.app/.../op-ssh-sign` | `/opt/1Password/op-ssh-sign` |
| Homebrew | `/opt/homebrew/bin/brew` | `/home/linuxbrew/.linuxbrew/bin/brew` or system |
| Theme detection | `defaults read -g AppleInterfaceStyle` | Defaults to "frappe" (dark) |
| LaunchAgents, Rime | Deployed | Skipped via `.chezmoiignore` |

### Windows notes

- Native Windows keeps the same XDG-style layout under `~/.config`, `~/.local/share`, and `~/.local/bin`.
- SSH uses Windows OpenSSH with the 1Password system agent, so `SSH_AUTH_SOCK` is left unset on Windows shells.
- Git SSH signing uses `~/.local/bin/op-ssh-sign.cmd`, which locates `op-ssh-sign.exe` dynamically per machine.
- WezTerm auto-discovers WSL domains on Windows. Set `WEZTERM_WSL_DISTRO` if you want a specific distro to be the default.
- In WSL, Git uses `ssh.exe` and `~/.local/bin/op-ssh-sign-wsl` so Windows 1Password can serve both environments.
- In WSL, `op` and `tailscale` prefer the Windows-side executables and fall back to native Linux installs when needed.

## Modules

### Terminals

| Module | Path | Template |
|--------|------|----------|
| Ghostty | `~/.config/ghostty` | plain |
| WezTerm | `~/.config/wezterm` | plain (runtime `find_shell()` for cross-platform) |
| Alacritty | `~/.config/alacritty` | plain |

### Editors

| Module | Path |
|--------|------|
| Neovim (LazyVim) | `~/.config/nvim` |
| Helix | `~/.config/helix` |
| Zed | `~/.config/zed` |

### Shells & Prompt

| Module | Files | Cross-platform |
|--------|-------|----------------|
| Zsh | `.zshrc`, `.zshenv`, `.zprofile` | `$OSTYPE` guards for macOS-specific code |
| Bash | `.bashrc`, `.bash_profile`, `.profile` | Same `$OSTYPE` guards |
| Fish | `~/.config/fish` | `uname` guards |
| Nushell | `~/.config/nushell` | `sys host` guards |
| Starship | `starship.toml`, `starship-compact.toml`, `starship-plain.toml` | Auto font detection per terminal |

### Multiplexers

| Module | Path |
|--------|------|
| tmux | `~/.config/tmux` (plugins via TPM, not chezmoi) |
| Zellij | `~/.config/zellij` |

### TUI Tools

| Module | Path |
|--------|------|
| lazygit | `~/.config/lazygit` |
| lazydocker | `~/.config/lazydocker` |
| Yazi | `~/.config/yazi` |
| btop | `~/.config/btop` (template: `{{ .chezmoi.homeDir }}` for theme path) |

### Dev & Security

| Module | Path | Template |
|--------|------|----------|
| Git | `~/.config/git` | `.tmpl` (gpg.ssh.program per OS) |
| SSH | `~/.ssh` | `.tmpl` (IdentityAgent per OS, OrbStack macOS-only) |
| GitHub CLI | `~/.config/gh` | plain |

### AI Coding Tools

| Module | Path | Contents |
|--------|------|----------|
| Claude Code | `~/.claude` | settings, agents, skills, commands, statusline |
| Codex skills | `~/.claude/skills/codex-*.md` | review, brainstorm, debug, implement (CLI-based) |
| Codex commands | `~/.claude/commands/codex-*.md` | Slash commands: `/codex-review`, `/codex-brainstorm`, etc. |

### macOS Only

| Module | Path | Ignored on Linux |
|--------|------|-----------------|
| LaunchAgents | `~/Library/LaunchAgents` | Yes |
| Rime (Squirrel) | `~/Library/Rime` | Yes |
| catppuccin-watcher | `~/.local/bin/catppuccin-watcher*` | Yes |
| daily-maintenance | `~/.local/bin/daily-maintenance` | Runs but macOS-specific tasks skipped |

### Scripts

| Script | Path | Purpose |
|--------|------|---------|
| daily-maintenance | `~/.local/bin/daily-maintenance` | brew/mas upgrade, Brewfile export, bookmark sync, chezmoi auto-push |
| vivaldi_to_safari | `~/Scripts/vivaldi_to_safari.py` | Sync Vivaldi bookmarks to Safari |
| theme-switch | `~/.local/bin/theme-switch` | Manual Catppuccin theme toggle |

### Package Lists (reference, not deployed)

| File | Generated by | Purpose |
|------|-------------|---------|
| `Brewfile` | `brew bundle dump` | Restore all Homebrew packages |
| `Masfile` | `mas list` | Restore all App Store apps |

Auto-exported daily by `daily-maintenance` and committed to git.

## Theme System (Catppuccin)

All tools auto-switch between **Frappe** (dark) and **Latte** (light) based on macOS appearance. On Linux, defaults to Frappe.

| Tool | Mechanism |
|------|-----------|
| Ghostty | Built-in `dark:/light:` theme syntax |
| Yazi, Neovim | Terminal background detection (OSC) |
| tmux | `client-focus-in` hook |
| fzf | `FZF_DEFAULT_OPTS` set at shell startup |
| CotEditor, Helix, btop | LaunchAgent (`catppuccin-watcher`) |
| lazygit, lazydocker | Shell wrapper functions (`lg`, `lzd`) |
| Zellij | Shell wrapper function (`zj`) |
| Alacritty | `theme-switch.sh` |

## Automation (daily-maintenance)

Runs daily at 9:00 via LaunchAgent `com.user.daily-maintenance.plist`:

```
1. brew update & upgrade (formulae + casks individually with timeout)
2. mas upgrade (App Store)
3. Export Brewfile + Masfile to chezmoi source
4. Sync Vivaldi bookmarks → Safari
5. Auto git commit & push chezmoi changes to origin + gitea
```

## Template Files

These files use chezmoi Go templates (`{{ }}`) for per-OS values:

| File | Templated values |
|------|-----------------|
| `.ssh/config` | `IdentityAgent` path, OrbStack include |
| `.config/git/config` | `gpg.ssh.program` path |
| `.config/btop/btop.conf` | `color_theme` absolute path |
| `.config/env.secrets` | 1Password secret references |
| `.config/nushell/env.secrets.nu` | 1Password secret references |
| `run_once_macos_defaults.sh` | macOS system preferences (runs once) |

## Secrets

Managed via 1Password CLI (`op`). Template files (`.tmpl`) use `onepasswordRead` to fetch secrets at `chezmoi apply` time. Secrets are never committed to git.

## Remotes

| Remote | URL |
|--------|-----|
| origin | `git@github.com:likegears/dotfiles.git` |
| gitea | `ssh://git@gitea.likegears.com:33233/likegears/dotfiles.git` |
