local M = {}
------------------------------------------------------------------------------------------------------------------------

function M.createWindow()
        local max_height = vim.api.nvim_win_get_height(0)
        local max_width  = vim.api.nvim_win_get_width(0)

        local height = math.floor(max_height * 0.8)
        local width  = math.floor(max_width * 0.8)

        local buf            = vim.api.nvim_create_buf(false, true)
        vim.bo[buf].filetype = "terminal"
        vim.api.nvim_open_win(buf, true, {
                relative = "editor",
                border   = Border.borderStyle,
                height   = height,
                width    = width,
                col      = (max_width - width) * 0.5,
                row      = (max_height - height) * 0.5,
        })
end

function M.createTerm()
        M.createWindow()
        vim.cmd.term("zsh")
        -- vim.cmd("startinsert")
end

------------------------------------------------------------------------------------------------------------------------
return M
