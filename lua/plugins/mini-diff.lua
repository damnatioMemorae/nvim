return {
        "nvim-mini/mini.diff",
        version = false,
        event   = "BufReadPre",
        keys    = { { "<leader>g", function() require("mini.diff").toggle_overlay() end } },
        opts    = {
                delay   = { text_change = 0 },
                view    = {
                        priority = 4000,
                        style    = "sign",
                        signs    = { add = "▐", change = "🮍", delete = "🭻" },
                },
                options = { algorithm = "myers", indent_heuristics = true },
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
