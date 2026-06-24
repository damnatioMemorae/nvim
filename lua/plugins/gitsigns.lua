return {
        "lewis6991/gitsigns.nvim",
        event  = "BufReadPre",
        keys   = {
                { -- HUNK NEXT
                        "<A-g>",
                        function() require("gitsigns").nav_hunk("next", { foldopen = true, navigation_message = false }) end,
                        desc = "Next hunk",
                },
                { -- HUNK PREV
                        "<A-G>",
                        function() require("gitsigns").nav_hunk("prev", { foldopen = true, navigation_message = false }) end,
                        desc = "Next hunk",
                },
                { -- TOGGLE BLAME
                        "<LocalLeader>g",
                        function() require("gitsigns").toggle_current_line_blame() end,
                        desc = "Line blame",
                },
                { -- PREVIEW HUNK
                        "<LocalLeader><LocalLeader>",
                        function() require("gitsigns").preview_hunk() end,
                        desc = "Preview hunk",
                },
                { -- TOGGLE INLINE
                        "<leader><leader>g",
                        function()
                                require("gitsigns").toggle_linehl()
                                require("gitsigns").toggle_word_diff()
                                require("gitsigns").toggle_deleted()
                        end,
                        desc = "Inline diff",
                },
        },
        opts   = {
                signs                           = {
                        add          = { text = "▌", show_count = false },
                        change       = { text = "🮌", show_count = false },
                        delete       = { text = "🭻", show_count = true },
                        topdelete    = { text = "🭶", show_count = true },
                        changedelete = { text = "~", show_count = true },
                        untracked    = { text = "🬐", show_count = false },
                },
                ---@type vim.api.keyset.win_config
                preview_config                  = {
                        style     = "minimal",
                        relative  = "cursor",
                        border    = Border.borderStyleNone,
                        title     = "",
                        focusable = false,
                        anchor    = "NW",
                },
                current_line_blame_formatter    = " <summary> (<author_time:%R>, <author>)) ",
                current_line_blame_formatter_nc = " +++ uncommitted ",
                current_line_blame_opts         = { virt_text_pos = "right_align", delay = 500 },
                count_chars                     = { "", "2", "3", "4", "5", "6", "7", "8", "9", ["+"] = "󰿮" },
                word_diff                       = false,
        },
        config = function(_, opts)
                require("gitsigns").setup(opts)

                local groups = {
                        { "CurrentLineBlame", "LspInlayHint" },

                        { "Add",              "Changed" },
                        { "Change",           "Changed" },
                        { "Delete",           "Removed" },
                        { "StagedAdd",        "Changed" },
                        { "StagedChange",     "Changed" },
                        { "StagedDelete",     "Removed" },
                }
                vim.iter(groups):each(function(group)
                        vim.api.nvim_set_hl(0, "GitSigns" .. group[1], { link = group[2] })
                end
                )
        end,
}
