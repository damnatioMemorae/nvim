return {
        "stevearc/quicker.nvim",
        ft     = "qf",
        keys   = {
                {
                        "<",
                        function() require("quicker").expand({ before = 4, after = 4, add_to_existing = true }) end,
                        ft   = { "qf" },
                        remap = true,
                        desc = "Expand quickfix context",
                },
                {
                        ">",
                        function() require("quicker").collapse() end,
                        ft   = { "qf" },
                        remap = true,
                        desc = "Collapse quickfix context",
                },
        },
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
