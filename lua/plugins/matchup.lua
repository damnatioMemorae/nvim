local g   = vim.g
local nxo = { "n", "x", "o" }

return {
        "andymass/vim-matchup",
        event   = "BufReadPost",
        init    = function()
                g.matchup_matchparen_enabled             = 1
                g.matchup_matchparen_fallback            = 1
                g.matchup_matchparen_timeout             = 30
                g.matchup_matchparen_insert_timeout      = 30
                g.matchup_matchparen_deferred_show_delay = 300
                g.matchup_matchparen_deferred_hide_delay = 30
                g.matchup_matchparen_deferred            = 1
                g.matchup_matchparen_hi_surround_always  = 1
                g.matchup_motion_override_Npercent       = 1 ---@diagnostic disable-line: name-style-check
                g.matchup_text_obj_linewise_operators    = { "d", "y", "c" }
        end,
        keys    = {
                { "(",     "[%",   mode = nxo, remap = true },
                { ")",     "]%",   mode = nxo, remap = true },
                { "<M-g>", "z%zv", mode = nxo, remap = true },
        },
        opts    = { treesitter = { stopline = 100 } },
}
