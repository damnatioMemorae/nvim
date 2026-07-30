local api = vim.api

local map = _G.bufMap

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

map({
        "<leader>fp",
        "<cmd>%! yq --output-format=json --prettyPrint<CR>",
        mode = "n",
        desc = " Prettify Buffer",
})

map({
        "<leader>fm",
        "<cmd>%! yq --output-format=json --indent=0<CR>",
        mode = "n",
        desc = " Minify Buffer",
})

map({
        "o",
        function()
                local line = api.nvim_get_current_line()
                if line:find("[^,{[]$") then return "A,<cr>" end
                return "o"
        end,
        mode = "n",
        expr = true,
        desc = " Auto-add comma on `o`",
})
