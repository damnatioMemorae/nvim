return {
        "ThePrimeagen/refactoring.nvim",
        event        = "VeryLazy",
        dependencies = { "nvim-lua/plenary.nvim", "nvim-treesitter/nvim-treesitter" },
        config       = function()
                require("refactoring").setup({
                        prompt_func_return_type = {
                                go   = true,
                                cpp  = true,
                                c    = true,
                                java = true,
                                h    = false,
                                hpp  = false,
                                cxx  = false,
                        },
                        prompt_func_param_type  = {
                                go   = true,
                                cpp  = true,
                                c    = true,
                                java = true,
                                h    = false,
                                hpp  = false,
                                cxx  = false,
                        },
                        printf_statements       = {
                                cpp = { 'std::cout << "%s" << "\\n";' },
                        },
                        print_var_statements    = {
                                cpp = { 'std::cout << "%s" << %s << "\\n";' },
                        },
                        show_success_message    = true,
                })

                local map      = vim.keymap.set
                local refactor = require("refactoring")
                local opts     = { expr = true }
                local modes    = { "n", "x" }

                map(modes, "<leader>fi", function() return refactor.refactor("Inline Variable") end, opts)
                map(modes, "<leader>fe", function() return refactor.refactor("Extract Variable") end, opts)
                map(modes, "<leader>fu", function() return refactor.refactor("Extract Function") end, opts)
                map(modes, "<leader>fU", function() return refactor.refactor("Extract Function To File") end, opts)
                map(modes, ",z", function() return refactor.select_refactor({ prefer_ex_cmd = true }) end)
                map("n", "<leader>rp", function() return refactor.debug.printf({ below = false }) end)
                map(modes, "<leader>rv", function() return refactor.debug.print_var() end)
                map("n", "<leader>rc", function() return refactor.debug.cleanup() end)
        end,
}
