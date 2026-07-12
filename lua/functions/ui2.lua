require("vim._core.ui2").enable({
        enable = true,
        msg    = {
                targets = {
                        [""]         = "msg",
                        empty        = "msg",
                        bufwrite     = "msg",
                        echo         = "msg",
                        echomsg      = "msg",
                        shell_ret    = "msg",
                        undo         = "msg",
                        wmsg         = "msg",
                        completion   = "msg",
                        confirm      = "msg",
                        confirm_sub  = "msg",
                        echoerr      = "msg",
                        emsg         = "msg",
                        list_cmd     = "msg",
                        lua_error    = "msg",
                        lua_print    = "msg",
                        progress     = "msg",
                        quickfix     = "msg",
                        rpc_error    = "msg",
                        search_cmd   = "msg",
                        search_count = "msg",
                        shell_cmd    = "msg",
                        shell_err    = "msg",
                        shell_out    = "msg",
                        typed_cmd    = "msg",
                        verbose      = "msg",
                        wildlist     = "msg",
                },
                cmd     = { height = 0.5 },
                dialog  = { height = 0.5 },
                pager   = { height = 0.5 },
                msg     = { height = 0.3, timeout = 1500 },
        },
})

local skip_messages = {
        -- WRITE
        "%d+L, %d+B",
        -- "%s",

        -- SEARCH
        "; after #%d+",
        "; before #%d+",
        "^[/?].*", -- searching up/down
        "E486: Pattern not found:",

        -- EDIT
        "%d+ less lines",
        "%d+ fewer lines",
        "%d+ more lines",
        "%d+ change;",
        "%d+ line less;",
        "%d+ more lines?;",
        "%d+ fewer lines;?",
        "1 more line",
        "1 line less",
        "^Hunk %d+ of %d+$",
        "Already at newest change",
        "Already at oldest change",
        "restart failed: +cmd did not quit the server",

        "%d lines yanked",
        "no lines in buffer",

        -- UNDO/REDO
        "%d+ changes?;",
        " changes; brefore #",
        " changes; after #",
        " 1 change; before #",
        " 1 change; after #",

        -- MOVE LINES
        " lines moved",
        " lines indented",
}

local normalized_content = function(src)
        if type(src) ~= "table" then
                return tostring(src or "")
        end

        return table.concat(vim
                .iter(src)
                :map(function(chunk)
                        return type(chunk) == "table" and chunk[2] or nil
                end)
                :totable())
end

local ui2        = require("vim._core.ui2")
local messages   = require("vim._core.ui2.messages")
local o_msg_show = messages.msg_show

local last_title = nil
local last_hl    = "Normal"
local win_hl     = "WildMenu"
local hl_str     = "Normal:" .. win_hl .. ",FloatBorder:" .. win_hl
local border     = Border.Default.Normal

local orig_set_pos = messages.set_pos

local function overrideMsgWin()
        local win = ui2.wins and ui2.wins.msg
        if not (win and vim.api.nvim_win_is_valid(win)) then
                return
        end
        if vim.api.nvim_win_get_config(win).hide then
                return
        end
        pcall(vim.api.nvim_set_option_value, "winhighlight", hl_str, { win = win })
        pcall(vim.api.nvim_win_set_config, win, {
                relative  = "editor",
                anchor    = "NE",
                row       = 2,
                col       = vim.o.columns,
                border    = border,
                style     = "minimal",
                title     = last_title and { { last_title, last_hl } } or nil,
                title_pos = last_title and "center" or nil,
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
        pcall(vim.api.nvim_set_option_value, "winhighlight", hl_str, { win = win })
        pcall(vim.api.nvim_win_set_config, win, {
                border    = border,
                height    = height,
                style     = "minimal",
                title     = last_title and { { last_title, last_hl } } or nil,
                title_pos = last_title and "center" or nil,
        })
end

local function overrideDialogWin()
        local win = ui2.wins and ui2.wins.dialog
        if not (win and vim.api.nvim_win_is_valid(win)) then
                return
        end
        if vim.api.nvim_win_get_config(win).hide then
                return
        end
        local height = vim.api.nvim_win_get_height(win)
        pcall(vim.api.nvim_set_option_value, "winhighlight", hl_str, { win = win })
        pcall(vim.api.nvim_win_set_config, win, {
                border    = border,
                height    = height,
                style     = "minimal",
                title     = last_title and { { last_title, last_hl } } or nil,
                title_pos = last_title and "center" or nil,
        })
end

messages.set_pos = function(tgt)
        orig_set_pos(tgt)
        if tgt == "msg" or tgt == nil then
                overrideMsgWin()
                return
        end
        if tgt == "pager" then
                overridePagerWin()
                return
        end
        if tgt == "dialog" then
                overrideDialogWin()
        end
end

messages.msg_show = function(kind, content, replaceLast, history, append, id, trigger)
        if kind == "bufwrite" then
                return
        end

        local msg = normalized_content(content)

        if vim
                   .iter(skip_messages)
                   :any(function(pat)
                           return msg:find(pat) ~= nil
                   end) then
                return
        end

        o_msg_show(kind, content, replaceLast, history, append, id, trigger)
end
