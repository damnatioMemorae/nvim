local log     = vim.log
local levels = log.levels

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "stevearc/conform.nvim",
        cmd  = "ConnformInfo",
        keys = { { "<leader>f", function() require("conform").format({ async = true, timeout_ms = 2000 }) end, mode = { "n", "x" }, desc = "󱉯 Format buffer" } },
        opts = {
                log_level           = levels.INFO,
                default_format_opts = { lsp_format = "last" },
                formatters          = {
                        clang_format   = { args = { "--style=file" } },
                        shfmt          = { args = { "-ln=bash", "-i=8", "-ci" } },
                        shellcheck     = { args = "'$FILENAME' --format=diff --shell=bash | patch -p1 '$FILENAME'" },
                        odinfmt        = { args = { "-stdin" }, stdin = true },
                        ["shell-home"] = {
                                format = function(_self, _ctx, lines, callback)
                                        local updated = vim.tbl_map(
                                                function(line)
                                                        return line:gsub("/Users/%a+",
                                                                         "$HOME"):gsub("([^/\\])~/", "%1$HOME/")
                                                end,
                                                lines
                                        )
                                        callback(nil, updated)
                                end,
                        },
                },
                formatters_by_ft    = {
                        c          = { "clang_format" },
                        cpp        = { "clang_format" },
                        cs         = { "clang_format" },
                        css        = { "prettierd", "prettier" },
                        go         = { "gofmt", "goimports" },
                        haskell    = { "ormolu" },
                        html       = { "prettierd", "prettier" },
                        javascript = { "prettierd", "prettier" },
                        jsonc      = { "prettierd", "prettier" },
                        json       = { "prettierd", "prettier" },
                        yaml       = { "prettierd", "prettier" },
                        python     = { "ruff", "isort", "black" },
                        sh         = { "shfmt" },
                        zsh        = { "shfmt" },
                        odin       = { "odinfmt" },
                        lua        = { lsp_format = "prefer" },
                        _          = { "trim_whitespace", "trim_newlines", "squeeze_blanks" },
                },
        },
}
