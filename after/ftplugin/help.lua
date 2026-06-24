vim.diagnostic.enable(false, { bufnr = 0 })
vim.opt_local.colorcolumn = ""
vim.opt_local.wrap        = true

_G.bufMap({ "q", vim.cmd.bwipeout, mode = "n", desc = "Quit" })
_G.bufMap({ "<D-w>", vim.cmd.bwipeout, mode = "n", desc = "Quit" })

local ext = vim.api.nvim_buf_get_name(0):match("%.(%w+)$")
if ext == "txt" then
        _G.bufMap({ "gs", "gO", mode = "n", remap = true })
end
