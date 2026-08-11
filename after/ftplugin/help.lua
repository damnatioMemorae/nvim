local fn    = vim.fn
local cmd   = vim.cmd
local diag  = vim.diagnostic
local opt_l = vim.opt_local

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

diag.enable(false, { bufnr = 0 })
opt_l.wrap          = true
opt_l.colorcolumn   = ""
opt_l.statuscolumn  = ""
opt_l.concealcursor = "n"

bufq { "q", cmd.bwipeout, desc = "Quit" }
bufq { "<M-w>", cmd.bwipeout, desc = "Quit" }

guard { fn.expand "%:e", function() bufq { "<LocalLeader>s", "gO", mode = "n", remap = true } end }

cmd "wincmd L"
