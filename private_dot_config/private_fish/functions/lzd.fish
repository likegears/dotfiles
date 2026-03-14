function lzd --wraps lazydocker
    set -l f (_catppuccin_flavor)
    command cp "$HOME/.config/lazydocker/theme-$f.yml" "$HOME/.config/lazydocker/config.yml"
    command lazydocker $argv
end
