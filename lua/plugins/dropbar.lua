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

local function addSpace(t)
        local new_t = {}

        for key, value in pairs(t) do
                new_t[key] = value .. " "
        end

        return new_t
end

return {
        "Bekaboo/dropbar.nvim",
        enabled      = false,
        event        = "BufReadPre",
        dependencies = { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
        keys         = { { "<LocalLeader>w", function() require("dropbar.api").pick() end, desc = "Toggle dropbar", mode = { "n" } } },
        opts         = {
                bar     = {
                        truncate      = true,
                        pick          = { pivots = "hjklfdsa" },
                        padding       = { left = 1, right = 2 },
                        gc            = { interval = 1000 },
                        hover         = true,
                        sources       = function(buf, _)
                                local sources = require("dropbar.sources")
                                local utils   = require("dropbar.utils")

                                if vim.bo[buf].ft == "neo-tree" or vim.bo[buf].ft == "Outline" then
                                        return {}
                                end

                                if vim.bo[buf].ft == "markdown" then
                                        return { sources.path, sources.markdown }
                                end

                                if vim.bo[buf].buftype == "terminal" then
                                        return { sources.terminal }
                                end

                                return { sources.path, utils.source.fallback({ sources.lsp }) }
                        end,
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
                        quick_navigation = true,
                        scrollbar        = { enable = false, background = true },
                        win_configs      = { style = "minimal", border = Border.borderStyleNone },
                        keymaps          = {
                                ["<Esc>"] = "<C-w>q",
                                ["h"]     = "<C-w>q",
                                ["i"]     = function()
                                        local utils = require("dropbar.utils")
                                        local menu  = utils.menu.get_current()
                                        if not menu then
                                                return
                                        end
                                        menu:fuzzy_find_open()
                                end,
                                ["l"]     = function()
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
                },
                fzf     = { prompt = " %#Special#> " },
                icons   = {
                        enable = true,
                        ui     = {
                                bar  = { separator = " " .. Icons.Arrows.rightBig .. " ", extends = " " .. Icons.Misc.ellipsis .. " " },
                                menu = { separator = " ", indicator = Icons.Misc.squareFilled .. " " },
                        },
                        kinds  = { symbols = addSpace(Icons.Kinds) },
                },
                sources = {
                        path = {
                                max_depth = 2,
                                modified  = function(sym)
                                        return sym:merge({
                                                name    = sym.name .. " ",
                                                icon    = " ",
                                                name_hl = "LspInlayHint",
                                                icon_hl = "LspInlayHint",
                                        })
                                end,
                        },
                        lsp  = { valid_types = types },
                },
        },
        config       = function(_, opts)
                require("dropbar").setup(opts)
                vim.ui.select = require("dropbar.utils.menu").select

                local groups = {
                        ---- DROPBAR -----------------------------------------------------------------------------------

                        { "Hover",                     "Visual" },
                        { "FzfMatch",                  "Special" },
                        { "CurrentContext",            "Visual" },
                        { "Preview",                   "PmenuSbar" },

                        ---- DROPBAR-ICON-UI ---------------------------------------------------------------------------

                        { "IconUiIndicator",           "NonText" },
                        { "IconUiSeparator",           "NonText" },
                        { "MenuCurrentContext",        "Visual" },
                        { "MenuHoverEntry",            "Visual" },
                        { "MenuHoverIcon",             "IncSearch" },
                        { "MenuHoverSymbol",           "Visual" },
                        { "MenuFloatBorder",           "DropBarMenuNormalFloat" },
                        { "MenuNormalFloat",           "WinBar" },
                        { "MenuSbar",                  "PmenuSbar" },
                        { "MenuThumb",                 "PmenuThumb" },
                        { "IconKindDefaultNC",         "WinBarNC" },

                        ---- DROPBAR KIND ------------------------------------------------------------------------------

                        { "KindDefault",               "Comment" },
                        { "KindArray",                 "Comment" },
                        { "KindBoolean",               "Comment" },
                        { "KindBreakstatement",        "Comment" },
                        { "KindCall",                  "Comment" },
                        { "KindCasestatement",         "Comment" },
                        { "KindClass",                 "Comment" },
                        { "KindConstant",              "Comment" },
                        { "KindConstructor",           "Comment" },
                        { "KindContinuestatement",     "Comment" },
                        { "KindDeclaration",           "Comment" },
                        { "KindDelete",                "Comment" },
                        { "KindDir",                   "Comment" },
                        { "KindDostatement",           "Comment" },
                        { "KindElsestatement",         "Comment" },
                        { "KindElement",               "Comment" },
                        { "KindEnum",                  "Comment" },
                        { "KindEnumMember",            "Comment" },
                        { "KindEvent",                 "Comment" },
                        { "KindField",                 "Comment" },
                        { "KindFile",                  "Comment" },
                        { "KindFolder",                "Comment" },
                        { "KindForStatement",          "Comment" },
                        { "KindFunction",              "Comment" },
                        { "KindH1Marker",              "Comment" },
                        { "KindH2Marker",              "Comment" },
                        { "KindH3Marker",              "Comment" },
                        { "KindH4Marker",              "Comment" },
                        { "KindH5Marker",              "Comment" },
                        { "KindH6Marker",              "Comment" },
                        { "KindIdentifier",            "Comment" },
                        { "KindIfStatement",           "Comment" },
                        { "KindInterface",             "Comment" },
                        { "KindKeyword",               "Comment" },
                        { "KindList",                  "Comment" },
                        { "KindMacro",                 "Comment" },
                        { "KindMarkdownH1",            "Comment" },
                        { "KindMarkdownH2",            "Comment" },
                        { "KindMarkdownH3",            "Comment" },
                        { "KindMarkdownH4",            "Comment" },
                        { "KindMarkdownH5",            "Comment" },
                        { "KindMarkdownH6",            "Comment" },
                        { "KindMethod",                "Comment" },
                        { "KindModule",                "Comment" },
                        { "KindNamespace",             "Comment" },
                        { "KindNull",                  "Comment" },
                        { "KindNumber",                "Comment" },
                        { "KindObject",                "Comment" },
                        { "KindOperator",              "Comment" },
                        { "KindPackage",               "Comment" },
                        { "KindPair",                  "Comment" },
                        { "KindProperty",              "Comment" },
                        { "KindReference",             "Comment" },
                        { "KindRepeat",                "Comment" },
                        { "KindReturn",                "Comment" },
                        { "KindRuleset",               "Comment" },
                        { "KindScope",                 "Comment" },
                        { "KindSpecifier",             "Comment" },
                        { "KindStatement",             "Comment" },
                        { "KindString",                "Comment" },
                        { "KindStruct",                "Comment" },
                        { "KindSwitchstatement",       "Comment" },
                        { "KindTerminal",              "Comment" },
                        { "KindType",                  "Comment" },
                        { "KindTypeParameter",         "Comment" },
                        { "KindUnit",                  "Comment" },
                        { "KindValue",                 "Comment" },
                        { "KindVariable",              "Comment" },
                        { "KindWhileStatement",        "Comment" },

                        ---- DROPBAR ICON KIND -------------------------------------------------------------------------

                        { "IconKindDefault",           "WinBar" },
                        { "IconKindArray",             "@string" },
                        { "IconKindBoolean",           "@lsp.type.boolean" },
                        { "IconKindBreakstatement",    "DiagnosticError" },
                        { "IconKindCall",              "@function.call" },
                        { "IconKindCasestatement",     "Conditional" },
                        { "IconKindClass",             "@lsp.type.class" },
                        { "IconKindConstant",          "@constant" },
                        { "IconKindConstructor",       "@constructor" },
                        { "IconKindContinuestatement", "Conditional" },
                        { "IconKindDeclaration",       "@lsp.type.type" },
                        { "IconKindDelete",            "DiagnosticError" },
                        { "IconKindDir",               "Function" },
                        { "IconKindDostatement",       "@keyword" },
                        { "IconKindElsestatement",     "Conditional" },
                        { "IconKindElement",           "@variable.builtin" },
                        { "IconKindEnum",              "@lsp.type.enum" },
                        { "IconKindEnumMember",        "@lsp.type.enumMember" },
                        { "IconKindEvent",             "@lsp.type.event" },
                        { "IconKindField",             "@field" },
                        { "IconKindFile",              "Comment" },
                        { "IconKindFolder",            "Directory" },
                        { "IconKindForStatement",      "@keyword.repeat" },
                        { "IconKindFunction",          "@lsp.type.function" },
                        { "IconKindH1Marker",          "MarkdownH1" },
                        { "IconKindH2Marker",          "MarkdownH2" },
                        { "IconKindH3Marker",          "MarkdownH3" },
                        { "IconKindH4Marker",          "MarkdownH4" },
                        { "IconKindH5Marker",          "MarkdownH5" },
                        { "IconKindH6Marker",          "MarkdownH6" },
                        { "IconKindIdentifier",        "Identifier" },
                        { "IconKindIfStatement",       "Conditional" },
                        { "IconKindInterface",         "@lsp.type.interface" },
                        { "IconKindKeyword",           "@lsp.type.keyword" },
                        { "IconKindList",              "@markup.list" },
                        { "IconKindMacro",             "@lsp.type.macro" },
                        { "IconKindMarkdownH1",        "MarkdownH1" },
                        { "IconKindMarkdownH2",        "MarkdownH2" },
                        { "IconKindMarkdownH3",        "MarkdownH3" },
                        { "IconKindMarkdownH4",        "MarkdownH4" },
                        { "IconKindMarkdownH5",        "MarkdownH5" },
                        { "IconKindMarkdownH6",        "MarkdownH6" },
                        { "IconKindMethod",            "@lsp.type.method" },
                        { "IconKindModule",            "@module" },
                        { "IconKindNamespace",         "@lsp.type.namespace" },
                        { "IconKindNull",              "@lsp.type.boolean" },
                        { "IconKindNumber",            "@lsp.type.number" },
                        { "IconKindObject",            "@keyword.function" },
                        { "IconKindOperator",          "@lsp.type.operator" },
                        { "IconKindPackage",           "Conditional" },
                        { "IconKindPair",              "@keyword" },
                        { "IconKindProperty",          "@property" },
                        { "IconKindReference",         "@keyword" },
                        { "IconKindRepeat",            "@keyword.repeat" },
                        { "IconKindReturn",            "@keyword.return" },
                        { "IconKindRuleset",           "@include" },
                        { "IconKindScope",             "@include" },
                        { "IconKindSpecifier",         "@include" },
                        { "IconKindStatement",         "Statement" },
                        { "IconKindString",            "@string" },
                        { "IconKindStruct",            "@lsp.type.struct" },
                        { "IconKindSwitchstatement",   "Conditional" },
                        { "IconKindTerminal",          "@string" },
                        { "IconKindType",              "@lsp.type.type" },
                        { "IconKindTypeParameter",     "@lsp.type.typeParameter" },
                        { "IconKindUnit",              "@keyword" },
                        { "IconKindValue",             "@text" },
                        { "IconKindVariable",          "@lsp.type.variable" },
                        { "IconKindWhileStatement",    "@keyword.repeat" },
                }
                require("core.utils").linkHl(groups, "DropBar")
        end,
}
