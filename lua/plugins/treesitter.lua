local keymap = require("core.utils").uniqueKeymap

return {
        "nvim-treesitter/nvim-treesitter",
        event  = "BufReadPre",
        build  = ":TSUpdate",
        init   = function()
                ---- HIGHLIGHTS ----------------------------------------------------------------------------------------

                local highlight = function(bufnr, lang)
                        if not vim.treesitter.language.add(lang) then
                                return vim.notify(
                                        string.format("Treesitter cannot load parser for: %s", lang),
                                        vim.log.levels.WARN,
                                        { title = "Treesitter" })
                        end
                        vim.treesitter.start(bufnr)
                end

                vim.api.nvim_create_autocmd("FileType", {
                        callback = function(args)
                                local ft  = vim.bo.filetype
                                local bt  = vim.bo.buftype
                                local buf = args.buf

                                if bt ~= "" then
                                        return
                                end

                                local ok, treesitter = pcall(require, "nvim-treesitter")
                                if not ok then
                                        return
                                end

                                ---- FOLDS -----------------------------------------------------------------------------

                                if ft == "javascriptreact" or ft == "typescript" then
                                        vim.opt_local.foldmethod = "indent"
                                else
                                        vim.opt_local.foldmethod = "expr"
                                        vim.opt_local.foldexpr   = "v:lua.vim.treesitter.foldexpr()"
                                end

                                vim.schedule(function()
                                        if vim.fn.mode() ~= "t" then
                                                vim.cmd("silent! normal! zx")
                                        end
                                end)

                                ---- INDENT ----------------------------------------------------------------------------

                                local dont_use_treesitter_indent = {
                                        "zsh",
                                        "bash",
                                        "markdown",
                                        "javascript",
                                        "python",
                                        "html",
                                        "yaml",
                                        "markdown",
                                }
                                if not vim.tbl_contains(dont_use_treesitter_indent, ft) then
                                        vim.bo.indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
                                end

                                ---- INSTALL PARSERS -------------------------------------------------------------------

                                if vim.fn.executable("tree-sitter") ~= 1 then
                                        vim.api.nvim_echo(
                                                { { "tree-sitter CLI not found. Parser cannot be installed.", "ErrorMsg" } },
                                                true, {})
                                        return false
                                end

                                if not vim.treesitter.language.get_lang(ft) then
                                        return
                                end

                                if vim.list_contains(treesitter.get_installed(), ft) then
                                        highlight(buf, ft)
                                elseif vim.list_contains(treesitter.get_available(), ft) then
                                        treesitter.install(ft):await(function()
                                                highlight(buf, ft)
                                        end)
                                end
                        end,
                })

                keymap("v",          "n", "]n", { remap = true, desc = "Select next node" })
                keymap("v",          "N", "[n", { remap = true, desc = "Select previous node" })
                keymap({ "v", "o" }, "m", "an", { remap = true, desc = "Select child node" })
                keymap({ "v", "o" }, "M", "in", { remap = true, desc = "Select parent node" })
        end,
        opts   = { install_dir = vim.fn.stdpath("data") .. "/treesitter" },
        config = function(_, opts)
                local treesitter = require("nvim-treesitter")
                treesitter.setup(opts)
                if vim.fn.executable("tree-sitter") ~= 1 then
                        vim.api.nvim_echo({ { "tree-sitter CLI not found. Parser cannot be installed.", "ErrorMsg" } },
                                          true, {})
                        return false
                end
                treesitter.install(opts.install)
        end,
}
