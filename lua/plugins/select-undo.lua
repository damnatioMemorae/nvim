return {
        "SunnyTamang/select-undo.nvim",
        event = "BufReadPre",
        opts  = {
                persistent_undo = true,
                mapping         = true,
                line_mapping    = "u",
                sweep_mapping   = "U",
                partial_mapping = "C",
                max_history     = 100,
        },
}
