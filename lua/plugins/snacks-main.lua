local v     = vim.v
local bo    = vim.bo
local fn    = vim.fn
local fs    = vim.fs
local ui    = vim.ui
local uv    = vim.uv
local cmd   = vim.cmd
local api   = vim.api
local env   = vim.env
local git   = Icon.Git
local misc  = Icon.Misc
local diag  = Icon.Diagnostics
local kinds = Icon.Kinds

local border = Border.Default.Normal
local none   = Border.Default.None

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local loaded, _ = pcall(require, "snacks")
local toggle    = Snacks.toggle
if loaded then
        toggle.option("relativenumber", { name = "Relative Line Number", global = true }):map "<leader>or"
        toggle.option("number", { name = "Line Number", global = true }):map "<leader>on"
        toggle.option("wrap", { name = "Wrap", global = true }):map "<leader>ow"
        toggle.treesitter { name = "Treesitter Highlight" }:map "<leader>ot"
end

local prefix = "<leader><leader>"
local function pick(picker)
        return function()
                return Snacks.picker[picker]()
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

linq
"SnacksPicker"
    { "", "Normal" }
    { "Col", "SnacksPickerRow" }
    { "Dir", "Comment" }
    { "Border", "Border" }
    { "Prompt", "Special" }
    { "BoxBorder", "Border" }
    { "Match", "PmenuMatch" }
    { "ListBorder", "Border" }
    { "InputBorder", "Border" }
    { "PreviewBorder", "Border" }
    { "CursorLine", "PmenuSel" }
    { "ListCursorLine", "PmenuSel" }
    { "PathIgnored", "Directory" }
    { "PathHidden", "Directory" }

local picker = {
        prompt     = " > ",
        ui_select  = false,
        hidden     = true,
        ignored    = true,
        formats    = { file = { filename_only = true } },
        layout     = { preset = "dropdown" },
        win        = {
                preview = { ["<C-p>"] = { "toggle_preview", mode = { "i", "n" } } },
                list    = { ["<C-p>"] = { "toggle_preview", mode = { "i", "n" } } },
                input   = {
                        keys = {
                                ["<a-s>"] = { "flash", mode = { "n", "i" } },
                                ["s"]     = { "flash" },
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
        sources    = {
                files      = {
                        cmd     = "rg",
                        follow  = true,
                        args    = {
                                "--files",
                                "--sortr=modified",
                                "--no-config",
                                ("--ignore-file=" .. env.HOME .. "/.config/ripgrep/ignore"),
                        },
                        hidden  = true,
                        matcher = { frecency = true },
                        win     = { input = { keys = { [":"] = { "complete_and_add_colon", mode = "i" } } } },
                        confirm = function(picker, item, action)
                                local abs_path       = Snacks.picker.util.path(item) or ""
                                local symlink_target = uv.fs_readlink(abs_path)
                                if symlink_target then
                                        local link_dir = fs.dirname(item._path)
                                        local original = fs.normalize(link_dir .. "/" .. symlink_target)
                                        assert(uv.fs_stat(original), "file does not exist: " .. original)
                                        item._path = original
                                end
                                local binary_ext = { "pdf", "png", "webp", "docx" }
                                local ext        = abs_path:match ".+%.([^.]+)$" or ""
                                if vim.tbl_contains(binary_ext, ext) then
                                        ui.open(abs_path)
                                        picker:close()
                                else
                                        Snacks.picker.actions.confirm(picker, item, action)
                                end
                        end,
                        actions = {
                                complete_and_add_colon = function(picker)
                                        local query = api.nvim_get_current_line()
                                        local file  = picker:current().file
                                        if not file or query:find ":" then
                                                fn.feedkeys(":", "n")
                                                return
                                        end
                                        api.nvim_set_current_line(file .. ":")
                                        cmd.startinsert { bang = true }
                                end,
                        },
                },
                help       = {
                        confirm = function(picker)
                                picker:action "help"
                                cmd.only()
                        end,
                },
                keymaps    = {
                        confirm = function(picker, item)
                                if not item.file then return end
                                picker:close()
                                local lnum = item.pos[1]
                                cmd(("edit +%d %s"):format(lnum, item.file))
                        end,
                },
                highlights = {
                        confirm = function(picker, item)
                                fn.setreg("+", item.hl_group)
                                Snacks.notify(item.hl_group, { title = "Copied", icon = "󰅍" })
                                picker:close()
                        end,
                },
        },
        icons      = {
                Diagnostics = diag,
                kinds       = kinds,
                tree        = { vertical = " ", middle = " ", last = " " },
                files       = { enabled = true, dir = kinds.Folder, dir_open = misc.folderOpen, file = kinds.File },
                ui          = { selected = diag.HINT .. " ", unselected = "" },
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
                flash         = function(picker)
                        local ok = pcall(require, "flash")
                        if not ok then return end
                        require "flash".jump {
                                pattern = "^",
                                label   = { after = { 0, 0 } },
                                search  = {
                                        mode    = "search",
                                        exclude = {
                                                function(win)
                                                        return bo[vim.api.nvim_win_get_buf(win)]
                                                            .filetype ~= "snacks_picker_list"
                                                end,
                                        },
                                },
                                action  = function(match)
                                        local idx = picker.list:row2idx(match.pos[1])
                                        picker.list:_move(idx, true, true)
                                end,
                        }
                end,
                yank          = function(picker, item, action)
                        if not item then return end
                        local reg   = action.reg or v.register
                        local value = item[action.field] or item.data or item.text
                        fn.setreg(reg, value)
                        if action.notify ~= false then
                                local buf = item.buf or api.nvim_win_get_buf(picker.main)
                                local ft  = bo[buf].filetype
                                vim.notify(value, nil, { icon = "󰅍", title = "Copied", ft = ft })
                        end
                end,
                qflist_and_go = function(picker, _item, _action)
                        local query = api.nvim_get_current_line()
                        local title = picker.title .. (query and ": " .. query or "")
                        picker:action "qflist"
                        fn.setqflist({}, "a", { title = title })
                        cmd.cclose()
                        cmd "silent cfirst"
                        cmd.normal { "zv", bang = true }
                        api.nvim_exec_autocmds("QuickFixCmdPost", {})
                end,
        },
        layouts    = {
                dropdown = {
                        layout = {
                                backdrop = true,
                                width    = 0.7,
                                height   = 0.7,
                                border   = none,
                                box      = "vertical",
                                {
                                        box       = "vertical",
                                        border    = none,
                                        title     = "",
                                        title_pos = "center",
                                        { win = "input", border = Border.Plain.Top,  height = 1 },
                                        { win = "list",  border = Border.Plain.NoTop },
                                },
                        },
                },
        },
        formatters = { file = { filename_list = true } },
}

return {
        "folke/snacks.nvim",
        keys = {
                { "<leader>fr",  Snacks.rename.rename_file, desc = "Rename File" },
                { "<leader>pr",  Snacks.profiler.scratch,   desc = "Rename File" },
                { prefix .. "f", pick "files",              desc = "File Picker" },
                { prefix .. "b", pick "buffers",            desc = "Buffer Picker" },
                { prefix .. "w", pick "grep",               desc = "Grep Picker" },
                { prefix .. "W", pick "grep_word",          desc = "Grep Word",              mode = { "n", "x" } },
                { prefix .. "k", pick "keymaps",            desc = "Keymap (global)" },
                { prefix .. "h", pick "highlights",         desc = "Highlight Picker" },
                { prefix .. "d", pick "diagnostics_buffer", desc = "Show Buffer Diagnostics" },
                { prefix .. "D", pick "diagnostics",        desc = "Show Workspace Symbols" },
        },
        opts = {
                quickfile = { enabled = true },
                lazygit   = { enabled = true },
                input     = { enabled = true, icon = "" },
                picker    = picker,
                profiler  = {
                        autocmds = true,
                        startup  = { event = "CmdlineLeave" },
                        globals  = { "kq", "auq", "req", "linq", "_linq", "match" },
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
                        input                = {
                                backdrop  = true,
                                border    = border,
                                row       = math.ceil(vim.o.lines / 10),
                                b         = { completion = true },
                                width     = 100,
                                title_pos = "left",
                                wo        = {
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
                },
        },
}
