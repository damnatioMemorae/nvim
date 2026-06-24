local map = _G.smartMap

local border_width = 1

local function filterShow(_fsEntry)
        return true
end

local function filterHide(fsEntry)
        return not vim.startswith(fsEntry.name, ".")
end

local show_dotfiles = true
local function toggleDotfiles()
        show_dotfiles    = not show_dotfiles
        local new_filter = show_dotfiles and filterShow or filterHide
        require("mini.files").refresh({ content = { filter = new_filter } })
end

local function mapSplit(buf, lhs, direction)
        local rhs = function()
                local cur_target = require("mini.files").get_explorer_state().target_window
                local new_target = vim.api.nvim_win_call(cur_target, function()
                        vim.cmd(direction .. " split")
                        return vim.api.nvim_get_current_win()
                end)

                require("mini.files").set_target_window(new_target)
        end

        local desc = "Split " .. direction
        map({ lhs, rhs, buf = buf, desc = desc })
end

local function setCwd()
        local path = (require("mini.files").get_fs_entry() or {}).path
        if path == nil then return vim.notify("Cursor is not on valid entry") end
        vim.fn.chdir(vim.fs.dirname(path))
end

local function yankPath()
        local path = (require("mini.files").get_fs_entry() or {}).path
        if path == nil then return vim.notify("Cursor is not on valid entry") end
        vim.fn.setreg(vim.v.register, path)
end

local function uiOpen()
        vim.ui.open(require("mini.files").get_fs_entry().path)
end

local function prefix(fsEntry)
        local icon_dir = Icons.Kinds.Folder .. " "
        if fsEntry.fs_type == "directory" then
                return icon_dir, "MiniFilesDirectory"
        end
        return require("mini.files").default_prefix(fsEntry)
end

local function setMark(id, path, desc)
        require("mini.files").set_bookmark(id, path, { desc = desc })
end

local function sideScroll(args, width, height)
        local state   = require("mini.files").get_explorer_state() or {}
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
        local focused_win_idx = idx(vim.api.nvim_get_current_win())
        local idx_offset      = this_win_idx - focused_win_idx

        local i          = math.abs(idx_offset) + 1
        local win_config = vim.api.nvim_win_get_config(args.data.win_id)
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
                win_config.row      = math.floor(0.5 * (vim.o.lines - win_config.height))
                win_config.col      = math.floor(0.5 * (vim.o.columns - win_config.width - win_config.width) + offset)
                win_config.relative = "editor"
                vim.api.nvim_win_set_config(args.data.win_id, win_config)
        end
end

return {
        "nvim-mini/mini.files",
        keys   = {
                { "<leader>e", function(...)
                        if not require("mini.files").close() then
                                require("mini.files").open(...)
                        end
                end,
                },
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
                        lsp_timeout             = 1000,
                },
                windows  = {
                        max_number    = 2,
                        preview       = true,
                        width_focus   = 60,
                        width_preview = 60,
                },
        },
        config = function(_, opts)
                require("mini.files").setup(opts)

                vim.api.nvim_create_autocmd("User", {
                        pattern  = "MiniFilesBufferCreate",
                        callback = function(args)
                                local buf = args.data.buf_id
                                local lhs = "<leader>"
                                map({ ".", toggleDotfiles, buf = buf, noremap = true })
                                map({ lhs .. "~", setCwd, buf = buf, desc = "Set cwd" })
                                map({ lhs .. "x", uiOpen, buf = buf, desc = "OS open" })
                                map({ lhs .. "y", yankPath, buf = buf, desc = "Yank path" })
                                mapSplit(buf, "<C-s>", "belowright horizontal")
                                mapSplit(buf, "<C-v>", "belowright vertical")
                                mapSplit(buf, "<C-t>", "tab")
                        end,
                })
                vim.api.nvim_create_autocmd("User", {
                        pattern  = "MiniFilesExplorerOpen",
                        callback = function()
                                setMark("n", vim.fn.stdpath("config"),          "Config")
                                setMark("w", vim.fn.getcwd,                     "Working directory")
                                setMark("l", vim.fn.stdpath("data") .. "/lazy", "Lazy directory")
                                setMark("h", vim.fn.expand("~/.config/hypr"),   "Hypr directory")
                                setMark("~", "~",                               "Home directory")
                        end,
                })
                vim.api.nvim_create_autocmd("User", {
                        pattern  = "MiniFilesWindowUpdate",
                        callback = function(args) sideScroll(args, 60, 30) end,
                })
                vim.api.nvim_create_autocmd("User", {
                        pattern  = { "MiniFilesExplorerOpen" },
                        callback = function() _G.addBackdrop("User", "MiniFilesExplorerClose") end,
                })
                vim.api.nvim_create_autocmd("User", {
                        pattern  = "MiniFilesWindowOpen",
                        callback = function(args)
                                if border_width == 1 then
                                        border_width  = 1
                                        local win_id  = args.data.win_id
                                        local config  = vim.api.nvim_win_get_config(win_id)
                                        config.border = Border.borderStyle
                                        vim.api.nvim_win_set_config(win_id, config)
                                end
                        end,
                })

                local groups = {
                        { "TitleFocused",   "Special" },
                        { "Title",          "Special" },
                        { "Normal",         "Normal" },
                        { "Border",         "Normal" },
                        { "BorderModified", "Normal" },
                        { "CursorLine",     "PmenuSel" },
                }
                vim.iter(groups):each(function(group)
                        vim.api.nvim_set_hl(0, "MiniFiles" .. group[1], { link = group[2] })
                end)
        end,
}
