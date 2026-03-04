local bkeymap       = require("core.utils").bufKeymapconfig.utils
--------------------------------------------------------------------------------

vim.opt_local.spell = true
vim.opt_local.wrap  = true

-- INFO for `pass` buffers, no plugins are loaded. Manually creating some these
-- mappings as substitute for convenience.
if vim.env.NO_PLUGINS then
    bkeymap("n", "ss", "VP", { desc = "Substitute line" })
    bkeymap("n", "<CR>", "ZZ", { desc = "Save and exit" })
end
