# ── Starship ──────────────────────────────────
mkdir ($nu.data-dir | path join "vendor/autoload")
starship init nu | save -f ($nu.data-dir | path join "vendor/autoload/starship.nu")

# ── Catppuccin theme ──────────────────────────
source ~/.config/nushell/themes/catppuccin_mocha.nu

# ── Cargo ─────────────────────────────────────
source ~/.config/nushell/cargo-env.nu

# ── Secrets from 1Password ───────────────────
source ~/.config/nushell/env.secrets.nu

# ── Aliases ───────────────────────────────────
alias cc = claude --dangerously-skip-permissions

# ── Catppuccin flavor detection ───────────────
def _catppuccin_flavor [] {
    if (sys host | get name) == "Darwin" {
        let result = (do { ^defaults read -g AppleInterfaceStyle } | complete)
        if $result.exit_code == 0 and ($result.stdout | str trim) == "Dark" { "frappe" } else { "latte" }
    } else {
        "frappe"
    }
}

# ── fzf catppuccin theme ─────────────────────
def --env _set_fzf_theme [] {
    let flavor = (_catppuccin_flavor)
    if $flavor == "frappe" {
        $env.FZF_DEFAULT_OPTS = "--color=bg+:#414559,spinner:#f2d5cf,hl:#e78284 --color=fg:#c6d0f5,header:#e78284,info:#ca9ee6,pointer:#f2d5cf --color=marker:#babbf1,fg+:#c6d0f5,prompt:#ca9ee6,hl+:#e78284 --color=border:#8caaee"
    } else {
        $env.FZF_DEFAULT_OPTS = "--color=bg+:#ccd0da,spinner:#dc8a78,hl:#d20f39 --color=fg:#4c4f69,header:#d20f39,info:#8839ef,pointer:#dc8a78 --color=marker:#7287fd,fg+:#4c4f69,prompt:#8839ef,hl+:#d20f39 --color=border:#1e66f5"
    }
}
_set_fzf_theme

# ── Zellij with auto theme ───────────────────
def --wrapped zj [...args] {
    let theme = if (sys host | get name) == "Darwin" {
        let result = (do { ^defaults read -g AppleInterfaceStyle } | complete)
        if $result.exit_code == 0 and ($result.stdout | str trim) == "Dark" {
            "catppuccin-mocha-vivid"
        } else {
            "catppuccin-frappe-vivid"
        }
    } else {
        "catppuccin-mocha-vivid"
    }
    do { ^zellij options --theme $theme } | complete | ignore
    ^zellij ...$args
}

# ── Lazygit with auto theme ──────────────────
def --wrapped lg [...args] {
    let f = (_catppuccin_flavor)
    with-env { LG_CONFIG_FILE: $"($env.HOME)/.config/lazygit/config.yml,($env.HOME)/.config/lazygit/theme-($f).yml" } {
        ^lazygit ...$args
    }
}

# ── Lazydocker with auto theme ───────────────
def --wrapped lzd [...args] {
    let f = (_catppuccin_flavor)
    ^cp $"($env.HOME)/.config/lazydocker/theme-($f).yml" $"($env.HOME)/.config/lazydocker/config.yml"
    ^lazydocker ...$args
}

# ── btop with auto theme ─────────────────────
def --wrapped bt [...args] {
    let f = (_catppuccin_flavor)
    if (sys host | get name) == "Darwin" {
        ^sed -i '' $'s|color_theme = .*|color_theme = "($env.HOME)/.config/btop/themes/catppuccin_($f).theme"|' $"($env.HOME)/.config/btop/btop.conf"
    } else {
        ^sed -i $'s|color_theme = .*|color_theme = "($env.HOME)/.config/btop/themes/catppuccin_($f).theme"|' $"($env.HOME)/.config/btop/btop.conf"
    }
    ^btop ...$args
}

# ── zoxide ────────────────────────────────────
source ~/.cache/zoxide/init.nu
