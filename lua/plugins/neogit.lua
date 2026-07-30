return {
        "NeogitOrg/neogit",
        dependencies = { "esmuellert/codediff.nvim", "folke/snacks.nvim" },
        cmd          = "Neogit",
        keys         = { { "<leader>gg", "<cmd>Neogit<cr>", desc = "Show Neogit UI" } },
        opts         = {
                kind     = "floating",
                floating = {
                        relative = "editor",
                        width    = 0.8,
                        height   = 0.7,
                        style    = "minimal",
                        border   = "single",
                },
        },
}
