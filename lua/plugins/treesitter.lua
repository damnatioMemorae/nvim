local parsers       = "all"
local ignoreParsers = { "toml", "ipkg" }

return {
        "nvim-treesitter/nvim-treesitter",
        branch = "master",
        event  = "BufReadPre",
        build  = ":TSUpdate",
        opts   = {
                parser_install_dir    = "~/.local/share/nvim/site",
                auto_install          = true,
                ensure_installed      = parsers,
                ignore_install        = ignoreParsers,
                highlight             = {
                        enable                            = true,
                        additional_vim_regex_highlighting = false,
                },
                indent                = { enable = true, disable = { "markdown" } },
                textobjects           = {
                        lsp_interop = { enable = true, border = Border.borderStyle },
                        select      = { lookahead = true, include_surrounding_whitespace = false },
                },
                incremental_selection = {
                        enable  = true,
                        keymaps = {
                                init_selection    = ",v",
                                node_incremental  = "<CR>",
                                scope_incremental = ",v",
                                node_decremental  = "<Backspace>",
                        },
                },
        },
        config = function(_, opts)
                require("nvim-treesitter.configs").setup(opts)
        end,
}
