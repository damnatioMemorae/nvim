return {
        "folke/persistence.nvim",
        lazy = false,
        opts = {
                dir    = vim.fn.stdpath("state") .. "/sessions/",
                need   = 1,
                branch = true,
        },
}
