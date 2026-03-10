return {
        "lukas-reineke/indent-blankline.nvim",
        event  = "VeryLazy",
        main   = "ibl",
        keys   = { { "<leader>oi", Toggle.indentLine, desc = "Indent Lines - Toggle" } },
        config = function()
                require("ibl").setup({
                        indent     = { char = " ", tab_char = " ", priority = 4 },
                        whitespace = { remove_blankline_trail = true },
                        scope      = {
                                show_start = true,
                                show_end   = false,
                                char       = Icons.Misc.verticalBar,
                                highlight  = { "Function" },
                        },
                })
        end,
}
