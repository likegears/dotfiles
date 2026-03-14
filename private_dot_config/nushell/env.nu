# ── XDG Base Directory ────────────────────────
$env.XDG_CONFIG_HOME = ($env.HOME | path join ".config")
$env.XDG_DATA_HOME = ($env.HOME | path join ".local/share")
$env.XDG_CACHE_HOME = ($env.HOME | path join ".cache")
$env.XDG_STATE_HOME = ($env.HOME | path join ".local/state")

# ── Rust ──────────────────────────────────────
$env.CARGO_HOME = ($env.XDG_DATA_HOME | path join "cargo")
$env.RUSTUP_HOME = ($env.XDG_DATA_HOME | path join "rustup")

# ── Bun ───────────────────────────────────────
$env.BUN_INSTALL = ($env.XDG_DATA_HOME | path join "bun")

# ── npm / pnpm ───────────────────────────────
$env.NPM_CONFIG_CACHE = ($env.XDG_CACHE_HOME | path join "npm")
$env.PNPM_HOME = ($env.XDG_DATA_HOME | path join "pnpm")
$env.PNPM_STORE_DIR = ($env.XDG_DATA_HOME | path join "pnpm/store")

# ── Docker ────────────────────────────────────
$env.DOCKER_CONFIG = ($env.XDG_CONFIG_HOME | path join "docker")

# ── GnuPG ─────────────────────────────────────
$env.GNUPGHOME = ($env.XDG_DATA_HOME | path join "gnupg")

# ── History / State ───────────────────────────
$env.LESSHISTFILE = ($env.XDG_STATE_HOME | path join "less/history")

# ── Conda ─────────────────────────────────────
$env.CONDARC = ($env.XDG_CONFIG_HOME | path join "conda/condarc")

# ── Matplotlib ────────────────────────────────
$env.MPLCONFIGDIR = ($env.XDG_CONFIG_HOME | path join "matplotlib")

# ── Claude Code ─────────────────────────────
$env.CLAUDE_AUTOCOMPACT_PCT_OVERRIDE = "70"

# ── Editor ────────────────────────────────────
$env.EDITOR = "nvim"
$env.VISUAL = "zed"

# ── SSH (1Password) ──────────────────────────
$env.SSH_AUTH_SOCK = ($env.HOME | path join "Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock")

# ── PATH ──────────────────────────────────────
use std/util "path add"
path add ($env.CARGO_HOME | path join "bin")
path add ($env.BUN_INSTALL | path join "bin")
path add $env.PNPM_HOME
path add "/opt/homebrew/bin"
path add "/opt/homebrew/sbin"
path add ($env.HOME | path join ".local/bin")
path add "/opt/homebrew/opt/mysql-client/bin"

# ── Homebrew ──────────────────────────────────
if ("/opt/homebrew/bin/brew" | path exists) {
    let brew_env = (do { ^/opt/homebrew/bin/brew shellenv } | complete)
    if $brew_env.exit_code == 0 {
        for line in ($brew_env.stdout | lines | where {|l| $l starts-with "export "}) {
            let kv = ($line | str replace "export " "" | str replace ";" "")
            let parts = ($kv | split column "=" key val)
            if ($parts | length) > 0 {
                let key = ($parts | get 0 | get key)
                let val = ($parts | get 0 | get val | str replace -a '"' '')
                if $key != "PATH" {
                    load-env { ($key): $val }
                }
            }
        }
    }
}
