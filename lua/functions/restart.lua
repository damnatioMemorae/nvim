local v   = vim.v
local fn  = vim.fn
local fs  = vim.fs
local uv  = vim.uv
local cmd = vim.cmd

local restart_session_file = "/tmp/restart.vim"
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

smartMap({
        "<leader>r",
        function()
                cmd("silent! update")
                cmd.mksession { restart_session_file, bang = true }
                cmd.restart()
        end,
        desc = "Save & restart",
        mode = { "n", "x", "i" },
})

vim.api.nvim_create_autocmd("VimEnter", {
        callback = vim.schedule_wrap(function()
                local is_restarting        = uv.fs_stat(restart_session_file) ~= nil
                local not_opened_with_args = fn.argc(-1) == 0

                if is_restarting then
                        cmd.source(restart_session_file)
                        pcall(os.remove, restart_session_file)
                elseif not_opened_with_args then
                        local last_file = vim
                                   .iter(v.oldfiles)
                                   :find(function(file)
                                           local not_git_commit_msg = fs.basename(file) ~= "COMMIT_EDITMSG"
                                           local exists             = uv.fs_stat(file) ~= nil
                                           return exists and not_git_commit_msg
                                   end)
                        if last_file then cmd.edit(last_file) end
                end
        end),
})
