return {
        "HakonHarnes/img-clip.nvim",
        event = "VeryLazy",
        opts  = {
                default = {
                        extension = "png",
                        process_cmd = "convert - -quality 75 jpg:-",
                }
        },
        keys  = {
                -- suggested keymap
                { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" },
        },
}
