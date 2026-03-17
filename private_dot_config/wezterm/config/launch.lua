local platform = require('utils.platform')

--- Find a shell binary by checking common install paths.
--- @param name string shell binary name (e.g. "fish", "nu")
--- @return string path the first existing path, or just the name as fallback
local function find_shell(name)
   local paths = {
      '/opt/homebrew/bin/' .. name,
      '/home/linuxbrew/.linuxbrew/bin/' .. name,
      '/usr/local/bin/' .. name,
      '/usr/bin/' .. name,
   }
   for _, p in ipairs(paths) do
      local f = io.open(p, 'r')
      if f then
         f:close()
         return p
      end
   end
   return name
end

local options = {
   default_prog = {},
   launch_menu = {},
}

if platform.is_win then
   options.default_prog = { 'pwsh', '-NoLogo' }
   options.launch_menu = {
      { label = 'PowerShell Core', args = { 'pwsh', '-NoLogo' } },
      { label = 'PowerShell Desktop', args = { 'powershell' } },
      { label = 'Command Prompt', args = { 'cmd' } },
      { label = 'Nushell', args = { 'nu' } },
      { label = 'Msys2', args = { 'ucrt64.cmd' } },
      {
         label = 'Git Bash',
         args = { 'C:\\Users\\kevin\\scoop\\apps\\git\\current\\bin\\bash.exe' },
      },
   }
else
   options.default_prog = { 'zsh', '-l' }
   options.launch_menu = {
      { label = 'Bash', args = { 'bash', '-l' } },
      { label = 'Fish', args = { find_shell('fish'), '-l' } },
      { label = 'Nushell', args = { find_shell('nu'), '-l' } },
      { label = 'Zsh', args = { 'zsh', '-l' } },
   }
end

return options
