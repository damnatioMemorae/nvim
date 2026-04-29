local groups = {
        { "Title",                "DiagnosticError" },

        { "PickerTitle",          "DiagnosticError" },
        { "Picker",               "Normal" },
        { "PickerBorder",         "borderStyle" },
        { "PickerListCursorLine", "Visual" },
        { "PickerCursorLine",     "TinyInlineDiagnosticVirtualTextError" },
        { "PickerSelected",       "Error" },
        { "PickerIconFile",       "BlinkCmpKindFile" },

        { "PickerUndoAdded",      "SnacksDiffAdd" },
        { "PickerUndoSaved",      "SnacksDiffContext" },
        { "PickerUndoRemoved",    "SnacksDiffDelete" },
        { "PickerUndoCurrent",    "DiffText" },

        { "DiffAdded",            "DiffAdd" },
        { "DiffSaved",            "DiffChange" },
        { "DiffRemoved",          "DiffDelete" },
        { "DiffCurrent",          "DiffText" },
}
require("core.utils").linkHl(groups, "Snacks")

local border = Border.borderStyle
local none   = Border.borderStyleNone
local top    = Border.borderTop
local bot    = Border.borderBottom

local loaded, _ = pcall(require, "snacks")
local toggle    = Snacks.toggle

if loaded then
        toggle.option("relativenumber", { name = " Relative Line Number", global = true }):map("<leader>or")
        toggle.option("number", { name = " Line Number", global = true }):map("<leader>on")
        toggle.option("wrap", { name = "󰖶 Wrap", global = true }):map("<leader>ow")
        toggle.treesitter({ name = " Treesitter Highlight" }):map("<leader>ot")
end

return {
        "folke/snacks.nvim",
        lazy     = false,
        priority = 1000,
        keys     = {
                -- { "<A-b>",      function() Snacks.bufdelete() end,          desc = "Delete Buffer" },
                { "<A-b>",      "<cmd>b #<CR>",                             desc = "Swap buffer" },
                { "<leader>fr", function() Snacks.rename.rename_file() end, desc = "Rename File" },
                { "<leader>lg", function() Snacks.lazygit() end,            desc = "Lazygit" },
        },
        opts     = {
                quickfile = { enabled = true },
                lazygit   = { enabled = true },
                input     = { enabled = true, icon = "" },
                indent    = {
                        indent  = { enabled = false, char = "", only_scope = true },
                        animate = { enabled = false },
                        chunk   = { enabled = false, only_current = false },
                        scope   = { enabled = false, char = "▏", underline = true, only_current = true, hl = "Function" },
                },
                scope     = {
                        enabled    = true,
                        min_size   = 2,
                        cursor     = false,
                        siblings   = false,
                        treesitter = {
                                enabled      = true,
                                injections   = true,
                                field_blocks = { "local_declaration" },
                                blocks       = {
                                        enabled = true,
                                        "function_declaration",
                                        "function_definition",
                                        "method_declaration",
                                        "method_definition",
                                        "class_declaration",
                                        "class_definition",
                                        "do_statement",
                                        "while_statement",
                                        "repeat_statement",
                                        "if_statement",
                                        "for_statement",
                                },
                        },
                },
                win       = {
                        border = border,
                        wo     = {
                                signcolumn     = "no",
                                statuscolumn   = " ",
                                winbar         = "",
                                number         = false,
                                relativenumber = false,
                                cursorcolumn   = false,
                        },
                },
                styles    = {
                        notification_history = {
                                border   = border,
                                height   = 0.9,
                                width    = 0.9,
                                title    = "",
                                titlepos = "left",
                                fg       = "markdown",
                                bo       = { filetype = "Snacks.notif_history", modifiable = false },
                                wo       = { winhighlight = "Normal:SnacksNotifierHistory,FloatBorder:SnacksNotifierHistoryBorder" },
                        },
                        input                = {
                                backdrop = true,
                                border   = border,
                                row      = math.ceil(vim.o.lines / 10),
                                b        = { completion = true },
                                width    = 80,
                                wo       = {
                                        cursorline   = false,
                                        winhighlight =
                                        "NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle",
                                },
                        },
                        blame_line           = {
                                backdrop = true,
                                width    = 0.6,
                                height   = 0.6,
                                border   = border,
                                title    = " 󰆽 Git blame ",
                        },
                },
                picker    = {
                        prompt    = " > ",
                        ui_select = false,
                        hidden    = true,
                        ignored   = true,
                        formats   = { file = { filename_only = true } },
                        layout    = { preset = "default" },
                        win       = {
                                input = {
                                        keys = {
                                                ["<Esc>"] = { "close", mode = { "i", "n" } },
                                                ["h"]     = { "toggle_hidden", mode = { "n" } },
                                                ["l"]     = { "confirm", mode = { "n" } },
                                                ["J"]     = { "preview_scroll_down", mode = { "i", "n" } },
                                                ["K"]     = { "preview_scroll_up", mode = { "i", "n" } },
                                                ["H"]     = { "preview_scroll_left", mode = { "i", "n" } },
                                                ["L"]     = { "preview_scroll_right", mode = { "i", "n" } },
                                        },
                                },
                        },
                        icons     = {
                                Diagnostics = Icons.Diagnostics,
                                kinds       = Icons.Kinds,
                                tree        = { vertical = " ", middle = " ", last = " " },
                                files       = {
                                        enabled  = true,
                                        dir      = Icons.Kinds.Folder,
                                        dir_open = Icons.Misc.folderOpen,
                                        file     = Icons.Kinds.File,
                                },
                                ui          = {
                                        selected   = Icons.Diagnostics.HINT .. " ",
                                        unselected = "",
                                },
                                git         = {
                                        added     = Icons.Git.Added,
                                        deleted   = Icons.Git.Deleted,
                                        modified  = Icons.Git.Modified,
                                        enabled   = true,
                                        commit    = "󰜘 ",
                                        staged    = "●",
                                        ignored   = " ",
                                        renamed   = "",
                                        unmerged  = " ",
                                        untracked = "?",
                                },
                        },
                        layouts   = {
                                vscode   = {
                                        preview = false,
                                        layout  = {
                                                backdrop  = true,
                                                row       = 1,
                                                width     = 0.3,
                                                height    = 0.45,
                                                min_width = 60,
                                                border    = none,
                                                box       = "vertical",
                                                { win = "input",   height = 1,          border = border, title = "{title} {live} {flags}", title_pos = "center" },
                                                { win = "list",    border = border },
                                                { win = "preview", title = "{preview}", border = border },
                                        },
                                },
                                select   = {
                                        preview = false,
                                        layout  = {
                                                backdrop   = true,
                                                width      = 0.5,
                                                min_width  = 80,
                                                height     = 0.4,
                                                min_height = 10,
                                                box        = "vertical",
                                                border     = border,
                                                title      = "{title}",
                                                title_pos  = "center",
                                                { win = "input",   height = 1,          border = bot },
                                                { win = "list",    border = none },
                                                { win = "preview", title = "{preview}", height = 0.4, border = top },
                                        },
                                },
                                vertical = {
                                        layout = {
                                                backdrop   = true,
                                                width      = 0.8,
                                                height     = 0.95,
                                                min_width  = 70,
                                                min_height = 30,
                                                box        = "vertical",
                                                border     = border,
                                                title      = "{title} {live} {flags}",
                                                title_pos  = "center",
                                                { win = "list",    border = none },
                                                { win = "input",   height = 1,          border = bot },
                                                { win = "preview", title = "{preview}", height = 0.6, border = top },
                                        },
                                },
                                default  = {
                                        layout = {
                                                box       = "horizontal",
                                                width     = 0.9,
                                                min_width = 120,
                                                height    = 0.9,
                                                {
                                                        box    = "vertical",
                                                        border = border,
                                                        title  = "{title} {live} {flags}",
                                                        { win = "input", height = 1,   border = bot },
                                                        { win = "list",  border = none },
                                                },
                                                { win = "preview", title = "{preview}", border = border, width = 0.7 },
                                        },
                                },
                                dropdown = {
                                        layout = {
                                                backdrop  = true,
                                                width     = 0.9,
                                                height    = 0.9,
                                                min_width = 80,
                                                border    = none,
                                                box       = "vertical",
                                                {
                                                        box       = "vertical",
                                                        border    = border,
                                                        title     = "{title} {live} {flags}",
                                                        title_pos = "center",
                                                        { win = "input", height = 1,   border = bot },
                                                        { win = "list",  border = none },
                                                        -- { win  = "preview", title  = "{preview}", height  = 0.6, border  = border },
                                                },
                                        },
                                },
                                sidebar  = {
                                        preview = false,
                                        layout  = {
                                                backdrop  = true,
                                                width     = 35,
                                                min_width = 20,
                                                height    = 0,
                                                position  = "right",
                                                border    = none,
                                                box       = "vertical",
                                                { win = "list",    border = none },
                                                { win = "preview", title = "{preview}", height = 0.4, border = top },
                                        },
                                },
                        },
                },
                image     = {
                        enabled  = false,
                        formats  = { "png", "jpg", "jpeg", "gif", "bmp", "webp", "tiff", "heic", "avif", "mp4", "mov", "avi", "mkv", "webm", "pdf" },
                        force    = false,
                        doc      = {
                                enabled    = true,
                                inline     = true,
                                float      = true,
                                max_width  = 80,
                                max_height = 40,

                                ---@diagnostic disable-next-line: unused-local
                                conceal = function(lang, type)
                                        return type == "math"
                                end,
                        },
                        img_dirs = { "img", "images", "assets", "static", "public", "media", "attachments" },
                        wo       = {
                                wrap           = false,
                                number         = false,
                                relativenumber = false,
                                cursorcolumn   = false,
                                signcolumn     = "no",
                                foldcolumn     = "0",
                                list           = false,
                                spell          = false,
                                statuscolumn   = "",
                        },
                        cache    = vim.fn.stdpath("cache") .. "/Snacks.image",
                        debug    = { request = false, convert = false, placement = false },
                        icons    = { math = "󰪚 ", chart = "󰄧 ", image = " " },
                        env      = {},
                        convert  = {
                                notify  = true,
                                mermaid = function()
                                        local theme = vim.o.background == "light" and "neutral" or "dark"
                                        return { "-i", "{src}", "-o", "{file}", "-b", "transparent", "-t", theme,
                                                "-s", "{scale}" }
                                end,
                                magick  = {
                                        default = { "{src}[0]", "-scale", "1920x1080>" },
                                        vector  = { "-density", 192, "{src}[0]" },
                                        math    = { "-density", 192, "{src}[0]", "-trim" },
                                        pdf     = { "-density", 192, "{src}[0]", "-background", "white", "-alpha", "remove", "-trim" },
                                },
                        },
                        math     = {
                                enabled = true,
                                typst   = {
                                        tpl = [[
                                                        #set page(width: auto, height: auto, margin: (x: 2pt, y: 2pt))
                                                        #show math.equation.where(block: false): set text(top-edge: "bounds", bottom-edge: "bounds")
                                                        #set text(size: 12pt, fill: rgb("${color}"))
                                                        ${header}
                                                        ${content}
                                                ]],
                                },
                                latex   = {
                                        font_size = "Large",
                                        packages  = { "amsmath", "amssymb", "amsfonts", "amscd", "mathtools" },
                                        tpl       = [[
                                                        \documentclass[preview,border=0pt,varwidth,12pt]{standalone}
                                                        \usepackage{${packages}}
                                                        \begin{document}
                                                        ${header}
                                                        { \${font_size} \selectfont
                                                        \color[HTML]{${color}}
                                                        ${content}}
                                                        \end{document}
                                                ]],
                                },
                        },
                },
        },
}
