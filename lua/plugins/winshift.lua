linq
"Winshift"
  { "Normal", "NormalFloat" }
  { "FoldColumn", "NormalFloat" }
  { "SignColumn", "NormalFloat" }
  { "LineNr", "LineNr" }
  { "LineNrAbove", "LineNr" }
  { "LineNrBelow", "LineNr" }
  { "CursorLneNr", "CursorLineNr" }

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "sindrets/winshift.nvim",
        keys = { { "<leader>w", "<cmd>WinShift<CR>" } },
        opts = {
                highlight_moving_win = true,
                focused_hl_group     = "NormalFloat",
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
                                ["<left>"]    = function() require "smart-splits".resize_left() end,
                                ["<down>"]    = function() require "smart-splits".resize_down() end,
                                ["<up>"]      = function() require "smart-splits".resize_up() end,
                                ["<right>"]   = function() require "smart-splits".resize_right() end,
                                ["<S-left>"]  = "far_left",
                                ["<S-down>"]  = "far_down",
                                ["<S-up>"]    = "far_up",
                                ["<S-right>"] = "far_right",
                        },
                },
        },
}
