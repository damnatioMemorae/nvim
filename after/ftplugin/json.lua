_G.bufMap({
        "<leader>fp",
        "<cmd>%! yq --output-format=json --prettyPrint<CR>",
        mode = "n",
        desc = " Prettify Buffer",
})

_G.bufMap({
        "<leader>fm",
        "<cmd>%! yq --output-format=json --indent=0<CR>",
        mode = "n",
        desc = " Minify Buffer",
})

_G.bufMap({
        "o",
        function()
                local line = vim.api.nvim_get_current_line()
                if line:find("[^,{[]$") then return "A,<cr>" end
                return "o"
        end,
        mode = "n",
        expr = true,
        desc = " Auto-add comma on `o`",
})
