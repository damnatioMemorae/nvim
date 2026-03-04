return {
        {
                "folke/persistence.nvim",
                lazy = false,
                opts = {
                        dir    = vim.fn.stdpath("state") .. "/sessions/",
                        need   = 1,
                        branch = true,
                },
        },
        {
                "OXY2DEV/helpview.nvim",
                lazy = false,
        },
        {
                "anuvyklack/keymap-amend.nvim",
                event = "VeryLazy",
        },
}
