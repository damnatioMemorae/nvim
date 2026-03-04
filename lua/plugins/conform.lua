return {
        "stevearc/conform.nvim",
        event  = { "BufReadPre", "BufNewFile", "BufWritePost" },
        config = function()
                local conform = require("conform")

                local ft      = {
                        c          = { "clang_format" },
                        cpp        = { "clang_format" },
                        css        = { "prettierd", "prettier" },
                        -- glsl       = { "clang_format" },
                        go         = { "gofmt", "goimports" },
                        html       = { "prettierd", "prettier" },
                        javascript = { "prettierd", "prettier" },
                        jsonc      = { "prettierd", "prettier" },
                        json       = { "prettierd", "prettier" },
                        yaml       = { "prettierd", "prettier" },
                        python     = { "ruff", "isort", "black" },
                        sh         = { "shfmt" },
                        zsh        = { "shfmt" },
                }

                local options = {
                        clang_format = { args = { "--style=file" } },
                        shfmt        = { args = { "-ln=bash", "-i=8", "-ci" } },
                }

                conform.setup({
                        formatters_by_ft = ft,
                        formatters       = options,
                })

                vim.keymap.set({ "n", "v" }, "<leader>f", function()
                        conform.format({
                                lsp_fallback = true,
                                async        = true,
                                timeout_ms   = 2000,
                        })
                end)
        end,
}
