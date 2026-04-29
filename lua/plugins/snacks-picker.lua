local leader = "<leader><leader>"

local top    = Border.borderTop
local border = Border.borderStyle
local bot    = Border.borderBottom
local none   = Border.borderStyleNone

local insertOnShow = function() vim.cmd.stopinsert() end

return {
        "folke/snacks.nvim",
        keys = {
                { leader .. "<leader>", function() Snacks.picker() end,                           desc = "Main Picker",             mode = { "n" } },
                { leader .. "f",        function() Snacks.picker.files() end,                     desc = "File Picker",             mode = { "n" } },
                { leader .. "k",        function() Snacks.picker.keymaps({ global = false }) end, desc = "Keymap (buffer)",         mode = { "n" } },
                { leader .. "K",        function() Snacks.picker.keymaps() end,                   desc = "Keymap (global)",         mode = { "n" } },
                { leader .. "w",        function() Snacks.picker.grep() end,                      desc = "Grep Picker",             mode = { "n" } },
                { leader .. "W",        function() Snacks.picker.grep_word() end,                 desc = "Grep Word",               mode = { "n", "x" } },
                { leader .. "B",        function() Snacks.picker.grep_buffers() end,              desc = "Grep Word",               mode = { "n" } },
                { leader .. "R",        function() Snacks.picker.registers() end,                 desc = "Register Picker",         mode = { "n" } },
                { leader .. "h",        function() Snacks.picker.highlights() end,                desc = "Highlight Picker",        mode = { "n" } },
                { leader .. "H",        function() Snacks.picker.help() end,                      desc = "Help Picker",             mode = { "n" } },
                { leader .. "l",        function() Snacks.picker.lazy() end,                      desc = "Lazy Picker",             mode = { "n" } },
                { leader .. "b",        function() Snacks.picker.buffers() end,                   desc = "Buffer Picker",           mode = { "n" } },
                { leader .. "u",        function() Snacks.picker.undo() end,                      desc = "Undo Picker",             mode = { "n" } },
                { leader .. "j",        function() Snacks.picker.jumps() end,                     desc = "Jumps Picker",            mode = { "n" } },
                { leader .. "e",        function() Snacks.explorer() end,                         desc = "Buffer Picker",           mode = { "n" } },

                -- LSP PICKERS
                { "<LocalLeader>r",     function() Snacks.picker.lsp_references() end,            desc = "Show References",         mode = { "n" } },
                { "<LocalLeader>i",     function() Snacks.picker.lsp_implementations() end,       desc = "Show Implementations",    mode = { "n" } },
                { "<LocalLeader>d",     function() Snacks.picker.lsp_definitions() end,           desc = "Show Definitions",        mode = { "n" } },
                { "<LocalLeader>D",     function() Snacks.picker.lsp_declarations() end,          desc = "Show Declarations",       mode = { "n" } },
                { leader .. "s",        function() Snacks.picker.lsp_symbols() end,               desc = "Show LSP Symbols",        mode = { "n" } },
                { leader .. "S",        function() Snacks.picker.lsp_workspace_symbols() end,     desc = "Show Workspace Symbols",  mode = { "n" } },
                { leader .. "d",        function() Snacks.picker.diagnostics_buffer() end,        desc = "Show Buffer Diagnostics", mode = { "n" } },
                { leader .. "D",        function() Snacks.picker.diagnostics() end,               desc = "Show Workspace Symbols",  mode = { "n" } },
        },
        opts = {
                picker = {
                        prompt    = " > ",
                        ui_select = false,
                        hidden    = true,
                        ignored   = true,
                        formats   = { file = { filename_only = true } },
                        layout    = { preset = "default" },
                        sources   = {
                                files        = {
                                        layout  = "vertical",
                                        cmd     = "rg",
                                        follow  = true,
                                        args    = {
                                                "--files",
                                                "--sortr=modified",
                                                "--no-config",
                                                ("--ignore-file=" .. vim.env.HOME .. "/.config/ripgrep/ignore"),
                                        },
                                        hidden  = true,
                                        matcher = { frecency = true },
                                        win     = { input = { keys = { [":"] = { "complete_and_add_colon", mode = "i" } } } },
                                        confirm = function(picker, item, action)
                                                local abs_path       = Snacks.picker.util.path(item) or ""
                                                local symlink_target = vim.uv.fs_readlink(abs_path)

                                                if symlink_target then
                                                        local link_dir = vim.fs.dirname(item._path)
                                                        local original = vim.fs.normalize(link_dir ..
                                                                "/" .. symlink_target)
                                                        assert(vim.uv.fs_stat(original),
                                                               "file does not exist: " .. original)
                                                        item._path = original
                                                end

                                                local binary_ext = { "pdf", "png", "webp", "docx" }
                                                local ext        = abs_path:match(".+%.([^.]+)$") or ""
                                                if vim.tbl_contains(binary_ext, ext) then
                                                        vim.ui.open(abs_path)
                                                        picker:close()
                                                else
                                                        Snacks.picker.actions.confirm(picker, item, action)
                                                end
                                        end,
                                        actions = {
                                                complete_and_add_colon = function(picker)
                                                        local query = vim.api.nvim_get_current_line()
                                                        local file  = picker:current().file
                                                        if not file or query:find(":") then
                                                                vim.fn.feedkeys(":", "n")
                                                                return
                                                        end
                                                        vim.api.nvim_set_current_line(file .. ":")
                                                        vim.cmd.startinsert{ bang = true }
                                                end,
                                        },
                                },
                                help         = {
                                        layout  = "vertical",
                                        confirm = function(picker)
                                                picker:action("help")
                                                vim.cmd.only()
                                        end,
                                },
                                keymaps      = {
                                        layout  = "dropdown",
                                        confirm = function(picker, item)
                                                if not item.file then return end
                                                picker:close()
                                                local lnum = item.pos[1]
                                                vim.cmd(("edit +%d %s"):format(lnum, item.file))
                                        end,
                                },
                                icons        = {
                                        layout  = { preset = "small_no_preview", layout = { width = 0.7 } },
                                        confirm = function(picker, item, action)
                                                picker:close()
                                                if not item then return end
                                                local value = item[action.field] or item.data or item.text
                                                vim.api.nvim_paste(value, true, -1)
                                                if picker.input.mode ~= "i" then return end
                                                vim.schedule(function()
                                                        local col = vim.fn.virtcol(".")
                                                        local eol = vim.fn.virtcol("$") - 1
                                                        if col == eol then
                                                                vim.cmd.startinsert{ bang = true }
                                                        else
                                                                vim.cmd.normal{ "l", bang = true }
                                                                vim.cmd.startinsert()
                                                        end
                                                end)
                                        end,
                                },
                                highlights   = {
                                        layout  = "default",
                                        confirm = function(picker, item)
                                                vim.fn.setreg("+",           item.hl_group)
                                                Snacks.notify(item.hl_group, { title = "Copied", icon = "󰅍" })
                                                picker:close()
                                        end,
                                },
                                buffers      = {
                                        on_show = insertOnShow,
                                        layout  = "vscode",
                                        format  = "buffer",
                                        hidden  = false,
                                        win     = { input = { keys = { ["d"] = "bufdelete", ["<Left>"] = "bufdelete" } } },
                                },
                                undo         = {
                                        on_show = insertOnShow,
                                        layout  = "default",
                                        format  = "buffer",
                                        hidden  = false,
                                        win     = {},
                                },
                                jumps        = {
                                        on_show = insertOnShow,
                                        layout  = "default",
                                        format  = "buffer",
                                        hidden  = false,
                                        win     = {},
                                },
                                explorer     = {
                                        layout = {
                                                preset  = "sidebar",
                                                preview = false,
                                                input   = false,
                                        },
                                },
                                grep         = { layout = "vertical" },
                                grep_word    = { layout = "vertical" },
                                grep_buffer  = { layout = "vertical" },
                                registers    = { layout = "vertical" },
                                lazy         = { layout = "dropdown" },
                                picker       = { layout = "vscode" },
                                colorschemes = { layout = { hidden = { "preview" }, max_height = 8, preset = "ivy" } },

                                lsp_implementations   = { layout = "vertical", on_show = insertOnShow },
                                lsp_definitions       = { layout = "vertical", on_show = insertOnShow },
                                lsp_declarations      = { layout = "vertical", on_show = insertOnShow },
                                lsp_symbols           = { layout = "vertical", on_show = insertOnShow },
                                lsp_workspace_symbols = { layout = "vertical", on_show = insertOnShow },
                                lsp_references        = { layout = "vertical", on_show = insertOnShow },
                                diagnostics           = { layout = "vertical", on_show = insertOnShow },
                                diagnostics_buffer    = { layout = "vertical", on_show = insertOnShow },
                        },
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
                                tree        = {
                                        vertical = " ",
                                        middle   = " ",
                                        last     = " ",
                                },
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
        },
}
