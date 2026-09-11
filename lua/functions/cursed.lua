local api   = vim.api
local cmd   = vim.cmd
local iter  = vim.iter
local mc_ns = api.nvim_create_namespace "nvim.multicursor"

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function mcGet()
        return iter(api.nvim_buf_get_extmarks(0, mc_ns, 0, -1, {}))
            :map(function(mark) return { mark[2] + 1, mark[3] } end)
            :totable()
end

function M.mcClear()
        api.nvim_buf_clear_namespace(0, mc_ns, 0, -1)
end

function M.mcAdd(_)
        return function()
                local row_prime, col_prime = unpack(api.nvim_win_get_cursor(0))
                local row_last             = row_prime
                local cursors              = mcGet()
                iter(cursors)
                    :each(function(pos)
                            local row = pos[1]
                            if _ > 0 and row > row_last then
                                    row_last = row
                            elseif _ < 0 and row < row_last then
                                    row_last = row
                            end
                    end)
                local row = row_last + _
                if row < 1 or row > api.nvim_buf_line_count(0) then return end
                iter(cursors)
                    :each(function(pos) if pos[1] == row and pos[2] == col_prime then return end end)
                api.nvim_mcursor(0, { row, col_prime })
                cmd "normal! 1q="
        end
end

function M.mcDel(_)
        return function()
                local row_prime, col_prime = unpack(api.nvim_win_get_cursor(0))
                local cursors              = mcGet()
                local index
                local row_tgt
                iter(cursors)
                    :enumerate()
                    :map(function(i, pos)
                            local row = pos[1]
                            if _ > 0 and row > row_prime then
                                    if not row_tgt or row > row_tgt then
                                            row_tgt = row
                                            index   = i
                                    end
                            elseif _ < 0 and row < row_prime then
                                    if not row_tgt or row < row_tgt then
                                            row_tgt = row
                                            index   = i
                                    end
                            end
                    end)
                if not index then return end
                table.remove(cursors, index)
                api.nvim_buf_clear_namespace(0, mc_ns, 0, -1)
                iter(cursors)
                    :each(function(pos) api.nvim_mcursor(0, pos) end)
                api.nvim_win_set_cursor(0, { row_prime, col_prime })
                cmd "normal! 1q="
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
