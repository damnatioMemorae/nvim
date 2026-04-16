return {
        "saghen/blink.pairs",
        build = "cargo build --release",
        event = { "InsertEnter", "CmdlineEnter" },
        keys  = {
                { "<A-i>", "a{<CR>", mode = "n", desc = " Open new scope", remap = true },
                { "<A-i>", "{<CR>", mode = "i", desc = " Open new scope", remap = true },
        },
        opts  = {
                mappings = {
                        enabled            = true,
                        cmdline            = true,
                        disabled_filetypes = {},
                        wrap               = {
                                ["<C-b>"]   = "motion",
                                ["<C-S-b>"] = "motion_reverse",
                        },
                        pairs              = {},
                },
                highlights = {
                        enabled         = true,
                        cmdline         = true,
                        -- groups          = { "BlinkPairsOrange", "BlinkPairsPurple", "BlinkPairsBlue" },
                        groups          = { "BlinkPairs" },
                        unmatched_group = "MatchParen",
                        matchparen      = {
                                enabled             = true,
                                cmdline             = false,
                                include_surrounding = true,
                                group               = "MatchParen",
                                priority            = 250,
                        },
                },
                debug = false,
        },
}
