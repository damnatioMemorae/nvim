return {
        "echasnovski/mini.align",
        version = false,
        event   = "VeryLazy",
        opts    = {
                mappings = {
                        start              = Config.prefix .. "a",
                        start_with_preview = Config.prefix .. "A",
                },
                options = {
                        split_pattern   = "",
                        justify_side    = "left",
                        merge_delimiter = "",
                },
                silent = true,
        },
}
