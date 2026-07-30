local g   = vim.g
local cmd = vim.cmd

require("core.utils.global")
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

if os.getenv("DISPLAY") ~= nil or os.getenv("WAYLAND_DISPLAY") ~= nil then
        cmd.colorscheme("darkppuccin")
else
        cmd.colorscheme("industry")
end

g.mapleader      = " "
g.maplocalleader = ","
-- g.loaded_nvim_dir_plugin = 1

_G.req
"core.globals" "options" "icons" "ui"

-- _G.q(_G.req)
-- "core.globals" "options" "icons" "ui"

_G.req
"loaders" "options" "functions"

if not vim.env.NO_PLUGINS then
        _G.req "core" "lazy"
        if g.setColorscheme then g.setColorscheme("init") end
end

_G.req
"core"
           { "commands", "CmdlineEnter" }
           { "keymaps", "BufReadPost" }
           { "lsp", "BufReadPost" }
           "autocmds"
