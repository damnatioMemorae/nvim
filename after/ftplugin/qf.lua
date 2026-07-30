local o     = vim.o
local cmd   = vim.cmd
local opt_l = vim.opt_local

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

opt_l.statuscolumn   = ""
opt_l.number         = false
opt_l.relativenumber = false

local function width(percentage)
        return o.columns * (percentage * 0.01)
end


cmd("wincmd L")
cmd("vertical resize " .. width(20))
