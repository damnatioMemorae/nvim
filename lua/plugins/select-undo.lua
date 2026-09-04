return {
        "SunnyTamang/select-undo.nvim",
        event = "BufReadPost",
        keys  = {
                { "u", "<cmd>SelectUndoLine<CR>gv",    mode = "v" },
                { "U", "<cmd>SelectUndoSweep<CR>gv",   mode = "v" },
                { "C", "<cmd>SelectUndoPartial<CR>gv", mode = "v" },
        },
        opts  = {
                line_mapping    = "u",
                sweep_mapping   = "U",
                partial_mapping = "C",
                max_history     = 500,
                persistent_undo = true,
                mapping         = false,
        },
}
