------------------------------------------------------------------------------------------------------------------------
-- ABBREVIATIONS

local abbr = require("core.utils").bufAbbrev

abbr("//", "#")
abbr("delay", "sleep")
abbr("const", "local")
abbr("~=", "=~") -- lua uses `=~`

------------------------------------------------------------------------------------------------------------------------
-- KEYMAPS

local bkeymap = require("core.utils").bufKeymap

bkeymap("n", "<A-s>", function()
    vim.cmd([[% substitute_/Users/\w\+/_$HOME/_e]]) -- replace `/Users/…` with `$HOME/`
    vim.lsp.buf.format()
end, { desc = " Format" })

------------------------------------------------------------------------------------------------------------------------
--[[ SHELL SYNTAX HIGHLIGHT

vim.cmd(" highlight @keyword.conditional.bash guifg=#74c7ec ")
vim.cmd(" highlight @keyword.repeat.bash      guifg=#74c7ec ")
vim.cmd(" highlight @variable.parameter.bash  guifg=#89b4fa ")
vim.cmd(" highlight @function.call.bash       guifg=#f38ba8 ")
vim.cmd(" highlight @function.builtin.bash    guifg=#cba6f7 ")
vim.cmd(" highlight @function.bash            guifg=#cdd6f4 ")
vim.cmd(" highlight @variable.bash            guifg=#cba6f7 ")
vim.cmd(" highlight @variable.bash            guifg=#f38ba8 ")
vim.cmd(" highlight @punctuation.special.bash guifg=#cba6f7 ")

vim.cmd(" highlight zshConditional            guifg=#74c7ec ")
vim.cmd(" highlight zshCommands               guifg=#f38ba8 ")
vim.cmd(" highlight zshFunction               guifg=#cba6f7 ")
vim.cmd(" highlight zshVariableDef            guifg=#cba6f7 ")
vim.cmd(" highlight zshBrackets               guifg=#6c7086 ")
vim.cmd(" highlight zshParentheses            guifg=#6c7086 ")
--]]
