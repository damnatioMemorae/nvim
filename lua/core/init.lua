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
g.loaded_nvim_dir_plugin = 1

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

req
"core"
           "lazy"
           { "commands", "CmdlineEnter" }
           { "keymaps", "BufReadPre" }
           { "lsp", "BufReadPost" }
           "autocmds"
