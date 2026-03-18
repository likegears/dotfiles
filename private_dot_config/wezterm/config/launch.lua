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

--- Return the first existing path from a list.
--- @param paths string[]
--- @return string|nil
local function first_existing(paths)
   for _, p in ipairs(paths) do
      if p and p ~= '' then
         local f = io.open(p, 'r')
         if f then
            f:close()
            return p
         end
      end
   end
   return nil
end

local options = {
   default_prog = {},
   launch_menu = {},
}

if platform.is_win then
   local program_files = os.getenv('ProgramFiles')
   local local_app_data = os.getenv('LOCALAPPDATA')
   local user_profile = os.getenv('USERPROFILE')
   local git_bash = first_existing({
      program_files and (program_files .. '\\Git\\bin\\bash.exe') or nil,
      program_files and (program_files .. '\\Git\\usr\\bin\\bash.exe') or nil,
      local_app_data and (local_app_data .. '\\Programs\\Git\\bin\\bash.exe') or nil,
      user_profile and (user_profile .. '\\scoop\\apps\\git\\current\\bin\\bash.exe') or nil,
   })

   options.default_prog = { 'pwsh', '-NoLogo' }
   options.launch_menu = {
      { label = 'PowerShell Core', args = { 'pwsh', '-NoLogo' } },
      { label = 'PowerShell Desktop', args = { 'powershell' } },
      { label = 'Command Prompt', args = { 'cmd' } },
      { label = 'Nushell', args = { 'nu' } },
      { label = 'Msys2', args = { 'ucrt64.cmd' } },
   }
   if git_bash then
      table.insert(options.launch_menu, { label = 'Git Bash', args = { git_bash, '-l' } })
   end
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
