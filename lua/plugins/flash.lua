return {
        "folke/flash.nvim",
        event = "VeryLazy",
        keys  = {
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
        opts  = {
                jump   = { nohlsearch = true },
                prompt = {
                        win_config = {
                                border = Config.borderStyle,
                                row    = -3,
                        },
                },
                search = {
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
                modes  = {
                        char   = { enabled = false },
                        search = { enabled = false },
                },
        },
}
