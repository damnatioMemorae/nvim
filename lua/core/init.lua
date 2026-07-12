vim.g.mapleader      = " "
vim.g.maplocalleader = ","

if os.getenv("DISPLAY") ~= nil or os.getenv("WAYLAND_DISPLAY") ~= nil then
        vim.cmd.colorscheme("darkppuccin")
else
        vim.cmd.colorscheme("industry")
end

require("core.utils.global")

-- _G.safeRequire("core.globals.options")
_G.lazySafeRequire("core.globals.options")
_G.lazySafeRequire("core.globals.icons")
_G.lazySafeRequire("core.globals.ui")

-- _G.safeRequire("core.lsp")
_G.lazySafeRequire("core.lsp", "BufReadPost")

_G.safeRequire("loaders.functions")
_G.lazySafeRequire("loaders.options")

if not vim.env.NO_PLUGINS then
        _G.safeRequire("core.lazy")
        if vim.g.setColorscheme then
                vim.g.setColorscheme("init")
        end
end

-- _G.safeRequire("core.keymaps")
-- _G.safeRequire("core.commands")
_G.lazySafeRequire("core.keymaps",  "BufReadPost")
_G.lazySafeRequire("core.commands", "CmdlineEnter")
_G.safeRequire("core.autocmds")
