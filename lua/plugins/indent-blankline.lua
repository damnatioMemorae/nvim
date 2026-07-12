local icons = Icon.Misc

return {
        "lukas-reineke/indent-blankline.nvim",
        event = "BufReadPre",
        main  = "ibl",
        keys  = { { "<leader>oi", Toggle.indentLines, desc = "Indent Lines - Toggle" } },
        opts  = {
                whitespace = { remove_blankline_trail = true },
                indent     = {
                        char      = " ",
                        highlight = { "Comment" },
                        tab_char  = " ",
                        priority  = 4,
                },
                scope      = {
                        show_start       = true,
                        show_end         = true,
                        show_exact_scope = false,
                        char             = icons.verticalBar,
                        highlight        = { "Function" },
                },
        },
}
