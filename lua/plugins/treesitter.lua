local ensure_installed = { "all" }
local ignoreParsers    = { "toml", "ipkg" }

return {
        "nvim-treesitter/nvim-treesitter",
        lazy  = false,
        build = ":TSUpdate",
        init  = function()
                if vim.fn.executable("tree-sitter") == 1 then
                        vim.defer_fn(function() require("nvim-treesitter").install(ensure_installed) end, 2000)
                else
                        local msg = "`tree-sitter-cli` not found. Skipping auto-install of parsers."
                        vim.notify(msg, vim.log.levels.WARN, { title = "Treesitter" })
                end

                vim.api.nvim_create_autocmd("FileType", {
                        desc     = "User: enable treesitter highlighting",
                        callback = function(ctx)
                                local has_started                = pcall(vim.treesitter.start, ctx.buf)
                                local dont_use_treesitter_indent = { "zsh", "bash", "markdown", "javascript" }

                                if has_started and not vim.list_contains(dont_use_treesitter_indent, ctx.match) then
                                        vim.bo[ctx.buf].indentexpr = "v:lua.require('nvim-treesitter').indentexpr()"
                                end
                        end,
                })

                vim.api.nvim_create_autocmd({ "ColorScheme", "VimEnter" }, {
                        desc     = "User: highlights for the Treesitter `comments` parser",
                        callback = function()
                                vim.api.nvim_set_hl(0, "@lsp.type.comment", {})
                                vim.api.nvim_set_hl(0, "@comment.bold",     { bold = true })
                        end,
                })

                -- `ts_query_ls`: use the custom directory set in the treesitter config
                local ts_dir = require("nvim-treesitter.config").get_install_dir("parser")
                vim.lsp.config("ts_query_ls", { init_options = { parser_install_directories = { ts_dir } } })
        end,
        opts  = { install_dir = vim.fn.stdpath("data") .. "/treesitter" },
}
