return {
        "saghen/blink.pairs",
        build        = function() require("blink.pairs").build():pwait(60000) end,
        event        = "BufReadPost",
        dependencies = { "saghen/blink.lib" },
        keys         = {
                { "<M-i>", "a{<CR><down>,<up><esc>i", mode = "n", desc = " Open new scope", remap = true },
                { "<M-i>", "{<CR>", mode = "i", desc = " Open new scope", remap = true },
        },
        opts         = {
                mappings = {
                        enabled            = true,
                        cmdline            = true,
                        disabled_filetypes = {},
                        wrap               = { ["<C-b>"] = "motion", ["<C-S-b>"] = "motion_reverse" },
                        pairs              = {
                                ["<"] = {
                                        {
                                                ">",
                                                languages = { "lua" },
                                                when      = function(ctx)
                                                        return ctx.ts:matches_capture("string")
                                                                   or ctx.ts:matches_capture("string_content")
                                                end,
                                        },
                                },
                        },
                },
                highlights = {
                        enabled         = true,
                        cmdline         = true,
                        groups          ={},
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
