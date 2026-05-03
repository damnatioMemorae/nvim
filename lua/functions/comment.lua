local M = {}

local config = {
        hrChar                   = "-",
        formatterWantsPadding    = { "python", "swift", "toml" },
        ignoreReplaceModeHelpers = { "markdown" },
}

---@return string?
local function getCommentstr()
        local com_str = vim.bo.commentstring
        if not com_str or com_str == "" then
                vim.notify("No commentstring for " .. vim.bo.ft, vim.log.levels.WARN, { title = "Comment" })
                return
        end
        return com_str
end

------------------------------------------------------------------------------------------------------------------------

function M.setupReplaceModeHelpersForComments()
        vim.api.nvim_create_autocmd("ModeChanged", {
                desc     = "User: uppercase the line when leaving replace mode on a comment",
                pattern  = "r:*", -- left replace-mode
                callback = function(ctx)
                        if vim.list_contains(config.ignoreReplaceModeHelpers, vim.bo[ctx.buf].ft) then return end
                        local line      = vim.api.nvim_get_current_line()
                        local com_chars = vim.trim(vim.bo.commentstring:format(""))
                        if vim.startswith(vim.trim(line), com_chars) then
                                vim.api.nvim_set_current_line(line:upper())
                        end
                end,
        })
        vim.api.nvim_create_autocmd("ModeChanged", {
                desc     = "User: automatically enter replace mode at label position",
                pattern  = "*:r", -- entered replace-mode
                callback = function(ctx)
                        if vim.list_contains(config.ignoreReplaceModeHelpers, vim.bo[ctx.buf].ft) then return end
                        local line      = vim.api.nvim_get_current_line()
                        local com_chars = vim.trim(vim.bo.commentstring:format(""))
                        if vim.startswith(vim.trim(line), com_chars) then
                                vim.cmd.normal{ "^" .. #com_chars + 1 .. "l", bang = true }
                        end
                end,
        })
end

---@param replaceModeLabel? any
function M.commentHr(replaceModeLabel)
        assert(vim.bo.commentstring ~= "", "Comment string not set for " .. vim.bo.ft)
        local start_ln = vim.api.nvim_win_get_cursor(0)[1]

        local ln = start_ln
        local line, indent
        repeat
                line   = vim.api.nvim_buf_get_lines(0, ln - 1, ln, true)[1]
                indent = line:match("^%s*")
                ln     = ln - 1
        until line ~= "" or ln == 0

        local indent_length  = vim.bo.expandtab and #indent or #indent * vim.bo.tabstop
        local com_str_length = #(vim.bo.commentstring:format(""))
        local textwidth      = vim.o.textwidth > 0 and vim.o.textwidth or 80
        local hr_length      = textwidth - (indent_length + com_str_length)

        local hr              = config.hrChar:rep(hr_length)
        local hr_with_comment = vim.bo.commentstring:format(hr)
        if not vim.list_contains(config.formatterWantsPadding, vim.bo.ft) then
                hr_with_comment = hr_with_comment:gsub(" ", config.hrChar)
        end

        local full_line = indent .. hr_with_comment
        if vim.bo.ft == "markdown" then
                full_line = "---"
        end

        vim.api.nvim_buf_set_lines(0, start_ln, start_ln, true, { full_line })
        if not replaceModeLabel then
                vim.api.nvim_buf_set_lines(0, start_ln + 1, start_ln + 1, true, { "" })
        end

        vim.api.nvim_win_set_cursor(0, { start_ln + 1, #indent })
        if replaceModeLabel then
                vim.cmd.normal({ com_str_length + 1 .. "l", bang = true })
                vim.cmd.startreplace()
        end
end

function M.duplicateLineAsComment()
        local com_str = getCommentstr()
        if not com_str then
                return
        end

        local lnum, col       = unpack(vim.api.nvim_win_get_cursor(0))
        local cur_line        = vim.api.nvim_get_current_line()
        local indent, content = cur_line:match("^(%s*)(.*)")
        local commented_line  = indent .. com_str:format(content)
        vim.api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { commented_line, cur_line })
        vim.api.nvim_win_set_cursor(0, { lnum + 1, col })
end

function M.docstring()
        vim.cmd.TSTextobjectGotoPreviousStart("@function.outer")

        local ft     = vim.bo.filetype
        local indent = vim.api.nvim_get_current_line():match("^%s*")
        local ln     = vim.api.nvim_win_get_cursor(0)[1]

        if ft == "python" then
                indent = indent .. (" "):rep(4)
                vim.api.nvim_buf_set_lines(0, ln, ln, false, { indent .. ('"'):rep(6) })
                vim.api.nvim_win_set_cursor(0, { ln + 1, #indent + 3 })
                vim.cmd.startinsert()
        elseif ft == "javascript" then
                vim.cmd.normal{ "t)", bang = true }
                vim.lsp.buf.code_action({
                        filter = function(action) return action.title == "Infer parameter types from usage" end,
                        apply  = true,
                })
                vim.defer_fn(function()
                                     vim.api.nvim_win_set_cursor(0, { ln + 1, 0 })
                                     vim.cmd.normal({ "t)", bang = true })
                             end, 100)
        elseif ft == "typescript" then
                vim.api.nvim_buf_set_lines(0, ln - 1, ln - 1, false, { indent .. "/**  */" })
                vim.api.nvim_win_set_cursor(0, { ln, #indent + 4 })
                vim.cmd.startinsert()
        else
                vim.notify("Unsupported filetype.", vim.log.levels.WARN)
        end
end

------------------------------------------------------------------------------------------------------------------------

---@param where? "eol"|"above"|"below"
function M.addComment(where)
        assert(vim.bo.commentstring ~= "", "Comment string not set for " .. vim.bo.ft)
        local lnum = vim.api.nvim_win_get_cursor(0)[1]

        if where == "above" or where == "below" then
                if where == "above" then
                        lnum = lnum - 1
                end
                vim.api.nvim_buf_set_lines(0, lnum, lnum, true, { "" })
                lnum = lnum + 1
                vim.api.nvim_win_set_cursor(0, { lnum, 0 })
        end

        local place_holder_at_end = vim.bo.commentstring:find("%%s$") ~= nil
        local line                = vim.api.nvim_get_current_line()

        local indent     = ""
        local empty_line = line == ""
        if empty_line then
                local i         = lnum
                local last_line = vim.api.nvim_buf_line_count(0)
                while vim.fn.getline(i) == "" and i < last_line do
                        i = i + 1
                end
                indent = vim.fn.getline(i):match("^%s*")
        end
        local spacing  = vim.list_contains(config.formatterWantsPadding, vim.bo.ft) and "  " or " "
        local new_line = empty_line and indent or line .. spacing

        local com_chars = vim.trim(vim.bo.commentstring:format(""))
        if place_holder_at_end then com_chars = com_chars .. " " end
        vim.api.nvim_set_current_line(new_line .. com_chars)

        if place_holder_at_end then
                vim.cmd.startinsert{ bang = true }
        else
                local placeholder_pos = vim.bo.commentstring:find("%%s") - 1
                local new_cursor_pos  = { lnum, #new_line + placeholder_pos }
                vim.api.nvim_win_set_cursor(0, new_cursor_pos)
                vim.cmd.startinsert()
        end
end

------------------------------------------------------------------------------------------------------------------------
return M
