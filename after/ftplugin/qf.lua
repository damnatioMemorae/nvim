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

local height = function(percentage) return math.floor(o.lines * percentage * 0.01) end
cmd("resize " .. height(30))

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function findListWindow()
        for _, win in ipairs(api.nvim_list_wins()) do
                local info = fn.getwininfo(win)[1]
                if info.loclist == 1 then
                        g.mode = "l"
                        return win, "ll"
                elseif info.quickfix == 1 then
                        g.mode = "c"
                        return win, "qf"
                end
        end
        return nil
end
findListWindow()
