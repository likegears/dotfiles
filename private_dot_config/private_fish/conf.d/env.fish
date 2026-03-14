# ── XDG Base Directory ────────────────────────────────────
set -gx XDG_CONFIG_HOME $HOME/.config
set -gx XDG_DATA_HOME $HOME/.local/share
set -gx XDG_CACHE_HOME $HOME/.cache
set -gx XDG_STATE_HOME $HOME/.local/state

# ── Rust ──────────────────────────────────────────────────
set -gx CARGO_HOME $XDG_DATA_HOME/cargo
set -gx RUSTUP_HOME $XDG_DATA_HOME/rustup

# ── Bun ───────────────────────────────────────────────────
set -gx BUN_INSTALL $XDG_DATA_HOME/bun
fish_add_path $BUN_INSTALL/bin

# ── npm / pnpm ────────────────────────────────────────────
set -gx NPM_CONFIG_CACHE $XDG_CACHE_HOME/npm
set -gx PNPM_HOME $XDG_DATA_HOME/pnpm
set -gx PNPM_STORE_DIR $XDG_DATA_HOME/pnpm/store
fish_add_path $PNPM_HOME

# ── Docker ────────────────────────────────────────────────
set -gx DOCKER_CONFIG $XDG_CONFIG_HOME/docker

# ── GnuPG ─────────────────────────────────────────────────
set -gx GNUPGHOME $XDG_DATA_HOME/gnupg

# ── History / State ───────────────────────────────────────
set -gx LESSHISTFILE $XDG_STATE_HOME/less/history

# ── Conda ─────────────────────────────────────────────────
set -gx CONDARC $XDG_CONFIG_HOME/conda/condarc

# ── Matplotlib ────────────────────────────────────────────
set -gx MPLCONFIGDIR $XDG_CONFIG_HOME/matplotlib

# ── Claude Code ───────────────────────────────────────────
set -gx CLAUDE_AUTOCOMPACT_PCT_OVERRIDE 70
