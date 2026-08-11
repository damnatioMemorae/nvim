local v  = vim.v
local fn = vim.fn

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function jump() require "flash".jump() end
local function remote() require "flash".remote() end
local function ts() require "flash".treesitter_search() end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

auq "CmdlineLeave" {
        callback = function()
                local ev = v.event
                if (ev.cmdtype == "?") and (not ev.abort) and (fn.searchcount().total > 1) then
                        vim.schedule(function() jump() end)
                end
        end,
}

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "folke/flash.nvim",
        keys = {
                { "f", jump,   mode = { "n", "x", "o" }, desc = "Flash" },
                { "R", remote, mode = "o",               desc = "Remote Flash" },
                { "r", ts,     mode = "o",               desc = "Treesitter Search" },
        },
        opts = {
                jump      = { nohlsearch = true, autojump = true },
                label     = { uppercase = false },
                highlight = {
                        backdrop = true,
                        matches  = true,
                        priority = 5000,
                        groups   = {
                                match    = "Comment",
                                current  = "NonText",
                                backdrop = "NonText",
                                label    = "Type",
                        },
                },
                prompt    = {
                        prefix     = { { Icon.Arrows.rightBig, "Special" } },
                        win_config = { border = Border.Default.None, row = 0 },
                },
                search    = {
                        enabled = false,
                        exclude = { "flash_prompt", "cmp_menu" },
                },
                remote_op = { restore = true },
                modes     = { char = { enabled = false }, search = { enabled = false } },
        },
}
