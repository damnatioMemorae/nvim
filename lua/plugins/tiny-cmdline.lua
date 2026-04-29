return {
        "rachartier/tiny-cmdline.nvim",
        event  = "VeryLazy",
        init   = function()
                vim.o.cmdheight = 0
        end,
        opts   = {
                width        = { min = 80 },
                position     = { y = "10%" },
                border       = Border.borderStyle,
                native_types = {},
        },
        config = function(_, opts)
                require("tiny-cmdline").setup(opts)
        end,
}
