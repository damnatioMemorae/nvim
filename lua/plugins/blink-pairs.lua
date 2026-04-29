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
                        wrap               = { ["<C-b>"] = "motion", ["<C-S-b>"] = "motion_reverse" },
                        pairs              = {
                                ["<"] = {
                                        {
                                                ">",
                                                languages = { "lua" },
                                                when      = function(ctx)
                                                        -- if vim.treesitter.get_node():type() == "string" or "string_content" then
                                                        --         return true
                                                        -- else
                                                        --         return false
                                                        -- end

                                                        -- return (ctx:text_before_cursor(2) == '"' or ctx:text_before_cursor(2) == "'")
                                                        --            or (ctx:is_after_cursor('"') or ctx:is_after_cursor("'"))
                                                        --            or ctx.char_under_cursor:match("%w")

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
