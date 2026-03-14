#!/bin/bash
# Auto-switch Catppuccin flavor to match OS appearance
# Runs on focus-in; only re-applies when appearance actually changed

case "$(uname -s)" in
  Darwin)
    [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" = "Dark" ] && WANT="frappe" || WANT="latte"
    ;;
  Linux)
    if command -v gsettings &>/dev/null; then
      [ "$(gsettings get org.gnome.desktop.interface color-scheme 2>/dev/null)" = "'prefer-dark'" ] && WANT="frappe" || WANT="latte"
    else
      WANT="frappe"
    fi
    ;;
  *)
    WANT="frappe"
    ;;
esac

HAVE=$(tmux show -gv @catppuccin_flavor 2>/dev/null)
[ "$WANT" = "$HAVE" ] && exit 0

# Step 1: Switch flavor and reload catppuccin
tmux set -g @catppuccin_flavor "$WANT"
tmux run-shell ~/.config/tmux/plugins/tmux/catppuccin.tmux

# Step 2: Re-expand status bar with new theme colors
tmux set -gF  status-left "#{E:@catppuccin_status_session}"
tmux set -gF  status-right "#{E:@catppuccin_status_application}"
tmux set -agF status-right "#{E:@catppuccin_status_directory}"
tmux set -agF status-right "#{E:@catppuccin_status_cpu}"
tmux set -agF status-right "#{E:@catppuccin_status_load}"
tmux set -agF status-right "#{E:@catppuccin_status_battery}"
tmux set -agF status-right "#{E:@catppuccin_status_uptime}"
tmux set -agF status-right "#{E:@catppuccin_status_host}"
tmux set -agF status-right "#{E:@catppuccin_status_user}"
tmux set -agF status-right "#{E:@catppuccin_status_date_time}"

# Step 3: Re-run battery/cpu plugins to interpolate their placeholders
tmux run-shell ~/.config/tmux/plugins/tmux-battery/battery.tmux
tmux run-shell ~/.config/tmux/plugins/tmux-cpu/cpu.tmux
