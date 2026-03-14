#!/bin/bash
# Auto-switch Alacritty catppuccin theme based on macOS appearance
CONFIG="$HOME/.config/alacritty/alacritty.toml"

if [ "$(defaults read -g AppleInterfaceStyle 2>/dev/null)" = "Dark" ]; then
  THEME="catppuccin-frappe.toml"
else
  THEME="catppuccin-latte.toml"
fi

sed -i '' "s|import = .*|import = [\"~/.config/alacritty/$THEME\"]|" "$CONFIG"
