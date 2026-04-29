return {
        "ThePrimeagen/refactoring.nvim",
        event  = "VeryLazy",
        config = function()
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

                local mode   = { "n", "x" }
                local rf     = require("refactoring")
                local keymap = require("core.utils").uniqueKeymap

                keymap(mode, "<leader>fi", function() return rf.refactor("Inline Variable") end,          { expr = true })
                keymap(mode, "<leader>fe", function() return rf.refactor("Extract Variable") end,         { expr = true })
                keymap(mode, "<leader>fu", function() return rf.refactor("Extract Function") end,         { expr = true })
                keymap(mode, "<leader>fU", function() return rf.refactor("Extract Function To File") end, { expr = true })

                keymap({ "n" }, "<leader>rc",     function() return rf.debug.cleanup() end)
                keymap({ "n" }, "<leader>rp",     function() return rf.debug.printf({ below = false }) end)
                keymap(mode,    "<leader>rv",     function() return rf.debug.print_var() end)
                keymap(mode,    "<LocalLeader>z", function() return rf.select_refactor({ prefer_ex_cmd = true }) end)
        end,
}
