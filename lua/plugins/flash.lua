local remote = function() require "flash".remote() end
local jump   = function() require "flash".jump() end
local inc    = function() require "flash".treesitter { actions = { ["m"] = "next", ["M"] = "prev" } } end
local first  = function() require "flash".jump { search = { mode = function(str) return "\\<" .. str end } } end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "folke/flash.nvim",
        keys = {
                { "f", jump,   mode = { "n", "x", "o" }, desc = "Flash" },
                { "F", first,  mode = { "n", "x", "o" }, desc = "Flash first" },
                { "R", remote, mode = "o",               desc = "Remote Flash" },
                { "T", inc,    mode = "o",               desc = "Treesitter Search" },
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
