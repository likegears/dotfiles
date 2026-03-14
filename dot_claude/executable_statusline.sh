#!/usr/bin/env bash
set -euo pipefail

# ╔══════════════════════════════════════════════╗
# ║  Claude Code Statusline — Gruvbox Powerline  ║
# ║  Color flow matches starship.toml exactly     ║
# ║  Empty segments are auto-hidden               ║
# ╚══════════════════════════════════════════════╝

input=$(cat)

# ── Gruvbox Dark palette (24-bit true color) ──
RST=$'\033[0m'
BOLD=$'\033[1m'
FG0=$'\033[38;2;251;241;199m'         # #fbf1c7

BG_MAG=$'\033[48;2;177;98;134m'       # #b16286
BG_ORA=$'\033[48;2;214;93;14m'        # #d65d0e
BG_YEL=$'\033[48;2;215;153;33m'       # #d79921
BG_AQU=$'\033[48;2;104;157;106m'      # #689d6a
BG_BLU=$'\033[48;2;69;133;136m'       # #458588
BG_BG3=$'\033[48;2;102;92;84m'        # #665c54

FG_MAG=$'\033[38;2;177;98;134m'
FG_ORA=$'\033[38;2;214;93;14m'
FG_YEL=$'\033[38;2;215;153;33m'
FG_AQU=$'\033[38;2;104;157;106m'
FG_BLU=$'\033[38;2;69;133;136m'
FG_BG3=$'\033[38;2;102;92;84m'

SEP=''  # U+E0B0 Powerline right arrow

# ── Parse JSON (single jq call) ──────────────
DATA=$(echo "$input" | jq -r '[
  (.model.display_name // "Claude"),
  (.workspace.project_dir // .workspace.current_dir // ""),
  (.context_window.used_percentage // 0 | floor | tostring),
  (.cost.total_cost_usd // 0 | tostring),
  (.cost.total_duration_ms // 0 | tostring),
  (.cost.total_lines_added // 0 | tostring),
  (.cost.total_lines_removed // 0 | tostring),
  (.workspace.current_dir // ""),
  (.agent.name // ""),
  (.worktree.name // "")
] | join("\t")' 2>/dev/null) || DATA=$'Claude\t\t0\t0\t0\t0\t0\t\t\t'

IFS=$'\t' read -r MODEL PROJECT_DIR CTX_PCT COST DUR_MS LINES_ADD LINES_DEL CWD AGENT WORKTREE <<< "$DATA"

: "${MODEL:=Claude}" "${PROJECT_DIR:=}" "${CTX_PCT:=0}" "${COST:=0}" "${DUR_MS:=0}"
: "${LINES_ADD:=0}" "${LINES_DEL:=0}" "${CWD:=}" "${AGENT:=}" "${WORKTREE:=}"

# Project name (basename)
PROJECT="${PROJECT_DIR##*/}"
: "${PROJECT:=${CWD##*/}}"

# ── Derived values ────────────────────────────
COST_FMT=$(printf '%.2f' "$COST")

DUR_SEC=$(( DUR_MS / 1000 ))
if (( DUR_SEC >= 3600 )); then
  DUR_FMT="$((DUR_SEC / 3600))h$((DUR_SEC % 3600 / 60))m"
elif (( DUR_SEC >= 60 )); then
  DUR_FMT="$((DUR_SEC / 60))m$((DUR_SEC % 60))s"
else
  DUR_FMT="${DUR_SEC}s"
fi

# Context bar — 10 chars
(( CTX_PCT > 100 )) && CTX_PCT=100
FILLED=$((CTX_PCT / 10))
EMPTY=$((10 - FILLED))
BAR=""
(( FILLED > 0 )) && BAR+=$(printf "%${FILLED}s" | tr ' ' '█')
(( EMPTY  > 0 )) && BAR+=$(printf "%${EMPTY}s"  | tr ' ' '░')

# Git branch
GIT_BR=""
if [ -n "$CWD" ]; then
  GIT_BR=$(git -C "$CWD" branch --show-current 2>/dev/null) || true
fi

# ── Dynamic Powerline builder ────────────────
# Tracks previous segment's fg-color so separators chain correctly
# even when intermediate segments are skipped.
out=""
PREV_FG=""  # fg matching previous segment's bg (for  separator)

emit() {
  local bg="$1" fg="$2" content="$3"
  # draw separator from previous segment into this one
  if [ -n "$PREV_FG" ]; then
    out+="${PREV_FG}${bg}${SEP}${RST}"
  fi
  out+="${bg}${FG0}${content}${RST}"
  PREV_FG="$fg"
}

end_bar() {
  [ -n "$PREV_FG" ] && out+="${PREV_FG}${SEP}${RST}"
}

# ── Emit segments (skip empty ones) ──────────

# Always: Model (magenta)
emit "$BG_MAG" "$FG_MAG" "${BOLD} 󰚩 ${MODEL} "

# Always: Project directory (orange) — identifies which Claude instance
emit "$BG_ORA" "$FG_ORA" " ${PROJECT} "

# Always: Context % (yellow)
emit "$BG_YEL" "$FG_YEL" " ${BAR} ${CTX_PCT}% "

# Cost (aqua) — skip if $0.00
if [ "$COST_FMT" != "0.00" ]; then
  emit "$BG_AQU" "$FG_AQU" "  \$${COST_FMT} "
fi

# Duration (blue) — skip if 0s
if (( DUR_SEC > 0 )); then
  emit "$BG_BLU" "$FG_BLU" "  ${DUR_FMT} "
fi

# Lines / Git / Agent (bg3) — conditional, combined
TAIL=""
if (( LINES_ADD > 0 || LINES_DEL > 0 )); then
  TAIL=" +${LINES_ADD}/-${LINES_DEL}"
fi
if [ -n "$AGENT" ]; then
  TAIL+="  ${AGENT}"
elif [ -n "$WORKTREE" ]; then
  TAIL+="  ${WORKTREE}"
elif [ -n "$GIT_BR" ]; then
  TAIL+="  ${GIT_BR}"
fi
if [ -n "$TAIL" ]; then
  emit "$BG_BG3" "$FG_BG3" "${TAIL} "
fi

end_bar
printf '%s' "$out"
