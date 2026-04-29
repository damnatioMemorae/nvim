return {
        "MayaFlux/lila.nvim",
        ft           = "cpp",
        dependencies = "nvim-treesitter/nvim-treesitter",
        config       = function()
                require("lila").setup()
        end,
}
