local git   = Icon.Git
local misc  = Icon.Misc
local diag  = Icon.Diagnostics
local kinds = Icon.Kinds

local leader = "<leader><leader>"

local none = Border.Default.None

local function importLuaModule()
        Snacks.picker.grep{
                title  = "󰢱 Import module",
                cmd    = "rg",
                args   = { "--only-matching", "--no-config" },
                live   = false,
                regex  = true,
                search = [[local (\w+) ?= ?require\(["'](.*?)["']\)(\.[\w.]*)?]],
                ft     = "lua",

                layout = { preset = "select", layout = { width = 0.75 } },
                transform = function(item, ctx) -- ensure items are unique
                        ctx.meta.done = ctx.meta.done or {}
                        local import = item.text:gsub(".-:", "") -- different occurrences of same import
                        if ctx.meta.done[import] then return false end
                        ctx.meta.done[import] = true
                end,
                format = function(item, _picker) -- only display the grepped line
                        local out = {}
                        local line = item.line:gsub("^local ", "")
                        Snacks.picker.highlight.format(item, line, out)
                        return out
                end,
                confirm = function(picker, item) -- insert the line below the current one
                        picker:close()
                        vim.cmd.normal{ "o", bang = true }
                        vim.api.nvim_set_current_line(item.line)
                        vim.cmd.normal{ "==l", bang = true }
                end,
        }
end

local picker = {
        prompt     = " > ",
        ui_select  = false,
        hidden     = true,
        ignored    = true,
        formats    = { file = { filename_only = true } },
        layout     = { preset = "dropdown" },
        sources    = {
                files      = {
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
                buffers    = {
                        format = "buffer",
                        hidden = false,
                        win    = { input = { keys = { ["d"] = "bufdelete", ["<Left>"] = "bufdelete" } } },
                },
                help       = {
                        confirm = function(picker)
                                picker:action("help")
                                vim.cmd.only()
                        end,
                },
                keymaps    = {
                        confirm = function(picker, item)
                                if not item.file then return end
                                picker:close()
                                local lnum = item.pos[1]
                                vim.cmd(("edit +%d %s"):format(lnum, item.file))
                        end,
                },
                highlights = {
                        confirm = function(picker, item)
                                vim.fn.setreg("+",           item.hl_group)
                                Snacks.notify(item.hl_group, { title = "Copied", icon = "󰅍" })
                                picker:close()
                        end,
                },

                grep        = {},
                grep_word   = {},
                grep_buffer = {},

                lsp_implementations   = {},
                lsp_definitions       = {},
                lsp_declarations      = {},
                lsp_symbols           = {},
                lsp_workspace_symbols = {},
                lsp_references        = {},
                diagnostics           = {},
                diagnostics_buffer    = {},
        },
        win        = {
                preview = {
                        ["<C-p>"] = { "toggle_preview", mode = { "i", "n" } },
                },
                list    = {
                        ["<C-p>"] = { "toggle_preview", mode = { "i", "n" } },
                },
                input   = {
                        keys = {
                                ["<Esc>"] = { "close", mode = { "i", "n" } },
                                ["h"]     = { "toggle_hidden", mode = { "n" } },
                                ["l"]     = { "confirm", mode = { "n" } },
                                ["J"]     = { "preview_scroll_down", mode = { "i", "n" } },
                                ["K"]     = { "preview_scroll_up", mode = { "i", "n" } },
                                ["H"]     = { "preview_scroll_left", mode = { "i", "n" } },
                                ["L"]     = { "preview_scroll_right", mode = { "i", "n" } },
                                ["<C-p>"] = { "toggle_preview", mode = { "i", "n" } },
                        },
                },
        },
        icons      = {
                Diagnostics = diag,
                kinds       = kinds,
                tree        = {
                        vertical = " ",
                        middle   = " ",
                        last     = " ",
                },
                files       = {
                        enabled  = true,
                        dir      = kinds.Folder,
                        dir_open = misc.folderOpen,
                        file     = kinds.File,
                },
                ui          = {
                        selected   = diag.HINT .. " ",
                        unselected = "",
                },
                git         = {
                        added     = git.Added,
                        deleted   = git.Deleted,
                        modified  = git.Modified,
                        enabled   = true,
                        commit    = "󰜘 ",
                        staged    = "●",
                        ignored   = " ",
                        renamed   = "",
                        unmerged  = " ",
                        untracked = "?",
                },
        },
        actions    = {
                yank          = function(picker, item, action)
                        if not item then
                                return
                        end
                        local reg   = action.reg or vim.v.register
                        local value = item[action.field] or item.data or item.text
                        vim.fn.setreg(reg, value)
                        if action.notify ~= false then
                                local buf = item.buf or vim.api.nvim_win_get_buf(picker.main)
                                local ft  = vim.bo[buf].filetype
                                vim.notify(value, nil, { icon = "󰅍", title = "Copied", ft = ft })
                        end
                end,
                qflist_and_go = function(picker, _item, _action)
                        local query = vim.api.nvim_get_current_line()
                        local title = picker.title .. (query and ": " .. query or "")
                        picker:action("qflist")
                        vim.fn.setqflist({}, "a", { title = title })

                        vim.cmd.cclose()
                        vim.cmd("silent cfirst")
                        vim.cmd.normal{ "zv", bang = true }

                        vim.api.nvim_exec_autocmds("QuickFixCmdPost", {})
                end,
        },
        layouts    = {
                dropdown          = {
                        layout = {
                                box    = "horizontal",
                                width  = 0.7,
                                height = 0.7,
                                border = none,
                                {
                                        box    = "vertical",
                                        border = none,
                                        title  = "",
                                        { win = "input", border = Border.Plain.NoBottom },
                                        { win = "list",  border = Border.Plain.Top },
                                },
                        },
                },
                small_no_preview  = {
                        cycle = true, -- `list_up/down` action wraps
                        layout = {
                                box = "horizontal",
                                width = 0.65,
                                height = 0.6,
                                border = "none",
                                {
                                        box = "vertical",
                                        border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"]],
                                        title = "{title} {live} {flags}",
                                        { win = "input", height = 1,     border = "bottom" },
                                        { win = "list",  border = "none" },
                                },
                        },
                },
                wide_with_preview = {
                        preset = "small_no_preview",
                        layout = {
                                width = 0.999,
                                [2] = {
                                        win = "preview",
                                        title = "{preview}",
                                        border = vim.o.winborder --[[@as "rounded"|"single"|"double"|"solid"]],
                                        width = 0.5,
                                },
                        },
                },
                big_preview       = {
                        preset = "wide_with_preview",
                        layout = {
                                height = 0.8,
                                [2] = { width = 0.6 }, -- second win is the preview
                        },
                },
                sidebar           = {
                        preview = "main",
                        cycle = true, -- `list_up/down` action wraps
                        layout = {
                                box = "vertical",
                                position = "left", -- = split window
                                width = 0.3,
                                min_width = 25,
                                { win = "input",  height = 1, border = "bottom" },
                                { win = "list" },
                                { win = "preview" },
                        },
                },
                sidebar_no_input  = {
                        preview = "main",
                        cycle = true, -- `list_up/down` action wraps
                        layout = {
                                box = "vertical",
                                position = "left", -- = split window
                                width = 0.3,
                                min_width = 25,
                                { win = "list" },
                                { win = "preview" },
                        },
                },
        },
        formatters = { file = { filename_list = true } },
}

return {
        "folke/snacks.nvim",
        keys = {
                { leader .. "<leader>", function() Snacks.picker() end,                           desc = "Main Picker",      mode = { "n" } },
                { leader .. "f",        function() Snacks.picker.files() end,                     desc = "File Picker",      mode = { "n" } },
                { leader .. "b",        function() Snacks.picker.buffers() end,                   desc = "Buffer Picker",    mode = { "n" } },
                { leader .. "w",        function() Snacks.picker.grep() end,                      desc = "Grep Picker",      mode = { "n" } },
                { leader .. "W",        function() Snacks.picker.grep_word() end,                 desc = "Grep Word",        mode = { "n", "x" } },
                { leader .. "k",        function() Snacks.picker.keymaps({ global = false }) end, desc = "Keymap (buffer)",  mode = { "n" } },
                { leader .. "K",        function() Snacks.picker.keymaps() end,                   desc = "Keymap (global)",  mode = { "n" } },
                { leader .. "h",        function() Snacks.picker.highlights() end,                desc = "Highlight Picker", mode = { "n" } },
                { leader .. "H",        function() Snacks.picker.help() end,                      desc = "Help Picker",      mode = { "n" } },
                { leader .. "d",    function() Snacks.picker.diagnostics_buffer() end,    desc = "Show Buffer Diagnostics", mode = { "n" } },
                { leader .. "D",    function() Snacks.picker.diagnostics() end,           desc = "Show Workspace Symbols",  mode = { "n" } },

                -- { leader .. "B",        function() Snacks.picker.grep_buffers() end,              desc = "Grep Word",         mode = { "n" } },
                -- { leader .. "R",        function() Snacks.picker.registers() end,                 desc = "Register Picker",   mode = { "n" } },
                -- { leader .. "l",        function() Snacks.picker.lsp_config() end,                desc = "Lazy Picker",       mode = { "n" } },
                -- { leader .. "u",        function() Snacks.picker.undo() end,                      desc = "Undo Picker",       mode = { "n" } },
                -- { leader .. "j",        function() Snacks.picker.jumps() end,                     desc = "Jumps Picker",      mode = { "n" } },
                -- { leader .. "e",        function() Snacks.explorer() end,                         desc = "Buffer Picker",     mode = { "n" } },
                -- { leader .. "i",        importLuaModule,                                          desc = "Import Lua Module", mode = { "n" },     ft = "lua" },
                -- { leader .. "s",    function() Snacks.picker.lsp_symbols() end,           desc = "Show LSP Symbols",        mode = { "n" } },
                -- { leader .. "S",    function() Snacks.picker.lsp_workspace_symbols() end, desc = "Show Workspace Symbols",  mode = { "n" } },

                {
                        leader .. "p",
                        function()
                                Snacks.picker.files({
                                        title      = "󰈮 Local plugins",
                                        cwd        = vim.fn.stdpath("data") .. "/lazy",
                                        exclude    = { "*/tests/*", "*.toml", "*.tmux", "*.txt" },
                                        matcher    = { filename_bonus = false },
                                        formatters = { file = { filename_first = false } },
                                })
                        end,
                        desc = "Import Lua Module",
                        mode = { "n" },
                        ft   = "lua",
                },
        },
        opts = {
                picker = picker,
        },
        config = function(_, opts)
                require("snacks").setup(opts)
                _G.hlLink({
                                  { "Picker",              "Normal" },
                                  { "PickerBorder",        "Border" },
                                  { "PickerBoxBorder",     "Border" },
                                  { "PickerListBorder",    "Border" },
                                  { "PickerInputBorder",   "Border" },
                                  { "PickerPreviewBorder", "Border" },
                          }, "Snacks")
        end,
}
