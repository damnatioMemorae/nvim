local v       = vim.v
local fn      = vim.fn
local api     = vim.api
local autocmd = api.nvim_create_autocmd
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function jump() require("flash").jump() end
local function remote() require("flash").remote() end
local function ts() require("flash").treesitter_search() end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

autocmd("CmdlineLeave", {
        callback = function()
                local ev = v.event
                if
                           (ev.cmdtype == "/") or (ev.cmdtype == "?") and (not ev.abort)
                           and (fn.searchcount().total > 1)
                then
                        vim.schedule(function() jump() end)
                end
        end,
})

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
                        prefix     = { { Icon.Arrows.rightBig, "FlashPromptIcon" } },
                        win_config = { border = Border.Default.None, row = -1 },
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
                                        if vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win)):match "BqfPreview" then
                                                return true
                                        end
                                        return not vim.api.nvim_win_get_config(win).focusable
                                end,
                        },
                },
                remote_op = { restore = true },
                modes     = { char = { enabled = false }, search = { enabled = false } },
        },
}
