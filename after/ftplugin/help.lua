vim.diagnostic.enable(false, { bufnr = 0 })
vim.opt_local.colorcolumn = ""
vim.opt_local.wrap        = true

local bkeymap = require("core.utils").bufKeymap

bkeymap("n", "q",     vim.cmd.bwipeout, { desc = "Quit" })
bkeymap("n", "<D-w>", vim.cmd.bwipeout, { desc = "Quit" })

local ext = vim.api.nvim_buf_get_name(0):match("%.(%w+)$")
if ext == "txt" then bkeymap("n", "gs", "gO", { remap = true }) end
