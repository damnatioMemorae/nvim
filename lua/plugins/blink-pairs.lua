return {
        "saghen/blink.pairs",
        build        = function() require "blink.pairs".build():pwait(60000) end,
        event        = "BufReadPost",
        dependencies = { "saghen/blink.lib" },
        opts         = {
                mappings = {
                        enabled            = true,
                        cmdline            = false,
                        disabled_filetypes = { "rip-substitute" },
                        wrap               = { ["<C-b>"] = "motion", ["<C-S-b>"] = "motion_reverse" },
                        pairs              = {
                                ["<"] = {
                                        {
                                                ">",
                                                languages = { "lua" },
                                                when      = function(ctx)
                                                        return ctx.ts:matches_capture "string"
                                                            or ctx.ts:matches_capture "string_content"
                                                end,
                                        },
                                },
                        },
                },
                highlights = {
                        enabled         = true,
                        cmdline         = false,
                        groups          = {},
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
