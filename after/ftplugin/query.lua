local bo    = vim.bo
local opt_l = vim.opt_local

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

bo.commentstring = "; %s"

if bo.buftype == "" then
        opt_l.tabstop   = 2
        opt_l.expandtab = true
end
