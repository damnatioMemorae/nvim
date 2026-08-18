local b   = vim.b
local v   = vim.v
local bo  = vim.bo
local fn  = vim.fn
local ui  = vim.ui
local cmd = vim.cmd
local api = vim.api
local log = vim.log
local lsp = vim.lsp

local levels = log.levels

require "utils.functional" ()

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
---- MACRO ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param toggleKey string
---@param reg string
function M.startOrStopRecording(toggleKey, reg)
        assert(#toggleKey == 1, "toggleKey must be a single character")
        local not_recording = fn.reg_recording() == ""
        if not_recording then
                cmd.normal { "q" .. reg, bang = true } -- start recording to register
                return
        end

        local prev_macro = fn.getreg(reg)
        cmd.normal { "q", bang = true }
        local macro = fn.getreg(reg):sub(1, -(#toggleKey + 1)) -- since the key itself is also recorded
        if macro ~= "" then
                fn.setreg(reg, macro)
                local msg = fn.keytrans(macro)
                vim.notify(msg, levels.TRACE, { title = "Recorded", icon = "󰃽" })
        else
                fn.setreg(reg, prev_macro) -- prevent `toggleKey` filling the register
                vim.notify("Aborted", levels.TRACE, { title = "Recording", icon = "󰃾" })
        end
end

---@param reg string vim register (single letter)
function M.playRecording(reg)
        match(fn.getreg(reg)) {
                [""] = function() vim.notify("There is no recording.", levels.WARN, { title = "Recording" }) end,
                _    = function() cmd.normal { "@" .. reg, bang = true } end,
        }
end

function M.editMacro(reg)
        where(function(_) ui.input({ prompt = _.title, default = _.macro_content }, _.fun) end) {
                macro_content = fn.getreg(reg),
                title         = ("macro [%s]"):format(reg),
                fun           = function(input)
                        if not input then return end
                        fn.setreg(reg, input)
                        vim.notify(input, nil)
                end,
        }
end

---- TOGGLE CASE ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function M.camelSnakeToggle()
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
function M.toggleWordCasing()
        where(function(_)
                cmd.normal { _.command, bang = true }
                api.nvim_win_set_cursor(0, _.prev_cursor)
        end) {
                    prev_cursor = api.nvim_win_get_cursor(0),
                    command     = match(fn.expand "<cword>") {
                            function(_) return _:upper() end, "guiw",
                            function(_) return _:lower() end, "guiwgUl",
                            _ = "gUiw",
                    },

            }
end

function M.toggleTitleCase()
        where(function(_)
                cmd.normal { _.cmd, bang = true }
                api.nvim_win_set_cursor(0, _.cursor)
        end) {
                    cursor = api.nvim_win_get_cursor(0),
                    cmd    = match(fn.expand "<cword>") {
                            function(_) return _:lower() end, "guiwgUl",
                            _ = "guiw",
                    },
            }
end

---- LSP CASE RENAME -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

function M.camelSnakeLspRename()
        local cword = fn.expand "<cword>"
        where(function(_)
                guard {
                        cword:find(_.snake_pattern), function() lsp.buf.rename(_.camel_cased) end,
                        cword:find(_.camel_pattern), function() lsp.buf.rename(_.snake_cased) end,
                        function() vim.notify(_.msg, _.level, { title = _.title }) end,
                }
        end) {
                    snake_pattern = "_(%w)",
                    camel_pattern = "([%l%d])(%u)",
                    snake_cased   = cword:gsub("([%l%d])(%u)", "%1_%2"):lower(),
                    camel_cased   = cword:gsub("_(%w)", function(c1) return c1:upper() end),
                    level         = levels.WARN,
                    msg           = "Neither snake_case nor camelCase: " .. cword,
                    title         = "LSP Rename",
            }
end

---- SMART DUPLICATE -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

function M.smartDuplicate()
        local cursor = api.nvim_win_get_cursor(0)
        local line   = api.nvim_get_current_line()
        where(function(_)
                api.nvim_buf_set_lines(0, _.row, _.row, false, { _.line })
                api.nvim_win_set_cursor(0, { _.row + 1, _.target_col })
        end) {
                    row        = cursor[1],
                    target_col = ("---@param"):find "%-%-%-@%w+ " or line:find "[:=] " or cursor[2],
                    line       = match(bo.filetype) {
                            javascript = line:gsub("^(%s*)if(.+{)$", "%1} else if%2"),
                            python     = line:gsub("^(%s*)if( .*:)$", "%1elif%2"),
                            lua        = line:gsub("^(%s*)if( .* then)$", "%1elseif%2"),
                            zsh        = line:gsub("^(%s*)if( .* then)$", "%1elif%2"),
                            markdown   = line:gsub("^(%s*)(%d+)%. ", function(indent, num)
                                    local increment = tonumber(num) + 1
                                    return indent .. increment .. ". "
                            end),
                            css        = line:gsub("(%a+):", {
                                    top    = "bottom:",
                                    bottom = "top:",
                                    right  = "left:",
                                    left   = "right:",
                                    light  = "dark:",
                                    dark   = "light:",
                                    width  = "height:",
                                    height = "width:",
                            }),
                    },
            }
end

---- f & F ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param char "f"|"F"
function M.fF(char)
        local target  = fn.getcharstr()
        local pattern = [[\V\C]] .. target
        fn.setreg("/",     pattern)
        fn.search(pattern, char == "f" and "" or "b")
        v.searchforward = 1
end

---- FORMATTING ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function M.formatWithFallback()
        guard {
                #lsp.get_clients { method = "textDocument/formatting", bufnr = 0 } > 0,
                function()
                        match(bo.ft) {
                                markdown = function() cmd "silent update! %q":format(api.nvim_buf_get_name(0)) end,
                        }
                        lsp.buf.format()
                end,
                function()
                        cmd [[% substitute_\s\+$__e]]
                        cmd [[% substitute _\(\n\n\)\n\+_\1_e]]
                        cmd [[silent! /^\%(\n*.\)\@!/,$ delete]]
                end,
        }
end

---- ALIGNMENT -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function M.alignSelectionByChar()
        local sep = fn.input "Enter table separator: "
        if sep == "" then sep = "&" end

        local mode = fn.mode()
        if not vim.tbl_contains({ "v", "V", "\22" }, mode) then
                print "Not in visual mode"
                return
        end

        local s_pos = fn.getpos "v"
        local e_pos = fn.getpos "."

        local s_row, e_row = s_pos[2], e_pos[2]
        if s_row > e_row then
                s_row, e_row = e_row, s_row
        end

        local lines = api.nvim_buf_get_lines(0, s_row - 1, e_row, false)
        if not lines or #lines == 0 then
                print "No lines selected"
                return
        end

        local split_lines, col_widths, indents = {}, {}, {}

        for _, line in ipairs(lines) do
                local indent = line:match "^%s*" or ""
                table.insert(indents, indent)

                local stripped = line:sub(#indent + 1)
                local cols     = vim.split(stripped, sep, true) ---@diagnostic disable-line: param-type-mismatch
                table.insert(split_lines, cols)

                for i, col in ipairs(cols) do
                        local width   = fn.strdisplaywidth(vim.trim(col))
                        col_widths[i] = math.max(col_widths[i] or 0, width)
                end
        end

        local aligned_lines = {}
        for idx, cols in ipairs(split_lines) do
                local aligned = {}
                for i, col in ipairs(cols) do
                        local txt = vim.trim(col)
                        local pad = col_widths[i] - fn.strdisplaywidth(txt)
                        table.insert(aligned, txt .. string.rep(" ", pad))
                end
                table.insert(aligned_lines, indents[idx] .. table.concat(aligned, " " .. sep .. " "))
        end

        api.nvim_buf_set_lines(0, s_row - 1, e_row, false, aligned_lines)
end

---- SCROLL OTHER WINDOWS ------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param lines integer
function M.scrollLspOrOtherWin(lines)
        local winid = b.lsp_floating_preview

        if not winid then
                local other_win = vim
                    .iter(api.nvim_tabpage_list_wins(0))
                    :find(function(win)
                            local not_floating = api.nvim_win_get_config(win).relative == ""
                            local not_this_win = api.nvim_get_current_win() ~= win
                            return not_floating and not_this_win
                    end)

                winid = other_win
        end

        if not winid then
                vim.notify("No other window found.", levels.WARN)
                return
        end
        api.nvim_win_call(winid, function()
                local topline = fn.winsaveview().topline
                fn.winrestview { topline = topline + lines }
        end)
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
function M.teleSend(mode)
        local content = match(mode) {
                text = function() makeText() end,
                file = function() return fn.expand "%:p" end,
        }

        return function(_content)
                return send(mode, _content or content)
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
