local bo  = vim.bo
local fn  = vim.fn
local api = vim.api
local cmd = vim.cmd

local config = {
        hrChar                   = "-",
        formatterWantsPadding    = { "python", "swift", "toml" },
        ignoreReplaceModeHelpers = { "markdown" },
}

local M = {}

---- HELPERS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function M.setupReplaceModeHelpersForComments()
        auq "ModeChanged" {
                desc     = "User: uppercase the line when leaving replace mode on a comment",
                pattern  = "r:*",
                callback = function(ctx)
                        match(bo[ctx.buf].ft) {
                                [config.ignoreReplaceModeHelpers] = function() end,
                                _                                 = function()
                                        local line      = api.nvim_get_current_line()
                                        local com_chars = vim.trim(bo.commentstring:format "")
                                        if vim.startswith(vim.trim(line), com_chars) then
                                                api.nvim_set_current_line(line:upper())
                                        end
                                end,
                        }
                end,
        }
        auq "ModeChanged" {
                desc     = "User: automatically enter replace mode at label position",
                pattern  = "*:r",
                callback = function(ctx)
                        match(bo[ctx.buf].ft) {
                                [config.ignoreReplaceModeHelpers] = function() end,
                                _                                 = function()
                                        local line      = api.nvim_get_current_line()
                                        local com_chars = vim.trim(bo.commentstring:format "")
                                        if vim.startswith(vim.trim(line), com_chars) then
                                                cmd.normal { "^" .. #com_chars + 1 .. "l", bang = true }
                                        end
                                end }
                end,
        }
end

---- COMMANDS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param replaceModeLabel? any
function M.commentHr(replaceModeLabel)
        assert(bo.commentstring ~= "", "Comment string not set for " .. bo.ft)
        local start_ln = api.nvim_win_get_cursor(0)[1]
        -- local start_ln = vim.pos.cursor(0)[1]

        local ln = start_ln
        local line, indent
        repeat
                line   = api.nvim_buf_get_lines(0, ln - 1, ln, true)[1]
                indent = line:match "^%s*"
                ln     = ln - 1
        until line ~= "" or ln == 0

        local indent_length  = bo.expandtab and #indent or #indent * bo.tabstop
        local com_str_length = #(bo.commentstring:format "")
        -- local textwidth      = vim.o.textwidth > 0 and vim.o.textwidth or 80
        local textwidth      = api.nvim_win_get_width(0) * 1
        local hr_length      = textwidth - (indent_length + com_str_length)

        local hr              = config.hrChar:rep(hr_length)
        local hr_with_comment = bo.commentstring:format(hr)
        if not vim.list_contains(config.formatterWantsPadding, bo.ft) then
                hr_with_comment = hr_with_comment:gsub(" ", config.hrChar)
        end

        where(function(_) api.nvim_buf_set_lines(0, _.ln, _.ln, true, { _.full }) end) {
                ln   = start_ln,
                full = match(bo.ft) {
                        markdown = "---",
                        _        = indent .. hr_with_comment,
                },
        }

        if not replaceModeLabel then
                api.nvim_buf_set_lines(0, start_ln + 1, start_ln + 1, true, { "" })
        end

        api.nvim_win_set_cursor(0, { start_ln + 1, #indent })
        if replaceModeLabel then
                cmd.normal { com_str_length + 1 .. "l", bang = true }
                cmd.startreplace()
        end
end

function M.duplicateLineAsComment()
        assert(bo.commentstring ~= "", "Comment string not set for " .. bo.ft)
        local lnum, col       = unpack(api.nvim_win_get_cursor(0))
        -- local lnum, col       = unpack(vim.pos.cursor(0))
        local cur_line        = api.nvim_get_current_line()
        local indent, content = cur_line:match "^(%s*)(.*)"
        local commented_line  = indent .. bo.commentstring:format(content)
        api.nvim_buf_set_lines(0, lnum - 1, lnum, false, { commented_line, cur_line })
        api.nvim_win_set_cursor(0, { lnum + 1, col })
end

---@param where? "eol"|"above"|"below"
function M.addComment(where)
        assert(bo.commentstring ~= "", "Comment string not set for " .. bo.ft)
        local lnum = match(where) {
                above = api.nvim_win_get_cursor(0)[1] - 1,
                _     = api.nvim_win_get_cursor(0)[1],
                -- above = vim.pos.cursor(0)[1] - 1,
                -- _     = vim.pos.cursor(0)[1],
        }

        match(where) {
                [{ "above", "below" }] = function()
                        api.nvim_buf_set_lines(0, lnum, lnum, true, { "" })
                        api.nvim_win_set_cursor(0, { lnum + 1, 0 })
                end }

        local place_holder_at_end = bo.commentstring:find "%%s$" ~= nil
        local line                = api.nvim_get_current_line()

        local indent     = ""
        local empty_line = line == ""
        if empty_line then
                local i         = lnum
                local last_line = api.nvim_buf_line_count(0)
                while fn.getline(i) == "" and i < last_line do
                        i = i + 1
                end
                indent = fn.getline(i):match "^%s*"
        end
        local spacing  = vim.list_contains(config.formatterWantsPadding, bo.ft) and "  " or " "
        local new_line = empty_line and indent or line .. spacing

        local com_chars = vim.trim(bo.commentstring:format "")
        if place_holder_at_end then com_chars = com_chars .. " " end
        api.nvim_set_current_line(new_line .. com_chars)

        if place_holder_at_end then
                cmd.startinsert { bang = true }
        else
                local placeholder_pos = bo.commentstring:find "%%s" - 1
                local new_cursor_pos  = { lnum, #new_line + placeholder_pos }
                api.nvim_win_set_cursor(0, new_cursor_pos)
                cmd.startinsert()
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
