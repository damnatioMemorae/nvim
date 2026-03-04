local M = {}
--------------------------------------------------------------------------------

-- fuzzy find a directory
function M.fzf_find(dir)
        -- Run fd to get file list
        local files = vim.fn.systemlist({ "fd", ".", dir, "-t", "f" })

        -- Run fzf
        vim.fn["fzf#run"]({
                source  = files,
                sink    = function(selected)
                        if selected and selected ~= "" then
                                vim.cmd("edit " .. vim.fn.fnameescape(selected))
                        end
                end,
                options = "--prompt 'Find File> '",
        })
end

--------------------------------------------------------------------------------
return M
