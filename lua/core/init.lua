local g   = vim.g
local cmd = vim.cmd

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

if os.getenv "DISPLAY" ~= nil or os.getenv "WAYLAND_DISPLAY" ~= nil then
        cmd.colorscheme "darkppuccin"
else
        cmd.colorscheme "industry"
end

g.mapleader              = " "
g.maplocalleader         = ","
g.qf_mode                = "l"
g.backdrop_wins          = { "dropbar_menu", "Glance", "rip-substitute", "terminal" }
g.loaded_nvim_dir_plugin = 1

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

req
"core"
  "lazy"
  { "commands", "CmdlineEnter" }
  { "keymaps", "BufReadPre" }
  { "lsp", "BufReadPost" }
  "autocmds"
