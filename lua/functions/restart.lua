local restartSessionFile = "/tmp/restart.vim"
------------------------------------------------------------------------------------------------------------------------

smartMap({
        "<leader>r",
        function()
                vim.cmd("silent! update")
                vim.cmd.mksession{ restartSessionFile, bang = true }
                vim.cmd.restart()
        end,
        desc = "Save & restart",
        mode = { "n", "x", "i" },
})

vim.api.nvim_create_autocmd("VimEnter", {
        callback = vim.schedule_wrap(function()
                local is_restarting        = vim.uv.fs_stat(restartSessionFile) ~= nil
                local not_opened_with_args = vim.fn.argc(-1) == 0

                if is_restarting then
                        vim.cmd.source(restartSessionFile)
                        pcall(os.remove, restartSessionFile)
                elseif not_opened_with_args then
                        local last_file = vim.iter(vim.v.oldfiles):find(function(file)
                                local not_git_commit_msg = vim.fs.basename(file) ~= "COMMIT_EDITMSG"
                                local exists             = vim.uv.fs_stat(file) ~= nil
                                return exists and not_git_commit_msg
                        end)
                        if last_file then vim.cmd.edit(last_file) end
                end
        end),
})
