---@diagnostic disable: name-style-check

local ui2  = require("vim._core.ui2")
local msgs = require("vim._core.ui2.messages")

----CONFIG--------------------------------------------------------------------------------------------------------------

local ignored_kinds = {
        bufwrite = false,
        [""]     = true,
}

local skip_patterns = {
        "%d+L, %d+B",
        "; after #%d+",
        "; before #%d+",
        "%d fewer lines",
        "%d more lines",
}

local dialog_kinds = {
        confirm     = true,
        confirm_sub = true,
        list_cmd    = true,
}

local kind_titles = {
        emsg         = { "  Error", "ErrorMsg" },
        echoerr      = { "  Error", "ErrorMsg" },
        lua_error    = { "  Error", "ErrorMsg" },
        rpc_error    = { "  Error", "ErrorMsg" },
        wmsg         = { "  Warning", "WarningMsg" },
        echo         = { "  Info", "Normal" },
        echomsg      = { "  Info", "Normal" },
        lua_print    = { "  Print", "Normal" },
        search_cmd   = { "  Search", "Normal" },
        search_count = { "  Search", "Normal" },
        undo         = { "  Undo", "Normal" },
        shell_out    = { "  Shell", "Normal" },
        shell_err    = { "  Shell", "ErrorMsg" },
        shell_cmd    = { "  Shell", "Normal" },
        quickfix     = { "  Quickfix", "Normal" },
        progress     = { "  Progress", "Normal" },
        typed_cmd    = { "  Command", "Normal" },
        list_cmd     = { "  List", "Normal" },
        verbose      = { "  Verbose", "Comment" },
}

----STATE---------------------------------------------------------------------------------------------------------------

local last_title = nil
local last_hl    = "FloatBorder"

----HELPERS-------------------------------------------------------------------------------------------------------------

local function contentToText(content)
        if type(content) ~= "table" then
                return tostring(content or "")
        end

        local parts = {}

        for _, chunk in ipairs(content) do
                if type(chunk) == "table" and chunk[2] then
                        parts[#parts + 1] = chunk[2]
                end
        end

        return table.concat(parts)
end

local function shouldSkip(kind, content)
        if ignored_kinds[kind] then
                return true
        end

        local text = contentToText(content)

        for _, pat in ipairs(skip_patterns) do
                if text:find(pat) then
                        return true
                end
        end

        return false
end

local function resolveTitle(kind, content)
        local entry = kind_titles[kind]

        if entry then
                return entry[1], entry[2]
        end

        local text = vim.trim(contentToText(content)):gsub("\n.*", "")

        if #text > 40 then
                text = text:sub(1, 37) .. "…"
        end

        return text ~= "" and (" " .. text .. " ") or "  Message ", "FloatBorder"
end

local function overrideMsgWin()
        local win = ui2.wins and ui2.wins.msg

        if not (win and vim.api.nvim_win_is_valid(win)) then
                return
        end

        if vim.api.nvim_win_get_config(win).hide then
                return
        end

        pcall(vim.api.nvim_win_set_config, win, {
                relative = "editor",
                anchor   = "NE",
                row      = 4,
                col      = vim.o.columns - 1,
                border   = Border.borderStyleNone,
                style    = "minimal",
        })
end

local function overridePagerWin()
        local win = ui2.wins and ui2.wins.pager

        if not (win and vim.api.nvim_win_is_valid(win)) then
                return
        end

        if vim.api.nvim_win_get_config(win).hide then
                return
        end

        local height = vim.api.nvim_win_get_height(win)
        pcall(vim.api.nvim_win_set_config, win, {
                border    = Border.borderStyle,
                height    = height,
                style     = "minimal",
                title_pos = last_title and "center" or nil,
        })
end

----UI2 ENABLE----------------------------------------------------------------------------------------------------------

ui2.enable({
        enable = true,
        msg    = {
                targets = {
                        [""]         = "msg",
                        bufwrite     = "msg",
                        completion   = "msg",
                        confirm      = "dialog",
                        echoerr      = "msg",
                        echo         = "msg",
                        echomsg      = "msg",
                        empty        = "msg",
                        emsg         = "pager",
                        list_cmd     = "pager",
                        lua_error    = "msg",
                        lua_print    = "msg",
                        progress     = "msg",
                        quickfix     = "msg",
                        rpc_error    = "msg",
                        search_cmd   = "msg",
                        search_count = "msg",
                        shell_cmd    = "pager",
                        shell_err    = "msg",
                        shell_out    = "pager",
                        shell_ret    = "msg",
                        typed_cmd    = "msg",
                        undo         = "msg",
                        verbose      = "pager",
                        wildlist     = "msg",
                        wmsg         = "msg",
                },
                cmd     = { height = 0.6 },
                dialog  = { height = 0.5 },
                pager   = { height = 0.8 },
                msg     = { height = 0.3, timeout = 2000 },
        },
})

----WRAP SET_POS--------------------------------------------------------------------------------------------------------

local orig_set_pos = msgs.set_pos
msgs.set_pos       = function(tgt)
        orig_set_pos(tgt)
        if tgt == "msg" or tgt == nil then
                overrideMsgWin()
                return
        end
        if tgt == "pager" then
                overridePagerWin()
        end
end

----WRAP MSG_SHOW-------------------------------------------------------------------------------------------------------

local orig_msg_show = msgs.msg_show
msgs.msg_show       = function(kind, content, replaceLast, history, append, id, trigger)
        if shouldSkip(kind, content) then
                return
        end

        local title, hl     = resolveTitle(kind, content)
        last_title, last_hl = title, hl

        orig_msg_show(kind, content, replaceLast, history, append, id, trigger)
end

local orig_show_msg = msgs.show_msg
msgs.show_msg       = function(tgt, kind, content, replaceLast, append, id)
        if tgt == "msg" and not dialog_kinds[kind] then
                local text  = contentToText(content)
                local width = 0

                for _, line in ipairs(vim.split(text, "\n")) do
                        width = math.max(width, vim.api.nvim_strwidth(line))
                end

                local lines = #vim.split(text, "\n")

                if width > math.floor(vim.o.columns * 0.75) or lines > 20 then
                        vim.schedule(function()
                                msgs.show_msg("pager", kind, content, replaceLast, append, id)
                                msgs.set_pos("pager")
                        end)
                        return
                end
        end
        orig_show_msg(tgt, kind, content, replaceLast, append, id)
end

--[[LSP PROGRESS--------------------------------------------------------------------------------------------------------

local id = { LspProgressMessages = vim.api.nvim_create_augroup("LspProgressMessages", { clear = true }) }

vim.api.nvim_create_autocmd("LspProgress", {
        group    = id.LspProgressMessages,
        callback = function(ev)
                local value  = ev.data.params.value
                local client = vim.lsp.get_client_by_id(ev.data.client_id)

                if not client then
                        return
                end

                local is_end = value.kind == "end"
                local msg    = value.message and (client.name .. ": " .. value.message)
                           or (client.name .. (is_end and ": done" or ""))

                vim.api.nvim_echo({ { msg } }, false, {
                        id      = "lsp." .. ev.data.client_id,
                        kind    = "progress",
                        source  = "vim.lsp",
                        title   = value.title,
                        status  = is_end and "success" or "running",
                        percent = value.percentage,
                })
        end,
})
--]]

----CMDLINE-------------------------------------------------------------------------------------------------------------
