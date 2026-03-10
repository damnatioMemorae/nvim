return {
        "nvim-treesitter/nvim-treesitter-context",
        event  = "VeryLazy",
        config = function()
                require("treesitter-context").setup{
                        enable              = true,
                        multiwindow         = false,
                        max_lines           = 2,
                        min_window_height   = 1,
                        line_numbers        = true,
                        multiline_threshold = 20,
                        trim_scope          = "outer",
                        mode                = "cursor",
                        separator           = nil,
                        zindex              = 20,
                        on_attach           = nil,
                }

                vim.api.nvim_set_hl(0, "TreesitterContextLineNumberBottom", { underline = false })
                vim.api.nvim_set_hl(0, "TreesitterContextBottom",           { underline = false })

                vim.keymap.set("n", ",t", function()
                                       require("treesitter-context").go_to_context(vim.v.count1)
                               end, { silent = true })
        end,
}
