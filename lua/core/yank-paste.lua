local map = require("core.utils").uniqueKeymap
------------------------------------------------------------------------------------------------------------------------
-- OPTIONS

vim.api.nvim_create_autocmd("TextYankPost", {
        desc     = "User: Highlighted Yank",
        callback = function() vim.highlight.on_yank{ timeout = 100 } end,
})

map("n", "<C-y>", ":%y<CR>", { desc = " Yank all", silent = true })

------------------------------------------------------------------------------------------------------------------------
-- STICKY YANK

do
        local cursorBefore
        map({ "n", "x" }, "y", function()
                    cursorBefore = vim.api.nvim_win_get_cursor(0)
                    return "y"
            end, { expr = true })
        map("n", "Y", function()
                    cursorBefore = vim.api.nvim_win_get_cursor(0)
                    return "y$"
            end, { expr = true, unique = false })

        vim.api.nvim_create_autocmd("TextYankPost", {
                desc     = "User: Sticky yank/delete",
                callback = function()
                        if vim.v.event.regname ~= "" or not cursorBefore then return end

                        if vim.v.event.operator == "y" then vim.api.nvim_win_set_cursor(0, cursorBefore) end
                end,
        })
end

------------------------------------------------------------------------------------------------------------------------
-- KEEP THE REGISTER CLEAN

map({ "n", "x" }, "x", '"_x')
map({ "n", "x" }, "c", '"_c')
map("n",          "C", '"_C')
map("x",          "p", "P")
map("n", "dd", function()
            local lineEmpty = vim.trim(vim.api.nvim_get_current_line()) == ""
            return (lineEmpty and '"_dd' or "dd")
    end, { expr = true })

-- PASTING
map("n", "<C-p>", function()
            local curLine = vim.api.nvim_get_current_line():gsub("%s*$", "")
            local reg     = vim.trim(vim.fn.getreg("+"))
            vim.api.nvim_set_current_line(curLine .. " " .. reg)
    end, { desc = " Sticky paste at EoL" })
map("i", "<A-v>", function()
            local reg = vim.trim(vim.fn.getreg("+")):gsub("\n%s*$", "\n")
            vim.fn.setreg("+", reg, "v")
            return "<C-g>u<C-r><C-o>+"
    end, { desc = " Paste charwise", expr = true })

--------------------------------------------------------------------------------------------------------------------
-- SPECIAL YANK OPERATIONS

map("n", "<leader>yl", function()
            vim.ui.input({ prompt = "󰅍 Yank lines matching:" }, function(input)
                    if not input then return end
                    local lines      = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                    local matchLines = vim.tbl_filter(function(l) return l:find(input, nil, true) end, lines)
                    vim.fn.setreg("+", table.concat(matchLines, "\n"))
                    local pluralS = #matchLines == 1 and "" or "s"
                    local msg     = ("%d line%s"):format(#matchLines, pluralS)
                    vim.notify(msg, nil, { title = "Copied", icon = "󰅍" })
            end)
    end, { desc = "󰦨 Lines matching pattern" })
map("n", "<leader>y:", function()
            local lastCmd = vim.fn.getreg(":"):gsub("^lua ?", "")
            vim.fn.setreg("+", lastCmd)
            vim.notify(lastCmd, nil, { title = "Copied", icon = "󰅍" })
    end, { desc = "󰘳 Last :excmd" })
