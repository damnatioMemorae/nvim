---@param module string
local function safeRequire(module)
        local success, errmsg = pcall(require, module)
        if not success then
                local msg = ("Error loading `%s`: %s"):format(module, errmsg)
                vim.defer_fn(function() vim.notify(msg, vim.log.levels.ERROR) end, 1000)
        end
end

vim.g.mapleader      = " "
vim.g.maplocalleader = "<Nop>"

safeRequire("core.Globals")
safeRequire("core.options")

if not vim.env.NO_PLUGINS then
        safeRequire("core.lazy")
        if vim.g.setColorscheme then vim.g.setColorscheme("init") end
end

safeRequire("core.commands")
safeRequire("core.autocmds")
safeRequire("core.lsp")
safeRequire("core.keymaps")
safeRequire("core.yank-paste")
safeRequire("core.backdrop-underline-fix")
-- safeRequire("functions.treesitter-diagnostics")
-- safeRequire("functions.commatose")

if os.getenv("DISPLAY") ~= nil or os.getenv("WAYLAND_DISPLAY") ~= nil then
        vim.cmd.colorscheme("catppuccin-mocha")
else
        vim.cmd.colorscheme("industry")
end
vim.schedule(function() safeRequire("functions.ui") end)
