local prefix = "<LocalLeader>"

return {
        "echasnovski/mini.align",
        version = false,
        event   = "VeryLazy",
        opts    = {
                mappings = {
                        start              = prefix .. "a",
                        start_with_preview = prefix .. "A",
                },
                options = {
                        split_pattern   = "",
                        justify_side    = "left",
                        merge_delimiter = "",
                },
                silent = true,
        },
}
