return {
        "Wansmer/treesj",
        dependencies = { "nvim-treesitter/nvim-treesitter" },
        keys         = {
                {
                        "<leader>s",
                        function() require("treesj").toggle() end,
                        desc = "TreeSJ toggle split/join",
                },
        },
        opts         = {
                use_default_keymaps = false,
                check_syntax_error  = true,
                max_join_length     = 800,
                cursor_behavior     = "hold",
                notify              = true,
                dot_repeat          = true,
        },
}
