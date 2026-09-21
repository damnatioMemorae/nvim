local nxo   = { "n", "x", "o" }
local flash = function(_) return function(__) return function() require "flash"[_](__) end end end
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "folke/flash.nvim",
        keys = {
                { "R", flash "remote" (),                                                          mode = "o", desc = "Remote Flash" },
                { "f", flash "jump" (),                                                            mode = nxo, desc = "Flash" },
                { "F", flash "jump" { search = { mode = function(str) return "\\<" .. str end } }, mode = nxo, desc = "Flash first" },
                { "T", flash "treesitter" { actions = { ["m"] = "next", ["M"] = "prev" } },        mode = "o", desc = "Treesitter Search" },
        },
        opts = {
                jump      = { nohlsearch = true, autojump = true },
                label     = { uppercase = false, style = "overlay" },
                highlight = {
                        backdrop = true,
                        matches  = true,
                        priority = 5000,
                        groups   = {
                                label    = "CurSearch",
                                match    = "LspInlayHint",
                                current  = "LspInlayHint",
                                backdrop = "NonText",
                        },
                },
                prompt    = {
                        enabled    = false,
                        prefix     = { { Icon.Arrows.rightBig, "Special" } },
                        win_config = { border = Border.Default.None, row = 0 },
                },
                search    = { enabled = false, exclude = { "flash_prompt", "cmp_menu" } },
                remote_op = { restore = true },
                modes     = {
                        search     = { enabled = false },
                        char       = { enabled = false },
                        treesitter = { enabled = false, search = { incremental = true }, label = { style = "overlay" } },
                },
        },
}
