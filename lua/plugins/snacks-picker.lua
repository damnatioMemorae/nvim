local prefix = Config.prefix
local leader = "<leader><leader>"

local top    = Border.borderTop
local border = Border.borderStyle
local bot    = Border.borderBottom
local none   = Border.borderStyleNone

local mode = { "n" }

local insertOnShow = function() vim.cmd.stopinsert() end

return {
        "folke/snacks.nvim",
        keys = {
                { leader .. "<leader>", function() Snacks.picker({ layout = "vscode" }) end,                           desc = "Main Picker",      mode = mode },
                { leader .. "f",        function() Snacks.picker.files({ layout = "vertical", hidden = true }) end,    desc = "File Picker",      mode = mode },
                { leader .. "k",        function() Snacks.picker.keymaps({ layout = "dropdown", global = false }) end, desc = "Keymap (buffer)",  mode = mode },
                { leader .. "K",        function() Snacks.picker.keymaps({ layout = "dropdown" }) end,                 desc = "Keymap (global)",  mode = mode },
                { leader .. "w",        function() Snacks.picker.grep({ layout = "vertical" }) end,                    desc = "Grep Picker",      mode = mode },
                { leader .. "W",        function() Snacks.picker.grep_word({ layout = "vertical" }) end,               desc = "Grep Word",        mode = mode },
                { leader .. "B",        function() Snacks.picker.grep_buffers({ layout = "vertical" }) end,            desc = "Grep Word",        mode = mode },
                { leader .. "R",        function() Snacks.picker.registers({ layout = "vertical" }) end,               desc = "Register Picker",  mode = mode },
                { leader .. "h",        function() Snacks.picker.highlights({ layout = "default" }) end,               desc = "Highlight Picker", mode = mode },
                { leader .. "l",        function() Snacks.picker.lazy({ layout = "dropdown" }) end,                    desc = "Lazy Picker",      mode = mode },
                { -- `spc spc b` BUFFERS
                        leader .. "b",
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
                        leader .. "u",
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
                        leader .. "j",
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
                        leader .. "e",
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
        opts = {
                picker = {
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
                        sources   = {
                                files        = {
                                        cmd     = "rg",
                                        follow  = true,
                                        args    = {
                                                "--files",
                                                "--sortr=modified",
                                                "--no-config",
                                                ("--ignore-file=" .. vim.env.HOME .. "/.config/ripgrep/ignore"),
                                        },
                                        layout  = "small_no_preview",
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
                                        confirm = function(picker)
                                                picker:action("help")
                                                vim.cmd.only()
                                        end,
                                },
                                keymaps      = {
                                        confirm = function(picker, item)
                                                if not item.file then return end
                                                picker:close()
                                                local lnum = item.pos[1]
                                                vim.cmd(("edit +%d %s"):format(lnum, item.file))
                                        end,
                                        layout = { preset = "big_preview", hidden = { "preview" } },
                                },
                                colorschemes = { layout = { hidden = { "preview" }, max_height = 8, preset = "ivy" } },
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
                                        confirm = function(picker, item)
                                                vim.fn.setreg("+",           item.hl_group)
                                                Snacks.notify(item.hl_group, { title = "Copied", icon = "󰅍" })
                                                picker:close()
                                        end,
                                },
                        },
                },
        },
}
