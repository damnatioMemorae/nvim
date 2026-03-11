local function addSpace(t)
        local newT = {}

        for key, value in pairs(t) do
                newT[key] = value .. " "
        end
        return newT
end

local types = {
        "File",
        "Module",
        "Namespace",
        "Package",
        "Class",
        "Method",
        "Property",
        "Field",
        "Constructor",
        "Enum",
        "Interface",
        "Function",
        "Variable",
        "Constant",
        "String",
        "Number",
        "Boolean",
        "Array",
        "Object",
        "Keyword",
        "Null",
        "EnumMember",
        "Struct",
        "Event",
        "Operator",
        "TypeParameter",
}

return {
        "Bekaboo/dropbar.nvim",
        event        = "LspAttach",
        dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },
        keys         = { { ",w", function() require("dropbar.api").pick() end, desc = "Toggle dropbar", mode = { "n" } } },
        opts         = {
                bar     = {
                        truncate      = true,
                        pick          = { pivots = "hjklfdsa" },
                        update_events = {
                                win = {
                                        "CursorHold",
                                        "CursorHoldI",
                                        "BufModifiedSet",
                                        "CursorMoved",
                                        "CursorMovedI",
                                        "FileChangedShellPost",
                                        "LspAttach",
                                        "ModeChanged",
                                        "TextChanged",
                                        "WinEnter",
                                        "WinResized",
                                },
                                buf = {
                                        "CursorHold",
                                        "CursorHoldI",
                                        "BufModifiedSet",
                                        "FileChangedShellPost",
                                        "LspAttach",
                                        "ModeChanged",
                                        "TextChanged",
                                        "WinResized",
                                },
                        },
                },
                menu    = {
                        keymaps   = {
                                ["h"] = "<C-w>q",
                                ["i"] = function()
                                        local utils = require("dropbar.utils")
                                        local menu  = utils.menu.get_current()
                                        if not menu then
                                                return
                                        end
                                        menu:fuzzy_find_open()
                                end,
                                -- ["l"] = function()
                                --         local api = require("dropbar.api")
                                --         api.select_context_start()
                                -- end,
                                ["l"] = function()
                                        local utils = require("dropbar.utils")
                                        local menu  = utils.menu.get_current()
                                        if not menu then
                                                return
                                        end
                                        local cursor    = vim.api.nvim_win_get_cursor(menu.win)
                                        local component = menu.entries[cursor[1]]:first_clickable(cursor[2])
                                        if component then
                                                menu:click_on(component, nil, 1, "l")
                                        end
                                end,
                        },
                        scrollbar = {
                                enable     = true,
                                background = true,
                        },
                },
                sources = {
                        treesitter = { valid_types = types },
                        lsp        = { valid_types = types },
                },
                icons   = {
                        enable = true,
                        ui     = {
                                bar  = { separator = " " .. Icons.Arrows.rightArrow .. " ", extends = " " .. Icons.Misc.ellipsis .. " " },
                                menu = { separator = " ", indicator = Icons.Misc.squareFilled .. " " },
                        },
                        kinds  = { symbols = addSpace(Icons.Kinds) },
                },
        },
}
