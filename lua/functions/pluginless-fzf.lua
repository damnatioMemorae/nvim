local M = {}
------------------------------------------------------------------------------------------------------------------------

function M.fzfFind(dir)
        local files = vim.fn.systemlist({ "fd", ".", dir, "-t", "f" })

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

------------------------------------------------------------------------------------------------------------------------
return M
