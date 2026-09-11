local fn  = vim.fn
local api = vim.api

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function M.visualProcessSelection(processingFunc)
        return function()
                local line_first = fn.line "v"
                local line_last  = fn.line "."
                if line_first > line_last then
                        line_first, line_last = line_last, line_first
                end

                local bufn  = api.nvim_get_current_buf()
                local lines = api.nvim_buf_get_lines(bufn, line_first - 1, line_last, false)

                local processed_lines = processingFunc(lines)

                api.nvim_buf_set_lines(bufn, line_first - 1, line_last, false, processed_lines)

                local keys = api.nvim_replace_termcodes("<ESC>", true, false, true)
                api.nvim_feedkeys(keys, "m", false)
        end
end

function M.cmdProcessSelection(processingFunc)
        return function(opts)
                local line_start = opts.line1
                local line_end   = opts.line2

                local bufn  = api.nvim_get_current_buf()
                local lines = api.nvim_buf_get_lines(bufn, line_start - 1, line_end, false)

                local processed_lines = processingFunc(lines)

                api.nvim_buf_set_lines(bufn, line_start - 1, line_end, false, processed_lines)
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
