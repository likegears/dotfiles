function zj --wraps zellij
    if test (defaults read -g AppleInterfaceStyle 2>/dev/null) = Dark
        set -l theme catppuccin-mocha-vivid
    else
        set -l theme catppuccin-frappe-vivid
    end
    command zellij options --theme $theme 2>/dev/null
    command zellij $argv
end
