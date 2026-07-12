vim.g.mapleader      = " "
vim.g.maplocalleader = ","

if os.getenv("DISPLAY") ~= nil or os.getenv("WAYLAND_DISPLAY") ~= nil then
        vim.cmd.colorscheme("darkppuccin")
else
        vim.cmd.colorscheme("industry")
end

require("core.utils.global")

_G.lazySafeRequire("core.globals.options", "BufReadPre")
_G.safeRequire("core.globals.icons")
_G.safeRequire("core.globals.ui")

_G.safeRequire("core.lsp")

_G.safeRequire("loaders.modules")
_G.safeRequire("loaders.options")

if not vim.env.NO_PLUGINS then
        _G.safeRequire("core.lazy")
        if vim.g.setColorscheme then
                vim.g.setColorscheme("init")
        end
end

_G.lazySafeRequire("core.keymaps",  "BufReadPre")
_G.lazySafeRequire("core.commands", "CmdlineEnter")
_G.safeRequire("core.autocmds")
