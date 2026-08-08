local bo = vim.bo

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

bo.commentstring = "/* %s */"

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

bufq { "!", function()
        local line = vim.api.nvim_get_current_line()
        cond(
                line:find "!important", function()
                        line = line:gsub(" ?!important", "")
                end)(function()
                           line = line:gsub(";?$", " !important;", 1)
                   end)
        vim.api.nvim_set_current_line(line)
end, mode = "n", desc = "Toggle !important" }
