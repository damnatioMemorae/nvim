return {
        "https://codeberg.org/knight9114/arc.nvim",
        event  = "VeryLazy",
        opts   = {
                layout      = "qwerty",
                hl_backdrop = "SnacksBackdrop",
                hl_label    = "DiagnosticVirtualTextError",
                keymap      = "f",
        },
        config = function(_, opts)
                require("arc").setup(opts)
        end,
}
