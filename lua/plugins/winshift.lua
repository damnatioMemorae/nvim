return {
        "sindrets/winshift.nvim",
        keys   = { { "<leader>w", "<cmd>WinShift<CR>" } },
        opts   = {
                highlight_moving_win = true,
                focused_hl_group     = "Visual",
                moving_win_options   = { wrap = false, cursorline = false, cursorcolumn = false, colorcolumn = "" },
                keymaps              = {
                        disable_defaults = false,
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
        },
        config = function(_, opts)
                require("winshift").setup(opts)

                local groups = {
                        { "Normal",       "NormalFloat" },
                        { "FoldColumn",   "NormalFloat" },
                        { "SignColumn",   "NormalFloat" },
                        { "LineNr",       "LineNr" },
                        { "LineNrAbove",  "LineNr" },
                        { "LineNrBelow",  "LineNr" },
                        { "CursorLineNr", "CursorLineNr" },
                }
                require("core.utils").linkHl(groups, "WinShift")
        end,
}
