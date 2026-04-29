return {
        "HakonHarnes/img-clip.nvim",
        keys  = { { "<leader>p", "<cmd>PasteImage<cr>", desc = "Paste image from system clipboard" } },
        opts  = {
                default = {
                        extension = "png",
                        process_cmd = "convert - -quality 75 jpg:-",
                },
        },
}
