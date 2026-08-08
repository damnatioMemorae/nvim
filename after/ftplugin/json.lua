local api = vim.api

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

bufq { "<leader>fp", "<cmd>%! yq --output-format=json --prettyPrint<CR>", desc = " Prettify Buffer" }
bufq { "<leader>fm", "<cmd>%! yq --output-format=json --indent=0<CR>", desc = " Minify Buffer" }
bufq { "o", function()
        local line = api.nvim_get_current_line()
        if line:find "[^,[]$" then return "A,<cr>" end
        return "o"
end, expr = true, desc = " Auto-add comma on `o`" }
