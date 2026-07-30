local cmd       = vim.cmd
local api       = vim.api
local diag      = vim.diagnostic
local opt_l = vim.opt_local

local map = _G.bufMap

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

diag.enable(false, { bufnr = 0 })
opt_l.wrap         = true
opt_l.colorcolumn  = ""
opt_l.statuscolumn = ""

map({ "q", cmd.bwipeout, desc = "Quit" })
map({ "<M-w>", cmd.bwipeout, desc = "Quit" })

local ext = api.nvim_buf_get_name(0):match("%.(%w+)$")
if ext == "txt" then
        map({ "<LocalLeader>s", "gO", mode = "n", remap = true })
end

cmd("wincmd L")
