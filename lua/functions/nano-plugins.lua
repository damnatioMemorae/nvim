local b   = vim.b
local v   = vim.v
local bo  = vim.bo
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api
local log = vim.log
local lsp = vim.lsp

local b_ft     = bo.ft
local filetype = bo.filetype
local levels  = log.levels

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
                vim.notify("Aborted.", levels.TRACE, { title = "Recording", icon = "󰃾" })
        end
end

---@param reg string vim register (single letter)
function M.playRecording(reg)
        local has_recording = fn.getreg(reg) ~= ""
        if has_recording then
                cmd.normal { "@" .. reg, bang = true }
        else
                local msg = "There is no recording."
                vim.notify(msg, levels.WARN, { title = "Recording", icon = "󰃾" })
        end
end

function M.editMacro(reg)
        local macro_content = fn.getreg(reg)
        local title         = ("Edit macro [%s]"):format(reg)
        local icon          = "󰃽"

        vim.ui.input({ prompt = icon .. " " .. title, default = macro_content }, function(input)
                if not input then return end
                fn.setreg(reg, input)
                vim.notify(input, nil, { title = title, icon = icon })
        end)
end

---- CASE TOGGLE ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function M.camelSnakeToggle()
        local cword         = fn.expand("<cword>")
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
        local prev_cursor = api.nvim_win_get_cursor(0)
        local cword       = fn.expand("<cword>")
        local command

        if cword == cword:upper() then
                command = "guiw"
        elseif cword == cword:lower() then
                command = "guiwgUl"
        else
                command = "gUiw"
        end

        cmd.normal { command, bang = true }
        api.nvim_win_set_cursor(0, prev_cursor)
end

function M.toggleTitleCase()
        local prev_cursor = api.nvim_win_get_cursor(0)
        local cword       = fn.expand("<cword>")
        local command     = cword == cword:lower() and "guiwgUl" or "guiw"
        cmd.normal { command, bang = true }
        api.nvim_win_set_cursor(0, prev_cursor)
end

---- LSP CASE RENAME -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

function M.camelSnakeLspRename()
        local cword         = fn.expand("<cword>")
        local snake_pattern = "_(%w)"
        local camel_pattern = "([%l%d])(%u)"

        if cword:find(snake_pattern) then
                local camel_cased = cword:gsub(snake_pattern, function(c1) return c1:upper() end)
                lsp.buf.rename(camel_cased)
        elseif cword:find(camel_pattern) then
                local snake_cased = cword:gsub(camel_pattern, "%1_%2"):lower()
                lsp.buf.rename(snake_cased)
        else
                local msg = "Neither snake_case nor camelCase: " .. cword
                vim.notify(msg, levels.WARN, { title = "LSP Rename" })
        end
end

---- SMART DUPLICATE -----------------------------------------------------------------------------------------------------------------------------------------------------------------------

function M.smartDuplicate()
        local row, col = unpack(api.nvim_win_get_cursor(0))
        local line     = api.nvim_get_current_line()
        local ft       = filetype

        if ft == "css" then
                line = line:gsub("(%a+):", {
                        top    = "bottom:",
                        bottom = "top:",
                        right  = "left:",
                        left   = "right:",
                        light  = "dark:",
                        dark   = "light:",
                        width  = "height:",
                        height = "width:",
                })
        elseif ft == "javascript" or ft == "typescript" or ft == "swift" then
                line = line:gsub("^(%s*)if(.+{)$", "%1} else if%2")
        elseif ft == "lua" then
                line = line:gsub("^(%s*)if( .* then)$", "%1elseif%2")
        elseif ft == "zsh" or ft == "bash" then
                line = line:gsub("^(%s*)if( .* then)$", "%1elif%2")
        elseif ft == "python" then
                line = line:gsub("^(%s*)if( .*:)$", "%1elif%2")
        elseif ft == "markdown" then
                line = line:gsub("^(%s*)(%d+)%. ", function(indent, num)
                        local increment = tonumber(num) + 1
                        return indent .. increment .. ". "
                end)
        end

        api.nvim_buf_set_lines(0, row, row, false, { line })

        local _, luadoc_field_pos = line:find("%-%-%-@%w+ ")
        local _, value_pos        = line:find("[:=] ")
        local target_col          = luadoc_field_pos or value_pos or col
        api.nvim_win_set_cursor(0, { row + 1, target_col })
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
        local formatting_lsp = lsp.get_clients({ method = "textDocument/formatting", bufnr = 0 })

        if #formatting_lsp > 0 then
                if b_ft == "markdown" then
                        local vim_cmd = ("silent update! %q"):format(api.nvim_buf_get_name(0))
                        cmd(vim_cmd)
                end
                lsp.buf.format()
        else
                cmd([[% substitute_\s\+$__e]])
                cmd([[% substitute _\(\n\n\)\n\+_\1_e]])
                cmd([[silent! /^\%(\n*.\)\@!/,$ delete]])
        end
end

---- ALIGNMENT -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function M.alignSelectionByChar()
        local sep = fn.input("Enter table separator: ")
        if sep == "" then sep = "&" end

        local mode = fn.mode()
        if not vim.tbl_contains({ "v", "V", "\22" }, mode) then
                print("Not in visual mode")
                return
        end

        local s_pos = fn.getpos("v")
        local e_pos = fn.getpos(".")

        local s_row, e_row = s_pos[2], e_pos[2]
        if s_row > e_row then
                s_row, e_row = e_row, s_row
        end

        local lines = api.nvim_buf_get_lines(0, s_row - 1, e_row, false)
        if not lines or #lines == 0 then
                print("No lines selected")
                return
        end

        local split_lines, col_widths, indents = {}, {}, {}

        for _, line in ipairs(lines) do
                local indent = line:match("^%s*") or ""
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

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
