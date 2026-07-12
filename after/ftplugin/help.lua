vim.diagnostic.enable(false, { bufnr = 0 })
vim.opt_local.wrap         = true
vim.opt_local.colorcolumn  = ""
vim.opt_local.statuscolumn = ""

_G.bufMap({ "q", vim.cmd.bwipeout, desc = "Quit" })
_G.bufMap({ "<A-w>", vim.cmd.bwipeout, desc = "Quit" })

local ext = vim.api.nvim_buf_get_name(0):match("%.(%w+)$")
if ext == "txt" then
        _G.bufMap({ "<LocalLeader>s", "gO", mode = "n", remap = true })
end

vim.cmd("wincmd L")
