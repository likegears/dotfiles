function bt --wraps btop
    set -l f (_catppuccin_flavor)
    sed -i '' "s|color_theme = .*|color_theme = \"$HOME/.config/btop/themes/catppuccin_$f.theme\"|" \
        "$HOME/.config/btop/btop.conf"
    command btop $argv
end
