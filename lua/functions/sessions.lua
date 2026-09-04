local fn  = vim.fn
local api = vim.api
local cmd = vim.cmd

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local dir = fn.stdpath "data" .. "/sessions/"

local function path()
        local cwd = fn.getcwd()
        return dir .. cwd:gsub("/", "%%") .. ".vim"
end

function M.save()
        fn.mkdir(dir, "p")
        if vim.bo[api.nvim_get_current_buf()].filetype == "snacks_dashboard" then
                return
        end
        cmd("mksession! " .. fn.fnameescape(path()))
end

function M.restore()
        local file = path()
        if fn.filereadable(file) == 0 then
                return false
        end
        cmd("silent! source " .. fn.fnameescape(file))
        return true
end

-- api.nvim_create_autocmd("VimEnter", {
--         nested   = true,
--         callback = function()
--                 if fn.argc() == 0 then
--                         M.restore()
--                 end
--         end,
-- })

api.nvim_create_autocmd("VimLeavePre", {
        callback = M.save,
})

api.nvim_create_user_command("SessionSave",    M.save,    {})
api.nvim_create_user_command("SessionRestore", M.restore, {})

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return M
