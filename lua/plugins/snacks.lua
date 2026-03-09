local button       = "Function"
local label        = "Comment"
local prefix       = Config.prefix
local insertOnShow = function() vim.cmd.stopinsert() end

return {
        "folke/snacks.nvim",
        lazy     = false,
        priority = 1000,
        keys     = {
                { "<C-n>",      function() Snacks.notifier.show_history() end, desc = "Notification History" },
                { "<leader>fr", function() Snacks.rename.rename_file() end,    desc = "Rename File" },
                { "<leader>lg", function() Snacks.lazygit() end,               desc = "Lazygit" },
                { -- `Alt b` DELETE BUFFER
                        "<A-b>",
                        function() Snacks.bufdelete() end,
                        desc = "Delete Buffer",
                },
                { -- `spc spc spc` MAIN
                        "<leader><leader><leader>",
                        function() Snacks.picker({ layout = "vscode" }) end,
                        desc = "Main Picker",
                        mode = { "n" },
                },
                { -- `spc spc f` FILES
                        "<leader><leader>f",
                        function() Snacks.picker.files({ layout = "vertical", hidden = true }) end,
                        desc = "File Picker",
                        mode = { "n" },
                },
                { -- `spc spc k` KEYMAPS
                        "<leader><leader>k",
                        function() Snacks.picker.keymaps({ layout = "dropdown" }) end,
                        desc = "Keymap Picker",
                        mode = { "n" },
                },
                { -- `spc spc w` GREP
                        "<leader><leader>w",
                        function() Snacks.picker.grep({ layout = "vertical" }) end,
                        desc = "Grep Picker",
                        mode = { "n" },
                },
                { -- `spc spc W` GREP WORD
                        "<leader><leader>W",
                        function() Snacks.picker.grep_word({ layout = "vertical" }) end,
                        desc = "Grep Word",
                        mode = { "n" },
                },
                { -- `spc spc B` GREP BUFFERS
                        "<leader><leader>B",
                        function() Snacks.picker.grep_buffers({ layout = "vertical" }) end,
                        desc = "Grep Word",
                        mode = { "n" },
                },
                { -- `spc spc R` REGISTERS
                        "<leader><leader>R",
                        function() Snacks.picker.registers({ layout = "vertical" }) end,
                        desc = "Register Picker",
                        mode = { "n" },
                },
                { -- `spc spc h` HIGHLIGHTS
                        "<leader><leader>h",
                        function() Snacks.picker.highlights({ layout = "default" }) end,
                        desc = "Highlight Picker",
                        mode = { "n" },
                },
                { -- `spc spc l` LAZY
                        "<leader><leader>l",
                        function() Snacks.picker.lazy({ layout = "dropdown" }) end,
                        desc = "Lazy Picker",
                        mode = { "n" },
                },
                { -- `spc spc b` BUFFERS `!10`
                        "<leader><leader>b",
                        function()
                                Snacks.picker.buffers({
                                        on_show = insertOnShow,
                                        layout  = "vscode",
                                        format  = "buffer",
                                        hidden  = false,
                                        win     = { input = { keys = { ["d"] = "bufdelete", ["<Left>"] = "bufdelete" } } },
                                })
                        end,
                        desc = "Buffer Picker",
                        mode = { "n" },
                },
                { -- `spc spc u` UNDO
                        "<leader><leader>u",
                        function()
                                Snacks.picker.undo({
                                        on_show = insertOnShow,
                                        layout  = "default",
                                        format  = "buffer",
                                        hidden  = false,
                                        win     = {},
                                })
                        end,
                        desc = "Undo Picker",
                        mode = { "n" },
                },
                { -- `spc spc j` JUMPS
                        "<leader><leader>j",
                        function()
                                Snacks.picker.jumps({
                                        on_show = insertOnShow,
                                        layout  = "default",
                                        format  = "buffer",
                                        hidden  = false,
                                        win     = {},
                                })
                        end,
                        desc = "Jumps Picker",
                        mode = { "n" },
                },
                { -- `spc spc e` EXPLORER
                        "<leader><leader>e",
                        function() Snacks.explorer({ layout = { preset = "sidebar", preview = false, input = false } }) end,
                        desc = "Buffer Picker",
                        mode = { "n" },
                },

                -- LSP PICKERS
                { -- `spc spc r` REFERENCES
                        prefix .. "r",
                        function() Snacks.picker.lsp_references({ layout = "vertical", on_show = insertOnShow }) end,
                        desc = "Show References",
                        mode = { "n" },
                },
                { -- `spc spc i` IMPLEMENTATIONS
                        prefix .. "i",
                        function() Snacks.picker.lsp_implementations({ layout = "vertical", on_show = insertOnShow }) end,
                        desc = "Show Implementations",
                        mode = { "n" },
                },
                { -- `spc spc d` DEFINITIONS
                        prefix .. "d",
                        function() Snacks.picker.lsp_definitions({ layout = "vertical", on_show = insertOnShow }) end,
                        desc = "Show Definitions",
                        mode = { "n" },
                },
                { -- `spc spc D` DECLARATIONS
                        prefix .. "D",
                        function() Snacks.picker.lsp_declarations({ layout = "vertical", on_show = insertOnShow }) end,
                        desc = "Show Declarations",
                        mode = { "n" },
                },
                { -- `spc spc s` SYMBOLS
                        "<leader><leader>s",
                        function() Snacks.picker.lsp_symbols({ layout = "vertical", on_show = insertOnShow }) end,
                        desc = "Show LSP Symbols",
                        mode = { "n" },
                },
                { -- `spc spc S` WORKSPACE SYMBOLS
                        "<leader><leader>S",
                        function() Snacks.picker.lsp_workspace_symbols({ layout = "vertical", on_show = insertOnShow }) end,
                        desc = "Show Workspace Symbols",
                        mode = { "n" },
                },
                { -- `spc spc d` DIAGNOSTICS BUFFER
                        "<leader><leader>d",
                        function() Snacks.picker.diagnostics_buffer({ layout = "vertical", on_show = insertOnShow }) end,
                        desc = "Show Buffer Diagnostics",
                        mode = { "n" },
                },
                { -- `spc spc D` DIAGNOSTICS WORKSPACE
                        "<leader><leader>D",
                        function() Snacks.picker.diagnostics({ layout = "vertical", on_show = insertOnShow }) end,
                        desc = "Show Workspace Symbols",
                        mode = { "n" },
                },
        },
        opts     = {
                quickfile    = { enabled = true },
                lazygit      = { enabled = true },
                input        = { enabled = true },
                indent       = {
                        indent  = {
                                enabled    = false,
                                char       = "",
                                only_scope = true,
                        },
                        animate = { enabled = false },
                        scope   = {
                                enabled      = false,
                                char         = "▏",
                                underline    = true,
                                only_current = true,
                                hl           = "Function",
                        },
                        chunk   = {
                                enabled      = false,
                                only_current = false,
                        },
                },
                scope        = {
                        enabled    = true,
                        min_size   = 2,
                        cursor     = false,
                        siblings   = false,
                        treesitter = {
                                enabled      = true,
                                injections   = true,
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
                                field_blocks = { "local_declaration" },
                        },
                },
                win          = {
                        border = Config.borderStyle,
                        wo     = {
                                signcolumn     = "no",
                                statuscolumn   = " ",
                                winbar         = "",
                                number         = false,
                                relativenumber = false,
                                cursorcolumn   = false,
                        },
                },
                statuscolumn = {
                        enabled = false,
                        left    = { "git", "sign" },
                        right   = { "fold" },
                        folds   = { open = true, git_hl = false },
                        git     = { pattern = { "GitSign", "MiniDiffSign" } },
                        refresh = 50,
                },
                styles       = {
                        notification_history = {
                                border   = Config.borderRight,
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
                                border   = Config.borderStyle,
                                row      = math.ceil(vim.o.lines / 2) - 8,
                                wo       = {
                                        cursorline   = false,
                                        winhighlight =
                                        "NormalFloat:SnacksInputNormal,FloatBorder:SnacksInputBorder,FloatTitle:SnacksInputTitle",
                                },
                        },
                        notification         = {
                                border  = Config.borderRight,
                                wo      = {
                                        winblend = Config.blend,
                                },
                                icons   = Icons.notifier,
                                enabled = true,
                                timeout = 2000,
                                style   = "minimal",
                        },
                        blame_line           = {
                                backdrop = true,
                                width    = 0.6,
                                height   = 0.6,
                                border   = Config.borderStyle,
                                title    = " 󰆽 Git blame ",
                        },
                },
                notifier     = {
                        icons   = Icons.notifier,
                        style   = "minimal",
                        enabled = true,
                        timeout = 2000,
                },
                picker       = {
                        prompt    = " > ",
                        ui_select = true,
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
                                diagnostics = Icons.diagnostics,
                                kinds       = Icons.symbolKinds,
                                tree        = {
                                        vertical = " ",
                                        middle   = " ",
                                        last     = " ",
                                },
                                files       = {
                                        enabled  = true,
                                        dir      = Icons.symbolKinds.Folder,
                                        dir_open = Icons.misc.folderOpen,
                                        file     = Icons.symbolKinds.File,
                                },
                                ui          = {
                                        selected   = Icons.diagnostics.HINT .. " ",
                                        unselected = "",
                                },
                                git         = {
                                        added     = Icons.git.Added,
                                        deleted   = Icons.git.Deleted,
                                        modified  = Icons.git.Modified,
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
                                                border    = "none",
                                                box       = "vertical",
                                                { win = "input",   height = 1,          border = "rounded", title = "{title} {live} {flags}", title_pos = "center" },
                                                { win = "list",    border = "bottom" },
                                                { win = "preview", title = "{preview}", border = "rounded" },
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
                                                border     = "rounded",
                                                title      = "{title}",
                                                title_pos  = "center",
                                                { win = "input",   height = 1,          border = "bottom" },
                                                { win = "list",    border = "none" },
                                                { win = "preview", title = "{preview}", height = 0.4,     border = "top" },
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
                                                border     = "single",
                                                title      = "{title} {live} {flags}",
                                                title_pos  = "center",
                                                { win = "list",    border = "none" },
                                                { win = "input",   height = 1,          border = "bottom" },
                                                { win = "preview", title = "{preview}", height = 0.6,     border = "top" },
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
                                                        border = "rounded",
                                                        title  = "{title} {live} {flags}",
                                                        { win = "input", height = 1,     border = "bottom" },
                                                        { win = "list",  border = "none" },
                                                },
                                                { win = "preview", title = "{preview}", border = "rounded", width = 0.7 },
                                        },
                                },
                                dropdown = {
                                        layout = {
                                                backdrop  = true,
                                                width     = 0.9,
                                                height    = 0.9,
                                                min_width = 80,
                                                border    = "none",
                                                box       = "vertical",
                                                {
                                                        box       = "vertical",
                                                        border    = "rounded",
                                                        title     = "{title} {live} {flags}",
                                                        title_pos = "center",
                                                        { win = "input", height = 1,     border = "bottom" },
                                                        { win = "list",  border = "none" },
                                                        -- { win  = "preview", title  = "{preview}", height  = 0.6,     border  = "rounded" },
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
                                                border    = "none",
                                                box       = "vertical",
                                                { win = "list",    border = "none" },
                                                { win = "preview", title = "{preview}", height = 0.4, border = "top" },
                                        },
                                },
                        },
                },
                image        = {
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
                        debug    = {
                                request   = false,
                                convert   = false,
                                placement = false,
                        },
                        env      = {},
                        icons    = {
                                math  = "󰪚 ",
                                chart = "󰄧 ",
                                image = " ",
                        },
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
                dashboard    = {
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
                                                { Icons.misc.newFile .. "  ", hl = button },
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
                                                { Icons.misc.recentFile .. "  ", hl = button },
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
                                                { Icons.misc.findFile .. "  ", hl = button },
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
                                                { Icons.misc.findText .. "  ", hl = button },
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
                                                { Icons.symbolKinds.Folder .. "  ", hl = button },
                                                { "Yazi",                           hl = label, width = 45 },
                                                { "[",                              hl = button },
                                                { "y",                              hl = label },
                                                { "]",                              hl = button },
                                        },
                                        action  = "<cmd>Yazi<CR>",
                                        key     = "y",
                                        padding = 1,
                                        align   = "center",
                                },
                                { -- RESTORE SESSION
                                        text    = {
                                                { Icons.misc.restore .. "  ", hl = button },
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
                                                { Icons.misc.config .. "  ", hl = button },
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
                                { -- LAZY
                                        text    = {
                                                { Icons.misc.package .. "  ", hl = button },
                                                { "Lazy",                     hl = label, width = 45 },
                                                { "[",                        hl = button },
                                                { "l",                        hl = label },
                                                { "]",                        hl = button },
                                        },
                                        key     = "l",
                                        action  = "<cmd> Lazy <CR>",
                                        padding = 1,
                                        align   = "center",
                                },
                                { -- UPDATE
                                        text    = {
                                                { Icons.misc.newPackage .. "  ", hl = button },
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
                                { -- QUIT
                                        text    = {
                                                { Icons.misc.quit .. "  ", hl = button },
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
