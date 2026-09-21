return {
        "nvim-mini/mini.align",
        version = false,
        event   = "BufReadPost",
        opts    = {
                mappings = {
                        start              = "sl",
                        start_with_preview = "sL",
                },
                options = {
                        split_pattern   = "",
                        justify_side    = "left",
                        merge_delimiter = "",
                },
                silent = true,
        },
}
