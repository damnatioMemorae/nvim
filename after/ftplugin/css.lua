vim.bo.commentstring = "/* %s */"

------------------------------------------------------------------------------------------------------------------------

_G.bufMap({
        "!",
        function()
                local line = vim.api.nvim_get_current_line()
                if line:find("!important") then
                        line = line:gsub(" ?!important", "")
                else
                        line = line:gsub(";?$", " !important;", 1)
                end
                vim.api.nvim_set_current_line(line)
        end,
        mode = "n",
        desc = " Toggle !important",
})
