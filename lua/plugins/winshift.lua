return {
        "sindrets/winshift.nvim",
        event  = "VeryLazy",
        keys   = {
                -- { "<C-A-left>", "<cmd>WinShift left<CR>", mode = { "n" } },
                -- { "<C-A-down>", "<cmd>WinShift down<CR>", mode = { "n" } },
                -- { "<C-A-up>", "<cmd>WinShift up<CR>", mode = { "n" } },
                -- { "<C-A-right>", "<cmd>WinShift right<CR>", mode = { "n" } },
                { "<leader>w", "<cmd>WinShift<CR>", mode = { "n" } },
        },
        config = function()
                require("winshift").setup({
                        highlight_moving_win = true,     -- Highlight the window being moved
                        focused_hl_group     = "Visual", -- The highlight group used for the moving window
                        moving_win_options   = {
                                wrap         = false,
                                cursorline   = false,
                                cursorcolumn = false,
                                colorcolumn  = "",
                        },
                        keymaps              = {
                                disable_defaults = false, -- Disable the default keymaps
                                win_move_mode    = {
                                        ["h"]         = "left",
                                        ["j"]         = "down",
                                        ["k"]         = "up",
                                        ["l"]         = "right",
                                        ["H"]         = "far_left",
                                        ["J"]         = "far_down",
                                        ["K"]         = "far_up",
                                        ["L"]         = "far_right",
                                        ["<left>"]    = "left",
                                        ["<down>"]    = "down",
                                        ["<up>"]      = "up",
                                        ["<right>"]   = "right",
                                        ["<S-left>"]  = "far_left",
                                        ["<S-down>"]  = "far_down",
                                        ["<S-up>"]    = "far_up",
                                        ["<S-right>"] = "far_right",
                                },
                        },
                        window_picker        = function()
                                return require("winshift.lib").pick_window({
                                        picker_chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890",
                                        filter_rules = {
                                                cur_win  = true,
                                                floats   = true,
                                                filetype = { "neo-tree", "Outline", "Alpha" },
                                                buftype  = {},
                                                bufname  = {},
                                        },
                                        filter_func  = nil,
                                })
                        end,
                })
        end,
}
