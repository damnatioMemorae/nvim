return {
        "folke/flash.nvim",
        keys = {
                {
                        "f",
                        mode = { "n", "x", "o" },
                        function() require("flash").jump() end,
                        desc = "Flash",
                },
                {
                        "R",
                        mode = "o",
                        function() require("flash").remote() end,
                        desc = "Remote Flash",
                },
                {
                        "r",
                        mode = "o",
                        function() require("flash").treesitter_search() end,
                        desc = "Treesitter Search",
                },
        },
        opts = {
                jump      = { nohlsearch = true, autojump = true },
                label     = { uppercase = false },
                prompt    = {
                        prefix     = { { Icons.Arrows.rightArrow, "FlashPromptIcon" } },
                        win_config = { border = Border.borderStyleNone, row = -1 },
                },
                search    = {
                        enabled = false,
                        exclude = {
                                "flash_prompt",
                                "qf",
                                "notify",
                                "cmp_menu",
                                "noice",
                                "flash_prompt",
                                function(win)
                                        if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)):match"BqfPreview" then
                                                return true
                                        end
                                        return not vim.api.nvim_win_get_config(win).focusable
                                end,
                        },
                },
                remote_op = { restore = true },
                modes     = { char = { enabled = false }, search = { enabled = false } },
        },
        config = function(_, opts)
                require("flash").setup(opts)

                vim.api.nvim_set_hl(0, "FlashBackdrop", { link = "NonText" })
                vim.api.nvim_set_hl(0, "FlashMatch",    { link = "LspInlayHint" })
                vim.api.nvim_set_hl(0, "FlashCurrent",  { link = "LspInlayHint" })
                vim.api.nvim_set_hl(0, "FlashLabel",    { link = "DiagnosticVirtualTextInfo" })
        end,
}
