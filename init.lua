if os.getenv("DISPLAY") ~= nil or os.getenv("WAYLAND_DISPLAY") ~= nil then
        vim.cmd.colorscheme("darkppuccin")
else
        vim.cmd.colorscheme("industry")
end

vim.cmd("packadd nvim.undotree")

---Safe wrapper for `require()` function
---@param module string module name
local function safeRequire(module)
        local success, errmsg = pcall(require, module)

        if not success then
                local msg = ("Error loading `%s`: %s"):format(module, errmsg)
                vim.defer_fn(function() vim.notify(msg, vim.log.levels.ERROR) end, 1000)
        end
end

safeRequire("core.Globals")
safeRequire("core.options")
safeRequire("functions.statuscol")

safeRequire("core.lsp")
safeRequire("core.ui2")

if not vim.env.NO_PLUGINS then
        safeRequire("core.lazy")
        if vim.g.setColorscheme then
                vim.g.setColorscheme("init")
        end
end

if pcall(require, "incline") then
        vim.o.laststatus = 0
        vim.o.statusline = " "
else
        safeRequire("core.statusline")
end

safeRequire("core.keymaps")
safeRequire("core.commands")
safeRequire("core.autocmds")
-- safeRequire("core.foldtext")

safeRequire("core.yank-paste")
-- safeRequire("core.backdrop-underline-fix")

-- safeRequire("functions.treesitter-diagnostics")
-- safeRequire("functions.commatose")
