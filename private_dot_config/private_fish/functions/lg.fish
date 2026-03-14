function lg --wraps lazygit
    set -l f (_catppuccin_flavor)
    set -lx LG_CONFIG_FILE "$HOME/.config/lazygit/config.yml,$HOME/.config/lazygit/theme-$f.yml"
    command lazygit $argv
end
