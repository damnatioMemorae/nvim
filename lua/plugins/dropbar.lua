local backdrop = 70
local types    = {
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
        event        = "BufEnter",
        dependencies = { "nvim-telescope/telescope-fzf-native.nvim" },
        keys         = { { "<LocalLeader>w", function() require("dropbar.api").pick() end, desc = "Toggle dropbar", mode = { "n" } } },
        opts         = {
                bar     = {
                        truncate      = true,
                        pick          = { pivots = "hjklfdsa" },
                        padding       = { left = 1, right = 2 },
                        -- gc            = { interval = 200 },
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
                        win_configs      = { style = "minimal", border = Border.borderStyle },
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
                sources = {
                        path       = { max_depth = 2 },
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
        config       = function(_, opts)
                require("dropbar").setup(opts)
                vim.ui.select = require("dropbar.utils.menu").select

                vim.api.nvim_create_autocmd({ "FileType", "FocusGained", "BufWinEnter" }, {
                        desc     = "Add backdrop to windows",
                        pattern  = { "dropbar_menu" },
                        callback = function(ctx)
                                local backdrop_name = "MasonBackdrop"
                                local mason_bufnr   = ctx.buf
                                local mason_zindex  = 20

                                local backdrop_bufnr = vim.api.nvim_create_buf(false, true)
                                local winnr          = vim.api.nvim_open_win(backdrop_bufnr, false, {
                                        relative  = "editor",
                                        row       = 0,
                                        col       = 0,
                                        width     = vim.o.columns,
                                        height    = vim.o.lines,
                                        focusable = false,
                                        style     = "minimal",
                                        zindex    = mason_zindex - 1,
                                })

                                vim.api.nvim_set_hl(0, backdrop_name, { link = "WinBlend" })
                                vim.wo[winnr].winhighlight     = "Normal:" .. backdrop_name
                                vim.wo[winnr].winblend         = backdrop
                                vim.bo[backdrop_bufnr].buftype = "nofile"

                                vim.api.nvim_create_autocmd({ "WinClosed" }, {
                                        once     = true,
                                        buffer   = mason_bufnr,
                                        callback = function()
                                                if vim.api.nvim_win_is_valid(winnr) then
                                                        vim.api.nvim_win_close(winnr,
                                                                               true)
                                                end
                                                if vim.api.nvim_buf_is_valid(backdrop_bufnr) then
                                                        vim.api.nvim_buf_delete(backdrop_bufnr, { force = true })
                                                end
                                        end,
                                })
                        end,
                })
        end,
}
