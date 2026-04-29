local button = "Function"
local label  = "Comment"

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
                                                { "New file",                 hl = label, width = 45 },
                                                { "[",                        hl = button },
                                                { "n",                        hl = label },
                                                { "]",                        hl = button },
                                        },
                                        key     = "n",
                                        action  = "<cmd> enew <BAR> startinsert <CR>",
                                        padding = 1,
                                        align   = "center",
                                },
                                { -- RECENT FILES
                                        text    = {
                                                { Icons.Misc.recentFile .. "  ", hl = button },
                                                { "Recent files",                hl = label, width = 45 },
                                                { "[",                           hl = button },
                                                { "r",                           hl = label },
                                                { "]",                           hl = button },
                                        },
                                        key     = "r",
                                        action  = function() Snacks.picker.recent({ layout = "vertical" }) end,
                                        padding = 1,
                                        align   = "center",
                                },
                                { -- FIND FILE
                                        text    = {
                                                { Icons.Misc.findFile .. "  ", hl = button },
                                                { "Find file",                 hl = label, width = 45 },
                                                { "[",                         hl = button },
                                                { "f",                         hl = label },
                                                { "]",                         hl = button },
                                        },
                                        action  = function() Snacks.picker.files({ layout = "vertical" }) end,
                                        key     = "f",
                                        padding = 1,
                                        align   = "center",
                                },
                                { -- FIND TEXT
                                        text    = {
                                                { Icons.Misc.findText .. "  ", hl = button },
                                                { "Find text",                 hl = label, width = 45 },
                                                { "[",                         hl = button },
                                                { "w",                         hl = label },
                                                { "]",                         hl = button },
                                        },
                                        action  = function() Snacks.picker.grep({ layout = "vertical" }) end,
                                        key     = "w",
                                        padding = 1,
                                        align   = "center",
                                },
                                { -- YAZI
                                        text    = {
                                                { Icons.Kinds.Folder .. "  ", hl = button },
                                                { "Yazi",                     hl = label, width = 45 },
                                                { "[",                        hl = button },
                                                { "y",                        hl = label },
                                                { "]",                        hl = button },
                                        },
                                        action  = "<cmd>Yazi<CR>",
                                        key     = "y",
                                        padding = 1,
                                        align   = "center",
                                },
                                { -- RESTORE SESSION
                                        text    = {
                                                { Icons.Misc.restore .. "  ", hl = button },
                                                { "Restore session",          hl = label, width = 45 },
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
                                                { "Config",                  hl = label, width = 45 },
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
                                                { "Mason",                    hl = label, width = 45 },
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
                                                { "Lazy",                     hl = label, width = 45 },
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
                                                { "Update plugins",              hl = label, width = 45 },
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
                                                { "Restart",                  hl = label, width = 45 },
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
                                                { "Quit",                  hl = label, width = 45 },
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
