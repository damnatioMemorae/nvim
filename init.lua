vim.g.mapleader      = " "
vim.g.maplocalleader = ","

if os.getenv("DISPLAY") ~= nil or os.getenv("WAYLAND_DISPLAY") ~= nil then
        vim.cmd.colorscheme("darkppuccin")
else
        vim.cmd.colorscheme("industry")
end

require("core.utils")

_G.safeRequire("core.globals")
-- _G.safeRequire("core.restart")
_G.safeRequire("functions.statuscol")
_G.safeRequire("functions.backdrop")

_G.safeRequire("core.lsp")
_G.safeRequire("functions.ui2")
_G.safeRequire("functions.statusline")
_G.safeRequire("loaders.options")

_G.safeRequire("core.toggle")
if not vim.env.NO_PLUGINS then
        _G.safeRequire("core.lazy")
        if vim.g.setColorscheme then
                vim.g.setColorscheme("init")
        end
end

_G.safeRequire("core.keymaps")
_G.safeRequire("core.commands")
_G.safeRequire("core.autocmds")
-- _G.safeRequire("core.foldtext")

-- _G.safeRequire("core.backdrop-underline-fix")

-- _G.safeRequire("functions.treesitter-diagnostics")
-- _G.safeRequire("functions.commatose")
