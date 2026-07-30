local bo        = vim.bo
local fn        = vim.fn
local uv        = vim.uv
local cmd       = vim.cmd
local api       = vim.api
local env       = vim.env
local lsp       = vim.lsp
local opt_l = vim.opt_local

local map  = _G.bufMap
local abbr = _G.bufAbbr

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

bo.expandtab  = true
bo.shiftwidth = 4
bo.tabstop    = 4

opt_l.listchars:append{ multispace = " " }
opt_l.formatoptions:append("r")

---- VIRTUAL ENVIRONMENT -----------------------------------------------------------------------------------------------

vim.defer_fn(function()
                     local venv = (uv.cwd() or "") .. "/.venv"
                     if uv.fs_stat(venv) then env.VIRTUAL_ENV = venv end ---@diagnostic disable-line: name-style-check
             end, 1)

---- ABBREVIATIONS -----------------------------------------------------------------------------------------------------

abbr("true",     "True")
abbr("false",    "False")
abbr("//",       "#")
abbr("--",       "#")
abbr("null",     "None")
abbr("nil",      "None")
abbr("none",     "None")
abbr("trim",     "strip")
abbr("function", "def")

---- KEYMAPS -----------------------------------------------------------------------------------------------------------

map({
        "g/",
        function()
                cmd.normal{ '"zyi"vi"', bang = true }

                local flag_in_line = api.nvim_get_current_line():match("re%.([MIDSUA])")
                local data         = {
                        regex        = fn.getreg("z"),
                        flags        = flag_in_line and "g" .. flag_in_line:gsub("D", "S"):lower() or "g",
                        substitution = "", -- TODO
                        delimiter    = '"',
                        flavor       = "python",
                        testString   = "",
                }

                require("rip-substitute.open-at-regex101").open(data)
        end,
        mode = "n",
        desc = " Open in regex101",
})

map({
        "<M-s>",
        function()
                lsp.buf.code_action({ context = { only = { "source.fixAll.ruff" } }, apply = true }) ---@diagnostic disable-line: assign-type-mismatch,missing-fields
                vim.defer_fn(lsp.buf.format, 50)
        end,
        mode = "n",
        desc = " Fixall & Format",
})

map({
        "<leader>ci",
        function()
                lsp.buf.code_action({ filter = function(a) return a.title:find("import") ~= nil end, apply = true })
        end,
        mode = "n",
        desc = " Import word under cursor",
})
