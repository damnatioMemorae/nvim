return {
        "nvim-mini/mini.diff",
        version = false,
        event   = "VeryLazy",
        opts    = {
                view    = {
                        style = "sign",
                        signs = {
                                add    = "▐",
                                change = "🮍",
                                delete = "🭻",
                        },
                },
                options = {
                        algorithm         = "myers",
                        indent_heuristics = true,
                },
        },
}
