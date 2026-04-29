local keymap = require("core.utils").uniqueKeymap

----OPTIONS-------------------------------------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("TextYankPost", {
        desc     = "User: Highlighted Yank",
        callback = function() vim.highlight.on_yank{ timeout = 100 } end,
})

keymap("n", "<C-y>", ":%y<CR>", { desc = " Yank all", silent = true })

----YANK----------------------------------------------------------------------------------------------------------------

do -- STICKY YANK
        keymap({ "n", "x" }, "y", function()
                       vim.b.preYankCursor = vim.api.nvim_win_get_cursor(0)
                       return "y"
               end, { expr = true })
        keymap("n", "Y", function()
                       vim.b.preYankCursor = vim.api.nvim_win_get_cursor(0)
                       return "y$"
               end, { expr = true, unique = false })

        vim.api.nvim_create_autocmd("TextYankPost", {
                desc = "User: Sticky yank",
                callback = function()
                        if vim.v.event.operator == "y" and vim.b.preYankCursor then
                                vim.api.nvim_win_set_cursor(0, vim.b.preYankCursor)
                                vim.b.preYankCursor = nil
                        end
                end,
        })
end

do -- YANKRING
        keymap("n", "<A-p>", '"1p', { desc = " Paste from yankring" })

        vim.api.nvim_create_autocmd("TextYankPost", {
                desc     = "User: Yankring",
                callback = function()
                        if vim.v.event.operator ~= "y" then
                                return
                        end
                        for i = 9, 1, -1 do
                                vim.fn.setreg(tostring(i), vim.fn.getreg(tostring(i - 1)))
                        end
                end,
        })
end

----KEEP THE REGISTER CLEAN---------------------------------------------------------------------------------------------

keymap({ "n", "x" }, "x", '"_x')
keymap({ "n", "x" }, "c", '"_c')
keymap("n",          "C", '"_C')
keymap("x",          "p", "P")
keymap("n", "dd", function()
               local line_empty = vim.trim(vim.api.nvim_get_current_line()) == ""
               return (line_empty and '"_dd' or "dd")
       end, { expr = true })

----PASTE---------------------------------------------------------------------------------------------------------------

keymap("n", "<C-p>", function()
               local cur_line = vim.api.nvim_get_current_line():gsub("%s*$", "")
               local reg      = vim.trim(vim.fn.getreg("+"))
               vim.api.nvim_set_current_line(cur_line .. " " .. reg)
       end, { desc = " Sticky paste at EoL" })

keymap("i", "<C-v>", function()
               local reg = vim.trim(vim.fn.getreg("+")):gsub("\n%s*$", "\n")
               vim.fn.setreg("+", reg, "v")
               return "<C-g>u<C-r><C-o>+"
       end, { desc = " Paste charwise", expr = true })

----SPECIAL YANK OPERATIONS---------------------------------------------------------------------------------------------

keymap("n", "<leader>yl", function()
               vim.ui.input({ prompt = "󰅍 Yank lines matching:" }, function(input)
                       if not input then return end
                       local lines       = vim.api.nvim_buf_get_lines(0, 0, -1, false)
                       local match_lines = vim.tbl_filter(function(l) return l:find(input, nil, true) end, lines)
                       vim.fn.setreg("+", table.concat(match_lines, "\n"))
                       local plural_s = #match_lines == 1 and "" or "s"
                       local msg      = ("%d line%s"):format(#match_lines, plural_s)
                       vim.notify(msg, nil, { title = "Copied", icon = "󰅍" })
               end)
       end, { desc = "󰦨 Lines matching pattern" })

keymap("n", "<leader>y:", function()
               local last_cmd = vim.fn.getreg(":"):gsub("^lua ?", "")
               vim.fn.setreg("+", last_cmd)
               vim.notify(last_cmd, nil, { title = "Copied", icon = "󰅍" })
       end, { desc = "󰘳 Last :excmd" })
