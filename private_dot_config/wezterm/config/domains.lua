local wezterm = require('wezterm')
local platform = require('utils.platform')

local wsl_domains = {}
local default_wsl_domain = nil

if platform.is_win and wezterm.default_wsl_domains then
   wsl_domains = wezterm.default_wsl_domains()

   local preferred = os.getenv('WEZTERM_WSL_DISTRO')
   if preferred and preferred ~= '' then
      for _, domain in ipairs(wsl_domains) do
         if domain.distribution == preferred or domain.name == preferred or domain.name == ('WSL:' .. preferred) then
            default_wsl_domain = domain.name
            break
         end
      end
   end

   if not default_wsl_domain and wsl_domains[1] then
      default_wsl_domain = wsl_domains[1].name
   end
end

return {
   -- ref: https://wezfurlong.org/wezterm/config/lua/SshDomain.html
   -- ssh_domains = {},
   ssh_domains = {
      -- yazi's image preview on Windows will only work if launched via ssh from WSL
      {
         name = 'wsl.ssh',
         remote_address = 'localhost',
         multiplexing = 'None',
         default_prog = { 'fish', '-l' },
         assume_shell = 'Posix'
      }
   },

   -- ref: https://wezfurlong.org/wezterm/multiplexing.html#unix-domains
   unix_domains = {},

   -- ref: https://wezfurlong.org/wezterm/config/lua/WslDomain.html
   wsl_domains = wsl_domains,
   default_wsl_domain = default_wsl_domain,
}
