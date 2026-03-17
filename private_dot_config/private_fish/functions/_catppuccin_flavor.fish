function _catppuccin_flavor
    if test (uname) = Darwin
        if test (defaults read -g AppleInterfaceStyle 2>/dev/null) = Dark
            echo frappe
        else
            echo latte
        end
    else
        echo frappe
    end
end
