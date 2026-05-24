return {
        "https://gitlab.com/david_wright/nvim-dap-image",
        dependencies = { "mfussenegger/nvim-dap", "3rd/image.nvim" },
        config       = function()
                require("nvim-dap-image").setup()
        end,
}
