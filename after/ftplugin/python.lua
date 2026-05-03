vim.bo.expandtab  = true
vim.bo.shiftwidth = 4
vim.bo.tabstop    = 4

vim.opt_local.listchars:append{ multispace = " " }
vim.opt_local.formatoptions:append("r")

---- VIRTUAL ENVIRONMENT -----------------------------------------------------------------------------------------------

vim.defer_fn(function()
                     local venv = (vim.uv.cwd() or "") .. "/.venv"
                     if vim.uv.fs_stat(venv) then vim.env.VIRTUAL_ENV = venv end ---@diagnostic disable-line: name-style-check
             end, 1)

---- ABBREVIATIONS -----------------------------------------------------------------------------------------------------

local abbr = require("core.utils").bufAbbrev
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

local bkeymap = require("core.utils").bufKeymap
bkeymap("n", "g/", function()
                vim.cmd.normal{ '"zyi"vi"', bang = true }

                local flag_in_line = vim.api.nvim_get_current_line():match("re%.([MIDSUA])")
                local data         = {
                        regex        = vim.fn.getreg("z"),
                        flags        = flag_in_line and "g" .. flag_in_line:gsub("D", "S"):lower() or "g",
                        substitution = "", -- TODO
                        delimiter    = '"',
                        flavor       = "python",
                        testString   = "",
                }

                require("rip-substitute.open-at-regex101").open(data)
        end, { desc = " Open in regex101" })

bkeymap("n", "<A-s>", function()
                vim.lsp.buf.code_action{ context = { only = { "source.fixAll.ruff" } }, apply = true } ---@diagnostic disable-line: assign-type-mismatch,missing-fields
                vim.defer_fn(vim.lsp.buf.format, 50)
        end, { desc = " Fixall & Format" })

bkeymap("n", "<leader>ci", function()
                vim.lsp.buf.code_action{ filter = function(a) return a.title:find("import") ~= nil end, apply = true }
        end, { desc = " Import word under cursor" })
