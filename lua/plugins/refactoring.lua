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

                local k = require("core.utils").uniqueKeymap
                local d = require("refactoring.debug")
                local r = require("refactoring")
                local m = { "n", "x" }

                k(m, "<leader>fi", function() return r.inline_var() end,           { expr = true })
                k(m, "<leader>fe", function() return r.extract_var() end,          { expr = true })
                k(m, "<leader>fu", function() return r.extract_func() .. "_" end,  { expr = true })
                k(m, "<leader>fU", function() return r.extract_func_to_file() end, { expr = true })

                -- k(m, "<leader>fi", function() return r.refactor("Inline Variable") end,          { expr = true })
                -- k(m, "<leader>fe", function() return r.refactor("Extract Variable") end,         { expr = true })
                -- k(m, "<leader>fu", function() return r.refactor("Extract Function") end,         { expr = true })
                -- k(m, "<leader>fU", function() return r.refactor("Extract Function To File") end, { expr = true })

                k(m, "<leader>pv", function() return d.print_var({ output_location = "below", expr = true }) end)
                k(m, "<leader>pV", function() return d.print_var({ output_location = "above", expr = true }) end)
                -- k({ "n" }, "<leader>rp", function() return d.printf({ below = false }) end)
                k({ "n" }, "<leader>pc", function() return d.cleanup({ restore_view = true }) end)

                k(m, "<LocalLeader>z", function() return r.select_refactor() end)
        end,
}
