return {
        "rachartier/tiny-cmdline.nvim",
        event   = "VeryLazy",
        init    = function() vim.o.cmdheight = 0 end,
        opts    = {
                width        = { min = 100 },
                position     = { y = "10%" },
                border       = Border.borderStyle,
                native_types = {},
        },
        config  = function(_, opts)
                require("tiny-cmdline").setup(opts)
                local groups = {
                        { "Normal", "WildMenu" },
                        { "Border", "WildMenu" },
                }
                vim.iter(groups):each(function(group)
                        vim.api.nvim_set_hl(0, "TinyCmdLine" .. group[1], { link = group[2] })
                end)
        end,
}
