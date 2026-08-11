linq
"MiniFiles"
           { "TitleFocused", "Border" }
           { "Title", "Border" }
           { "Normal", "Normal" }
           { "Border", "Normal" }
           { "BorderModified", "Normal" }
           { "CursorLine", "PmenuSel" }

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local o      = vim.o
local v      = vim.v
local fn     = vim.fn
local fs     = vim.fs
local ui     = vim.ui
local api    = vim.api
local cmd    = vim.cmd
local log    = vim.log
local levels = log.levels

local kinds = Icon.Kinds

local send = require "functions.nano-plugins".teleSend "file"

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local border_width  = 1
local show_dotfiles = true

local function open()
        if not require "mini.files".close() then
                require "mini.files".open()
        end
end

local function current()
        local mf = require "mini.files"
        local _  = mf.close() or mf.open(api.nvim_buf_get_name(0), false)
        vim.defer_fn(function() mf.reveal_cwd() end, 30)
end

local function filterShow(_fsEntry)
        return true
end

local function filterHide(fsEntry)
        return not vim.startswith(fsEntry.name, ".")
end

local function toggleDotfiles()
        show_dotfiles    = not show_dotfiles
        local new_filter = show_dotfiles and filterShow or filterHide
        require "mini.files".refresh { content = { filter = new_filter } }
end

local function mapSplit(buf, lhs, direction)
        local rhs = function()
                local cur_target = require "mini.files".get_explorer_state().target_window
                local new_target = api.nvim_win_call(cur_target, function()
                        cmd(direction .. " split")
                        return api.nvim_get_current_win()
                end)

                require "mini.files".set_target_window(new_target)
        end

        local desc = "Split " .. direction
        keyq { lhs, rhs, buf = buf, desc = desc }
end

local function setCwd()
        local path = (require "mini.files".get_fs_entry() or {}).path
        if path == nil then return vim.notify "Cursor is not on valid entry" end
        fn.chdir(fs.dirname(path))
end

local function yankPath()
        local path = (require "mini.files".get_fs_entry() or {}).path
        if path == nil then return vim.notify "Cursor is not on valid entry" end
        vim.notify("Yanked: " .. path)
        fn.setreg(v.register, path)
end

local function uiOpen()
        ui.open(require "mini.files".get_fs_entry().path)
end

local function prefix(fsEntry)
        local icon_dir = kinds.Folder .. " "
        if fsEntry.fs_type == "directory" then
                return icon_dir, "MiniFilesDirectory"
        end
        return require "mini.files".default_prefix(fsEntry)
end

local function setMark(id, path, desc)
        require "mini.files".set_bookmark(id, path, { desc = desc })
end

local function layout(args, width, height)
        local state   = require "mini.files".get_explorer_state() or {}
        local win_ids = vim.tbl_map(function(t) return t.win_id end, state.windows or {})

        local function idx(winId)
                for i, id in ipairs(win_ids) do
                        if id == winId then
                                return i
                        end
                end
        end

        local widths          = { width, width }
        local this_win_idx    = idx(args.data.win_id)
        local focused_win_idx = idx(api.nvim_get_current_win())
        local idx_offset      = this_win_idx - focused_win_idx

        local i          = math.abs(idx_offset) + 1
        local win_config = api.nvim_win_get_config(args.data.win_id)
        win_config.width = i <= #widths and widths[i] or widths[#widths]

        if this_win_idx and focused_win_idx then
                local offset = 0
                for j = 1, math.abs(idx_offset), 1 do
                        local w          = widths[j] or widths[#widths]
                        local offset_new = 0.5 * (w + win_config.width)
                        if idx_offset > 0 then
                                offset = offset + offset_new + border_width
                        else
                                offset = offset - offset_new
                        end
                end

                win_config.height   = idx_offset == 0 and height or height
                win_config.row      = math.floor(0.5 * (o.lines - win_config.height))
                win_config.col      = math.floor(0.5 * (o.columns - win_config.width - win_config.width) + offset)
                win_config.relative = "editor"
                api.nvim_win_set_config(args.data.win_id, win_config)
        end
end

auq "User" { -- MARKS
        pattern  = "MiniFilesExplorerOpen",
        callback = function()
                require "utils.misc".addBackdrop("User", "MiniFilesExplorerClose")
                fn.confirm = function() ---@diagnostic disable-line: duplicate-set-field
                        vim.notify("confirmed", levels.WARN)
                        return 1
                end
                setMark("n", fn.stdpath "config",                      "Config")
                setMark("w", fn.getcwd,                                "Working directory")
                setMark("t", fn.stdpath "data" .. "/mini.files/trash", "Trash directory")
                setMark("l", fn.stdpath "data" .. "/lazy",             "Lazy directory")
                setMark("h", fn.expand "~/.config/hypr",               "Hypr directory")
                setMark("~", "~",                                      "Home directory")
        end,
}

auq "User" { -- SPLITS AND MAPS
        pattern  = "MiniFilesBufferCreate",
        callback = function(args)
                local buf = args.data.buf_id
                local lhs = "<leader>"
                mapSplit(buf, "<C-s>", "belowright horizontal")
                mapSplit(buf, "<C-v>", "belowright vertical")
                mapSplit(buf, "<C-t>", "tab")
                keyq { lhs .. "~", setCwd, buf = buf, desc = "Set cwd" }
                keyq { lhs .. "x", uiOpen, buf = buf, desc = "OS open" }
                keyq { lhs .. "y", yankPath, buf = buf, desc = "Yank path" }
                keyq { "@", yankPath, buf = buf, desc = "Yank path" }
                keyq { "S", function()
                        send((require "mini.files".get_fs_entry() or {}).path)
                end, mode = { "n", "x" }, buf = buf, desc = "Telegram send" }
        end,
}

auq "User" { -- BORDER
        pattern  = "MiniFilesWindowOpen",
        callback = function(args)
                if border_width == 1 then
                        border_width  = 1
                        local win_id  = args.data.win_id
                        local config  = api.nvim_win_get_config(win_id)
                        config.border = Border.Default.Normal
                        api.nvim_win_set_config(win_id, config)
                end
        end,
}

auq "User" { -- LAYOUT
        pattern  = "MiniFilesWindowUpdate",
        callback = function(args) layout(args, 60, 30) end,
}

auq "User" { -- CONFIRM
        pattern  = "MiniFilesExplorerClose",
        callback = function() fn.confirm = fn.confirm end,
}

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "nvim-mini/mini.files",
        keys   = {
                { "<leader>e", open },
                { "<leader>E", current },
        },
        opts   = {
                content  = {
                        filter    = nil,
                        highlight = nil,
                        prefix    = prefix,
                        sort      = nil,
                },
                mappings = {
                        close       = "<Esc>",
                        go_in       = "l",
                        go_in_plus  = "L",
                        go_out      = "h",
                        go_out_plus = "H",
                        mark_goto   = "m",
                        mark_set    = '"',
                        reset       = "<BS>",
                        reveal_cwd  = "@",
                        show_help   = "g?",
                        synchronize = "<LocalLeader>",
                        trim_left   = "<",
                        trim_right  = ">",
                },
                options  = {
                        permanent_delete        = false,
                        use_as_default_explorer = true,
                        lsp_timeout             = 2000,
                },
                windows  = {
                        max_number    = 2,
                        preview       = true,
                        width_focus   = 60,
                        width_preview = 60,
                },
        },
        config = function(_, opts)
                require "mini.files".setup(opts)
                require "real-icons.integrations.mini_files".opts()
        end,
}
