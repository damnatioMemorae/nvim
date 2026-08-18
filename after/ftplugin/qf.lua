local o     = vim.o
local g     = vim.g
local fn    = vim.fn
local api   = vim.api
local cmd   = vim.cmd
local opt_l = vim.opt_local

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

opt_l.statuscolumn   = ""
opt_l.signcolumn     = "no"
opt_l.number         = false
opt_l.relativenumber = false

local width  = function(percentage) return o.columns * (tonumber(percentage) * 0.01) end
local height = function(percentage) return o.lines * (percentage * 0.01) end

cmd("resize " .. height(20))
-- cmd "wincmd L"
-- cmd("vertical resize " .. width(25))

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function findListWindow()
        for _, win in ipairs(api.nvim_list_wins()) do
                local info = fn.getwininfo(win)[1]
                if info.loclist == 1 then
                        g.qf_mode = "l"
                        return win, "ll"
                elseif info.quickfix == 1 then
                        g.qf_mode = "c"
                        return win, "qf"
                end
        end
        return nil
end
findListWindow()
