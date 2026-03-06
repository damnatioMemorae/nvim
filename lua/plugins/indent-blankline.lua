return {
        "lukas-reineke/indent-blankline.nvim",
        enabled = true,
        event  = "VeryLazy",
        main   = "ibl",
        keys   = { { "<leader>oi", "<cmd>IBLToggle<CR>", desc = "󰖶 Indent guides", mode = { "n" } } },
        config = function()
                require("ibl").setup({
                        indent     = {
                                char     = " ",
                                tab_char = " ",
                                priority = 4,
                        },
                        whitespace = {
                                remove_blankline_trail = true,
                        },
                        scope      = {
                                show_start = true,
                                show_end   = false,
                                char       = Icons.misc.verticalBar,
                                highlight  = { "Function" },
                        },
                })
        end,
}
