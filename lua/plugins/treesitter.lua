-- local ensure_installed = { "all" }
local ensure_installed = {
        "all",
}

---@param node "inc" | "dec" | "next" | "prev"
local function incSelect(node)
        if node == "inc" then
                if vim.treesitter.get_parser(nil, nil, { error = false }) then
                        require("vim.treesitter._select").select_parent(vim.v.count1)
                else
                        vim.lsp.buf.selection_range(vim.v.count1)
                end
        elseif node == "dec" then
                if vim.treesitter.get_parser(nil, nil, { error = false }) then
                        require("vim.treesitter._select").select_child(vim.v.count1)
                else
                        vim.lsp.buf.selection_range(-vim.v.count1)
                end
        elseif node == "next" then
                require("vim.treesitter._select").select_next(vim.v.count1)
        elseif node == "prev" then
                require("vim.treesitter._select").select_prev(vim.v.count1)
        end
end

return {
        "nvim-treesitter/nvim-treesitter",
        lazy   = false,
        build  = ":TSUpdate",
        init   = function()
                ----HIGHLIGHTS------------------------------------------------------------------------------------------

                local highlight = function(bufnr, lang)
                        if not vim.treesitter.language.add(lang) then
                                return vim.notify(
                                        string.format("Treesitter cannot load parser for: %s", lang),
                                        vim.log.levels.INFO,
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

                                ----FOLDS-------------------------------------------------------------------------------

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

                                ----INDENT------------------------------------------------------------------------------

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

                                ----INSTALL PARSERS---------------------------------------------------------------------

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

                -- vim.api.nvim_create_autocmd("FileType", {
                --         desc     = "User: enable treesitter highlighting",
                --         callback = function(ctx)
                --                 local has_started                = pcall(vim.treesitter.start, ctx.buf)
                --                 local dont_use_treesitter_indent = { "zsh", "bash", "markdown", "javascript" }
                --
                --                 if has_started and not vim.list_contains(dont_use_treesitter_indent, ctx.match) then
                --                         vim.bo[ctx.buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
                --                 end
                --         end,
                -- })

                vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
                        desc     = "User: highlights for the Treesitter `comments` parser",
                        callback = function()
                                vim.api.nvim_set_hl(0, "@lsp.type.comment", {})
                                vim.api.nvim_set_hl(0, "@comment.bold",     { bold = true })
                        end,
                })

                -- `ts_query_ls`: use the custom directory set in the treesitter config
                -- local ts_dir = require("nvim-treesitter.config").get_install_dir("parser")
                -- vim.lsp.config("ts_query_ls", { init_options = { parser_install_directories = { ts_dir } } })

                vim.keymap.set("x",          "n", function() incSelect("next") end, { desc = "Select next node" })
                vim.keymap.set("x",          "N", function() incSelect("prev") end, { desc = "Select previous node" })
                vim.keymap.set({ "x", "o" }, "m", function() incSelect("inc") end,  { desc = "Select child node" })
                vim.keymap.set({ "x", "o" }, "M", function() incSelect("dec") end,  { desc = "Select parent node" })
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
