return {
        "mbbill/undotree",
        lazy = true,
        keys = { { ",u", "<cmd>UndotreeToggle<cr>", desc = "Undo tree", mode = { "n" } } },
        config = function()
                vim.cmd([[
                        let g:undotree_WindowLayout = 4
                        let g:undotree_ShortIndicators = 1
                        let g:undotree_SetFocusWhenToggle = 1
                ]])
        end,
}
