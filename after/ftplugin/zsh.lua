---- ABBREVIATIONS -----------------------------------------------------------------------------------------------------

_G.bufAbbr("//",    "#")
_G.bufAbbr("delay", "sleep")
_G.bufAbbr("const", "local")
_G.bufAbbr("~=",    "=~") -- lua uses `=~`

---- KEYMAPS -----------------------------------------------------------------------------------------------------------

_G.bufMap({
        "<A-s>",
        function()
                vim.cmd([[% substitute_/Users/\w\+/_$HOME/_e]]) -- replace `/Users/…` with `$HOME/`
                vim.lsp.buf.format()
        end,
        mode = "n",
        desc = " Format",
})

---- SHELL SYNTAX HIGHLIGHTING -----------------------------------------------------------------------------------------

vim.cmd(" highlight @keyword.conditional.bash guifg=#74c7ec ")
vim.cmd(" highlight @keyword.repeat.bash      guifg=#74c7ec ")
vim.cmd(" highlight @variable.parameter.bash  guifg=#89b4fa ")
vim.cmd(" highlight @function.call.bash       guifg=#f38ba8 ")
vim.cmd(" highlight @function.builtin.bash    guifg=#cba6f7 ")
vim.cmd(" highlight @function.bash            guifg=#cdd6f4 ")
-- vim.cmd(" highlight @variable.bash            guifg=#cba6f7 ")
vim.cmd(" highlight @variable.bash            guifg=#f38ba8 ")
vim.cmd(" highlight @punctuation.special.bash guifg=#cba6f7 ")

vim.cmd(" highlight zshConditional            guifg=#74c7ec ")
vim.cmd(" highlight zshCommands               guifg=#f38ba8 ")
vim.cmd(" highlight zshFunction               guifg=#cba6f7 ")
vim.cmd(" highlight zshVariableDef            guifg=#cba6f7 ")
vim.cmd(" highlight zshBrackets               guifg=#6c7086 ")
vim.cmd(" highlight zshParentheses            guifg=#6c7086 ")
