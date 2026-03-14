if status is-interactive
    # ── Editor ────────────────────────────────────────────────
    set -gx EDITOR nvim
    set -gx VISUAL zed

    # ── SSH auth (1Password) ──────────────────────────────────
    set -gx SSH_AUTH_SOCK "$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

    # ── PATH additions ────────────────────────────────────────
    fish_add_path /opt/homebrew/opt/mysql-client/bin
    fish_add_path $HOME/.local/bin
    fish_add_path -a ./
    fish_add_path -a $HOME/.antigravity/antigravity/bin
    fish_add_path -a "$HOME/Library/Application Support/JetBrains/Toolbox/scripts"
    fish_add_path -a /System/Volumes/Data/Applications/Obsidian.app/Contents/MacOS

    # ── Abbreviations ─────────────────────────────────────────
    abbr -a cc 'claude --dangerously-skip-permissions'

    # ── Aliases ───────────────────────────────────────────────
    alias wget='wget --hsts-file="$XDG_STATE_HOME/wget/hsts"'

    # ── Secrets from 1Password (parse bash export format) ─────
    if test -f $XDG_CONFIG_HOME/env.secrets
        for line in (grep '^export ' $XDG_CONFIG_HOME/env.secrets)
            set -l kv (string replace 'export ' '' $line)
            set -l key (string split -m1 '=' $kv)[1]
            set -l val (string trim -c "'" (string split -m1 '=' $kv)[2])
            set -gx $key $val
        end
    end

    # ── Homebrew ──────────────────────────────────────────────
    if test -x /opt/homebrew/bin/brew
        eval (/opt/homebrew/bin/brew shellenv)
    end

    # ── direnv ────────────────────────────────────────────────
    if command -q direnv
        direnv hook fish | source
    end

    # ── zoxide ────────────────────────────────────────────────
    if command -q zoxide
        zoxide init fish | source
    end

    # ── OrbStack ──────────────────────────────────────────────
    source ~/.orbstack/shell/init2.fish 2>/dev/null; or true

    # ── fzf catppuccin auto theme ─────────────────────────────
    _set_fzf_catppuccin_theme
end
