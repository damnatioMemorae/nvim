local b      = vim.b
local v      = vim.v
local bo     = vim.bo
local fn     = vim.fn
local ui     = vim.ui
local cmd    = vim.cmd
local api    = vim.api
local lsp    = vim.lsp
local iter   = vim.iter
local levels = vim.log.levels

local p = require "utils.functional".predicates
local T = require "utils.functional".matching.thunk

---- MACRO ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param toggleKey string
---@param reg string
local function startOrStopRecording(toggleKey, reg)
        return function()
                assert(#toggleKey == 1, "toggleKey must be a single character")
                local not_recording = fn.reg_recording() == ""
                if not_recording then
                        cmd.normal { "q" .. reg, bang = true } -- start recording to register
                        return
                end
                local prev_macro = fn.getreg(reg)
                cmd.normal { "q", bang = true }
                local macro = fn.getreg(reg):sub(1, -(#toggleKey + 1))
                if macro ~= "" then
                        fn.setreg(reg, macro)
                        local msg = fn.keytrans(macro)
                        vim.notify(msg, levels.TRACE, { title = "Recorded" })
                else
                        fn.setreg(reg, prev_macro)
                        vim.notify("Aborted", levels.TRACE, { title = "Recording" })
                end
        end
end

---@param reg string vim register (single letter)
local function playRecording(reg)
        return function()
                match(fn.getreg(reg)) {
                        [""] = function() vim.notify("There is no recording.", levels.WARN, { title = "Recording" }) end,
                        _    = function() cmd.normal { "@" .. reg, bang = true } end,
                }
        end
end

local function editMacro(reg)
        return function()
                local macro_content = fn.getreg(reg)
                local title         = ("macro [%s]"):format(reg)
                local fun           = function(input)
                        if not input then return end
                        fn.setreg(reg, input)
                        vim.notify(input, nil)
                end
                ui.input({ prompt = title, default = macro_content }, fun)
        end
end

---- TOGGLE CASE ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function camelSnakeToggle()
        local cword         = fn.expand "<cword>"
        local new_word
        local snake_pattern = "_(%w)"
        local camel_pattern = "([%l%d])(%u)"
        if cword:find(snake_pattern) then
                new_word = cword:gsub(snake_pattern, function(capture) return capture:upper() end)
        elseif cword:find(camel_pattern) then
                new_word = cword:gsub(camel_pattern, function(c1, c2) return c1 .. "_" .. c2:lower() end)
        else
                vim.notify("Neither a snake_case nor camelCase", levels.WARN)
                return
        end
        local line = api.nvim_get_current_line()
        local col  = api.nvim_win_get_cursor(0)[2] + 1
        local start, ending
        while true do
                start, ending = line:find(cword, ending or 1, true)
                if start <= col and ending >= col then break end
        end
        local new_line = line:sub(1, start - 1) .. new_word .. line:sub(ending + 1)
        api.nvim_set_current_line(new_line)
end

-- UPPER -> lower -> Title -> UPPER -> …
local function toggleWordCasing()
        local prev_cursor = api.nvim_win_get_cursor(0)
        local command     = match(fn.expand "<cword>") {
                [p.upper] = "guiw",
                [p.lower] = "guiwgewgUl",
                _         = "gUiw",
        }
        cmd.normal { command, bang = true }
        api.nvim_win_set_cursor(0, prev_cursor)
end

---- LSP CASE RENAME -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function camelSnakeLspRename()
        local cword         = fn.expand "<cword>"
        local snake_pattern = "_(%w)"
        local camel_pattern = "([%l%d])(%u)"
        local snake_cased   = cword:gsub("([%l%d])(%u)", "%1_%2"):lower()
        local camel_cased   = cword:gsub("_(%w)", function(c1) return c1:upper() end)
        local level         = levels.WARN
        local msg           = "Neither snake_case nor camelCase: " .. cword
        local title         = "LSP Rename"
        guard {
                cword:find(snake_pattern), function() lsp.buf.rename(camel_cased) end,
                cword:find(camel_pattern), function() lsp.buf.rename(snake_cased) end,
                function() vim.notify(msg, level, { title = title }) end,
        }
end

---- SMART DUPLICATE -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function smartDuplicate()
        local cursor     = api.nvim_win_get_cursor(0)
        local line       = api.nvim_get_current_line()
        local row        = cursor[1]
        local target_col = ("---@param"):find "%-%-%-@%w+ " or line:find "[:=] " or cursor[2]
        local gsub       = function(...) return line:gsub(...) end
        local com        = match(bo.filetype) {
                javascript = T(gsub, "^(%s*)if(.+{)$", "%1} else if%2"),
                python     = T(gsub, "^(%s*)if( .*:)$", "%1elif%2"),
                lua        = T(gsub, "^(%s*)if( .* then)$", "%1elseif%2"),
                zsh        = T(gsub, "^(%s*)if( .* then)$", "%1elif%2"),
                css        = T(gsub, "(%a+):", {
                        top    = "bottom:",
                        bottom = "top:",
                        right  = "left:",
                        left   = "right:",
                        light  = "dark:",
                        dark   = "light:",
                        width  = "height:",
                        height = "width:",
                }),
                markdown   = T(gsub, "^(%s*)(%d+)%. ", function(indent, num)
                        return indent .. tonumber(num) + 1 .. ". "
                end),
                _          = T(gsub, "^(%s*)(%d+)%. ", function(indent, num)
                        return indent .. tonumber(num) + 1 .. ". "
                end),
        }
        api.nvim_buf_set_lines(0, row, row, false, { com })
        api.nvim_win_set_cursor(0, { row + 1, target_col })
end

---- f & F ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param char "f"|"F"
local function fF(char)
        local target  = fn.getcharstr()
        local pattern = [[\V\C]] .. target
        fn.setreg("/",     pattern)
        fn.search(pattern, char == "f" and "" or "b")
        v.searchforward = 1
end

---- FORMATTING ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function formatWithFallback()
        guard {
                #lsp.get_clients { method = "textDocument/formatting", bufnr = 0 } > 0,
                function()
                        match(bo.ft) { markdown = function() cmd "silent update! %q":format(api.nvim_buf_get_name(0)) end }
                        lsp.buf.format()
                end,
                function()
                        cmd [[% substitute_\s\+$__e]]
                        cmd [[% substitute _\(\n\n\)\n\+_\1_e]]
                        cmd [[silent! /^\%(\n*.\)\@!/,$ delete]]
                end,
        }
end

---- SCROLL OTHER WINDOWS ------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param lines integer
local function scrollLspOrOtherWin(lines)
        return function()
                local winid = b.lsp_floating_preview
                if not winid then
                        local other_win = iter(api.nvim_tabpage_list_wins(0))
                            :find(function(win)
                                    local not_floating = api.nvim_win_get_config(win).relative == ""
                                    local not_this_win = api.nvim_get_current_win() ~= win
                                    return not_floating and not_this_win
                            end)
                        winid = other_win
                end
                if not winid then
                        vim.notify("No other window found", levels.WARN)
                        return
                end
                api.nvim_win_call(winid, function()
                        local topline = fn.winsaveview().topline
                        fn.winrestview { topline = topline + lines }
                end)
        end
end

---- TELEGRAM SEND -------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function send(mode, content)
        local args = match(mode) {
                file = { "telegram-send", "--file" },
                text = { "telegram-send", "--format", "markdown" },
        }
        table.insert(args, content or "") ---@diagnostic disable-line: param-type-mismatch
        vim.system(args, {}, function(out) ---@diagnostic disable-line: param-type-mismatch
                local ok = out.code == 0
                vim.schedule(function()
                        vim.notify(
                                (ok and "Sent %s %s" or "Couldn't send %s %s"):format(mode, content),
                                (ok and levels.INFO or levels.ERROR)
                        )
                end)
        end)
end

local function makeText()
        local lang  = bo.filetype
        local lines = table.concat(api.nvim_buf_get_lines(0, 0, -1, false), "\n")
        return ("```%s\n%s\n```"):format(lang, lines)
end

---@param mode "file"|"text"
local function teleSend(mode)
        local content = match(mode) {
                text = makeText,
                file = T(fn.expand, "%:p"),
        }
        return function(_content)
                return send(mode, _content or content)
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return {
        camelSnakeLspRename  = camelSnakeLspRename,
        camelSnakeToggle     = camelSnakeToggle,
        editMacro            = editMacro,
        fF                   = fF,
        formatWithFallback   = formatWithFallback,
        playRecording        = playRecording,
        scrollLspOrOtherWin  = scrollLspOrOtherWin,
        smartDuplicate       = smartDuplicate,
        startOrStopRecording = startOrStopRecording,
        teleSend             = teleSend,
        toggleTitleCase      = toggleTitleCase,
        toggleWordCasing     = toggleWordCasing,
}
