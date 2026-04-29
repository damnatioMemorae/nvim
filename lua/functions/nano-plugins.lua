local M = {}
------------------------------------------------------------------------------------------------------------------------

---1. start/stop with just one keypress
---2. add notification & sound for recording
---@param toggleKey string key used to trigger this function
---@param reg string vim register (single letter)
function M.startOrStopRecording(toggleKey, reg)
        local not_recording = vim.fn.reg_recording() == ""

        if not_recording then
                vim.cmd.normal{ "q" .. reg, bang = true }
        else
                vim.cmd.normal{ "q", bang = true }
                local macro = vim.fn.getreg(reg):sub(1, -(#toggleKey + 1))
                if macro ~= "" then
                        vim.fn.setreg(reg, macro)
                        local msg = vim.fn.keytrans(macro)
                        vim.notify(msg, vim.log.levels.TRACE, { title = "Recorded", icon = "󰃽" })
                else
                        vim.notify("Aborted.", vim.log.levels.TRACE, { title = "Recording", icon = "󰜺" })
                end
        end
end

function M.editMacro(reg)
        local macro_content = vim.fn.getreg(reg)
        local title         = ("Edit macro [%s]"):format(reg)
        local icon          = "󰃽"

        vim.ui.input({ prompt = icon .. " " .. title, default = macro_content }, function(input)
                if not input then return end
                vim.fn.setreg(reg, input)
                vim.notify(input, nil, { title = title, icon = icon })
        end)
end

------------------------------------------------------------------------------------------------------------------------

-- Simplified implementation of coerce.nvim
function M.camelSnakeToggle()
        local cword         = vim.fn.expand("<cword>")
        local new_word
        local snake_pattern = "_(%w)"
        local camel_pattern = "([%l%d])(%u)"

        if cword:find(snake_pattern) then
                new_word = cword:gsub(snake_pattern, function(capture) return capture:upper() end)
        elseif cword:find(camel_pattern) then
                new_word = cword:gsub(camel_pattern, function(c1, c2) return c1 .. "_" .. c2:lower() end)
        else
                vim.notify("Neither a snake_case nor camelCase", vim.log.levels.WARN)
                return
        end

        local line = vim.api.nvim_get_current_line()
        local col  = vim.api.nvim_win_get_cursor(0)[2] + 1
        local start, ending

        while true do
                start, ending = line:find(cword, ending or 1, true)
                if start <= col and ending >= col then break end
        end

        local new_line = line:sub(1, start - 1) .. new_word .. line:sub(ending + 1)
        vim.api.nvim_set_current_line(new_line)
end

-- UPPER -> lower -> Title -> UPPER -> …
function M.toggleWordCasing()
        local prev_cursor = vim.api.nvim_win_get_cursor(0)
        local cword       = vim.fn.expand("<cword>")
        local cmd

        if cword == cword:upper() then
                cmd = "guiw"
        elseif cword == cword:lower() then
                cmd = "guiwgUl"
        else
                cmd = "gUiw"
        end

        vim.cmd.normal{ cmd, bang = true }
        vim.api.nvim_win_set_cursor(0, prev_cursor)
end

------------------------------------------------------------------------------------------------------------------------

-- Simplified implementation of `coerce.nvim`
function M.camelSnakeLspRename()
        local cword         = vim.fn.expand("<cword>")
        local snake_pattern = "_(%w)"
        local camel_pattern = "([%l%d])(%u)"

        if cword:find(snake_pattern) then
                local camel_cased = cword:gsub(snake_pattern, function(c1) return c1:upper() end)
                vim.lsp.buf.rename(camel_cased)
        elseif cword:find(camel_pattern) then
                local snake_cased = cword:gsub(camel_pattern, "%1_%2"):lower()
                vim.lsp.buf.rename(snake_cased)
        else
                local msg = "Neither snake_case nor camelCase: " .. cword
                vim.notify(msg, vim.log.levels.WARN, { title = "LSP Rename" })
        end
end

function M.toggleTitleCase()
        local prev_cursor = vim.api.nvim_win_get_cursor(0)
        local cword       = vim.fn.expand("<cword>")
        local cmd         = cword == cword:lower() and "guiwgUl" or "guiw"
        vim.cmd.normal{ cmd, bang = true }
        vim.api.nvim_win_set_cursor(0, prev_cursor)
end

------------------------------------------------------------------------------------------------------------------------

function M.smartDuplicate()
        local row, col = unpack(vim.api.nvim_win_get_cursor(0))
        local line     = vim.api.nvim_get_current_line()
        local ft       = vim.bo.filetype

        -- filetype-specific tweaks
        if ft == "css" then
                -- stylua: ignore
                line = line:gsub("(%a+):", {
                        top = "bottom:",
                        bottom = "top:",
                        right = "left:",
                        left = "right:",
                        light = "dark:",
                        dark = "light:",
                        width = "height:",
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
        elseif ft == "markdown" then -- increment numbered list
                line = line:gsub("^(%s*)(%d+)%. ", function(indent, num)
                        local increment = tonumber(num) + 1
                        return indent .. increment .. ". "
                end)
        end

        -- insert duplicated line
        vim.api.nvim_buf_set_lines(0, row, row, false, { line })

        -- move cursor down, and to value/field (if any)
        local _, luadoc_field_pos = line:find("%-%-%-@%w+ ")
        local _, value_pos        = line:find("[:=] ")
        local target_col          = luadoc_field_pos or value_pos or col
        vim.api.nvim_win_set_cursor(0, { row + 1, target_col })
end

------------------------------------------------------------------------------------------------------------------------

-- `fF` work with `nN` instead of `;,` (inspired by tT.nvim)
---@param char "f"|"F"
function M.fF(char)
        local target  = vim.fn.getcharstr() -- awaits user input for a char
        local pattern = [[\V\C]] .. target
        vim.fn.setreg("/",     pattern)
        vim.fn.search(pattern, char == "f" and "" or "b") -- move cursor
        vim.v.searchforward = 1                           -- `n` always forward, `N` always backward
end

------------------------------------------------------------------------------------------------------------------------

function M.formatWithFallback()
        local formatting_lsp = vim.lsp.get_clients{ method = "textDocument/formatting", bufnr = 0 }

        if #formatting_lsp > 0 then
                -- save for efm-formatters that don't use stdin
                if vim.bo.ft == "markdown" then
                        -- saving with explicit name prevents issues when changing `cwd`
                        -- `:update!` suppresses "The file has been changed since reading it!!!"
                        local vim_cmd = ("silent update! %q"):format(vim.api.nvim_buf_get_name(0))
                        vim.cmd(vim_cmd)
                end
                vim.lsp.buf.format()
        else
                vim.cmd([[% substitute_\s\+$__e]])            -- remove trailing spaces
                vim.cmd([[% substitute _\(\n\n\)\n\+_\1_e]])  -- remove duplicate blank lines
                vim.cmd([[silent! /^\%(\n*.\)\@!/,$ delete]]) -- remove blanks at end of file
        end
end

------------------------------------------------------------------------------------------------------------------------

function M.alignSelectionByChar()
        local sep = vim.fn.input("Enter table separator: ")
        if sep == "" then sep = "&" end

        -- Ensure we are in visual mode
        local mode = vim.fn.mode()
        if not vim.tbl_contains({ "v", "V", "\22" }, mode) then
                print("Not in visual mode")
                return
        end

        -- Get positions of the selection
        local s_pos = vim.fn.getpos("v")
        local e_pos = vim.fn.getpos(".")

        local s_row, e_row = s_pos[2], e_pos[2]
        if s_row > e_row then
                s_row, e_row = e_row, s_row
        end

        -- Get selected lines from the buffer (0-based indexing)
        local lines = vim.api.nvim_buf_get_lines(0, s_row - 1, e_row, false)
        if not lines or #lines == 0 then
                print("No lines selected")
                return
        end

        local split_lines, col_widths, indents = {}, {}, {}

        for _, line in ipairs(lines) do
                -- Detect indentation (spaces or tabs)
                local indent = line:match("^%s*") or ""
                table.insert(indents, indent)

                -- Remove indentation before splitting
                local stripped = line:sub(#indent + 1)
                local cols     = vim.split(stripped, sep, true) ---@diagnostic disable-line: param-type-mismatch
                table.insert(split_lines, cols)

                -- Compute max width for each column
                for i, col in ipairs(cols) do
                        local width   = vim.fn.strdisplaywidth(vim.trim(col))
                        col_widths[i] = math.max(col_widths[i] or 0, width)
                end
        end

        -- Rebuild aligned lines
        local aligned_lines = {}
        for idx, cols in ipairs(split_lines) do
                local aligned = {}
                for i, col in ipairs(cols) do
                        local txt = vim.trim(col)
                        local pad = col_widths[i] - vim.fn.strdisplaywidth(txt)
                        table.insert(aligned, txt .. string.rep(" ", pad))
                end
                table.insert(aligned_lines, indents[idx] .. table.concat(aligned, " " .. sep .. " "))
        end

        -- Replace the original lines in the buffer with aligned ones
        vim.api.nvim_buf_set_lines(0, s_row - 1, e_row, false, aligned_lines)
end

---@param lines integer
function M.scrollLspOrOtherWin(lines)
        local winid = vim.b.lsp_floating_preview

        if not winid then
                local other_win = vim.iter(vim.api.nvim_tabpage_list_wins(0)):find(function(win)
                        local not_floating = vim.api.nvim_win_get_config(win).relative == ""
                        local not_this_win = vim.api.nvim_get_current_win() ~= win
                        return not_floating and not_this_win
                end)
                winid           = other_win
        end

        if not winid then
                vim.notify("No other window found.", vim.log.levels.WARN)
                return
        end
        vim.api.nvim_win_call(winid, function()
                local topline = vim.fn.winsaveview().topline
                vim.fn.winrestview{ topline = topline + lines }
        end)
end

------------------------------------------------------------------------------------------------------------------------
return M
