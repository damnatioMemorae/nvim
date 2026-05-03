return {
        "stevearc/quicker.nvim",
        ft     = "qf",
        opts   = {
                opts = {
                        number         = false,
                        relativenumber = false,
                        signcolumn     = "no",
                },
        },
        config = function(_, opts)
                require("quicker").setup(opts)
        end,
}
