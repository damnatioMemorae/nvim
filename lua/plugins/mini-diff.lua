return {
        "nvim-mini/mini.diff",
        version = false,
        event   = "VeryLazy",
        keys    = { { "<leader>g", function() MiniDiff.toggle_overlay() end } }, ---@diagnostic disable-line undefined-global
        opts    = {
                delay   = { text_change = 0 },
                view    = {
                        priority = 4000,
                        style    = "sign",
                        signs    = {
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
        config  = function(_, opts)
                require("mini.diff").setup(opts)

                local groups = {
                        { "SignAdd",        "DiffChanged" },
                        { "SignChange",     "DiffChanged" },
                        { "SignDelete",     "DiffRemoved" },
                        { "OverAdd",        "DiffAdd" },
                        { "OverChange",     "DiffChange" },
                        { "OverDelete",     "DiffDelete" },
                        { "OverContext",    "DiffText" },
                        { "OverChangeBuf",  "DiffText" },
                        { "OverContextBuf", "DiffText" },
                }
                require("core.utils").linkHl(groups, "MiniDiff")
        end,
}
