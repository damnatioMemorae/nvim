return {
        "nvim-mini/mini.align",
        version = false,
        event   = "BufReadPost",
        opts    = {
                mappings = {
                        start              = "&",
                        start_with_preview = "<LocalLeader>&",
                },
                options = {
                        split_pattern   = "",
                        justify_side    = "left",
                        merge_delimiter = "",
                },
                silent = true,
        },
}
