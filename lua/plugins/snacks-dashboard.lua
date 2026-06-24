local button = "Function"
local label  = "Comment"
local width  = 46

local function getPicker(picker, mode)
        mode = mode or "snacks"

        local fzf_lua = pcall(require, "fzf-lua")
        local snacks  = pcall(require, "snacks")

        if snacks then
                return require(mode)[picker]()
        elseif fzf_lua then
                return require(mode)[picker]()
        end
end

local mode = "fzf-lua"
local function picker(pick)
        getPicker(pick, mode)
end

return {
        "folke/snacks.nvim",
        opts = {
                dashboard = {
                        formats  = {
                                key = function(item)
                                        return {
                                                { "[",      hl = "DropBarKindNumber" },
                                                { item.key, hl = "DropBarKindCall" },
                                                { "]",      hl = "DropBarKindNumber" },
                                        }
                                end,
                        },
                        sections = {
                                { -- LOGO
                                        text    = {
                                                {
                                                        [[
  ▄████▄       ░░░░░    ░░░░░    ░░░░░    ░░░░░
 ███▄█▀       ░ ▄░ ▄░  ░ ▄░ ▄░  ░ ▄░ ▄░  ░ ▄░ ▄░
█████  █  █   ░░░░░░░  ░░░░░░░  ░░░░░░░  ░░░░░░░
 █████▄       ░░░░░░░  ░░░░░░░  ░░░░░░░  ░░░░░░░
   ████▀      ░ ░ ░ ░  ░ ░ ░ ░  ░ ░ ░ ░  ░ ░ ░ ░
]],
                                                },
                                                hl = "Title",
                                        },
                                        align   = "center",
                                        padding = 2,
                                },
                                { -- NEW FILE
                                        text    = {
                                                { Icons.Misc.newFile .. "  ", hl = button },
                                                { "New file",                 hl = label, width = width },
                                                { "[",                        hl = button },
                                                { "n",                        hl = label },
                                                { "]",                        hl = button },
                                        },
                                        key     = "n",
                                        action  = "<cmd> enew <BAR> startinsert <CR>",
                                        padding = 1,
                                        align   = "center",
                                },
                                { -- FILE
                                        text    = {
                                                { Icons.Misc.findFile .. "  ", hl = button },
                                                { "Files",                     hl = label, width = width },
                                                { "[",                         hl = button },
                                                { "f",                         hl = label },
                                                { "]",                         hl = button },
                                        },
                                        action  = function() picker("files") end,
                                        key     = "f",
                                        padding = 1,
                                        align   = "center",
                                },
                                { -- GREP
                                        text    = {
                                                { Icons.Misc.findText .. "  ", hl = button },
                                                { "Grep",                      hl = label, width = width },
                                                { "[",                         hl = button },
                                                { "w",                         hl = label },
                                                { "]",                         hl = button },
                                        },
                                        action  = function() picker("live_grep") end,
                                        key     = "w",
                                        padding = 1,
                                        align   = "center",
                                },
                                { -- EXPLORE
                                        text    = {
                                                { Icons.Kinds.Folder .. "  ", hl = button },
                                                { "Explore",                  hl = label, width = width },
                                                { "[",                        hl = button },
                                                { "e",                        hl = label },
                                                { "]",                        hl = button },
                                        },
                                        action  = function() require("mini.files").open() end,
                                        key     = "e",
                                        padding = 1,
                                        align   = "center",
                                },
                                { -- RESTORE SESSION
                                        text    = {
                                                { Icons.Misc.restore .. "  ", hl = button },
                                                { "Restore session",          hl = label, width = width },
                                                { "[",                        hl = button },
                                                { "s",                        hl = label },
                                                { "]",                        hl = button },
                                        },
                                        key     = "s",
                                        action  = [[<cmd> lua require("persistence").load({ last  = false }) <cr>]],
                                        padding = 1,
                                        align   = "center",
                                },
                                { -- CONFIG
                                        text    = {
                                                { Icons.Misc.config .. "  ", hl = button },
                                                { "Config",                  hl = label, width = width },
                                                { "[",                       hl = button },
                                                { "c",                       hl = label },
                                                { "]",                       hl = button },
                                        },
                                        key     = "c",
                                        action  = function() Snacks.picker.files() end,
                                        padding = 1,
                                        align   = "center",
                                },
                                { -- MASON
                                        text    = {
                                                { Icons.Misc.package .. "  ", hl = button },
                                                { "Mason",                    hl = label, width = width },
                                                { "[",                        hl = button },
                                                { "l",                        hl = label },
                                                { "]",                        hl = button },
                                        },
                                        key     = "m",
                                        action  = function()
                                                require("mason"); vim.cmd("Mason")
                                        end,
                                        padding = 1,
                                        align   = "center",
                                },
                                { -- LAZY
                                        text    = {
                                                { Icons.Misc.package .. "  ", hl = button },
                                                { "Lazy",                     hl = label, width = width },
                                                { "[",                        hl = button },
                                                { "m",                        hl = label },
                                                { "]",                        hl = button },
                                        },
                                        key     = "l",
                                        action  = "<cmd> Lazy <CR>",
                                        padding = 1,
                                        align   = "center",
                                },
                                { -- UPDATE
                                        text    = {
                                                { Icons.Misc.newPackage .. "  ", hl = button },
                                                { "Update plugins",              hl = label, width = width },
                                                { "[",                           hl = button },
                                                { "u",                           hl = label },
                                                { "]",                           hl = button },
                                        },
                                        key     = "u",
                                        action  = "<cmd> Lazy update <CR>",
                                        padding = 1,
                                        align   = "center",
                                },
                                { -- RESTART
                                        text    = {
                                                { Icons.Misc.restore .. "  ", hl = button },
                                                { "Restart",                  hl = label, width = width },
                                                { "[",                        hl = button },
                                                { "r",                        hl = label },
                                                { "]",                        hl = button },
                                        },
                                        key     = "r",
                                        action  = "<cmd> restart <CR>",
                                        padding = 1,
                                        align   = "center",
                                },
                                { -- QUIT
                                        text    = {
                                                { Icons.Misc.quit .. "  ", hl = button },
                                                { "Quit",                  hl = label, width = width },
                                                { "[",                     hl = button },
                                                { "q",                     hl = label },
                                                { "]",                     hl = button },
                                        },
                                        key     = "q",
                                        action  = "<cmd> qa <CR>",
                                        padding = 2,
                                        align   = "center",
                                },
                                { -- PANE
                                        pane    = 1,
                                        section = "startup",
                                },
                        },
                },
        },
}
