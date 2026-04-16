return {
        "rachartier/tiny-cmdline.nvim",
        lazy = false,
        init = function()
                vim.o.cmdheight = 0
        end,
        opts = {
                border       = Border.borderStyle,
                native_types = {},
        },
        config = function(_, opts)
                require("tiny-cmdline").setup(opts)
        end,
}
