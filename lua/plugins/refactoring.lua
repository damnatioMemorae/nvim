return {
        "ThePrimeagen/refactoring.nvim",
        dependencies = { "kevinhwang91/promise-async" },
        event        = "VeryLazy",
        config       = function()
                require("refactoring").setup({
                        -- prompt_func_return_type = {
                        --         go   = true,
                        --         cpp  = true,
                        --         c    = true,
                        --         java = true,
                        --         h    = false,
                        --         hpp  = false,
                        --         cxx  = false,
                        -- },
                        -- prompt_func_param_type  = {
                        --         go   = true,
                        --         cpp  = true,
                        --         c    = true,
                        --         java = true,
                        --         h    = false,
                        --         hpp  = false,
                        --         cxx  = false,
                        -- },
                        -- printf_statements       = {
                        --         cpp = { 'std::cout << "%s" << "\\n";' },
                        -- },
                        -- print_var_statements    = {
                        --         cpp = { 'std::cout << "%s" << %s << "\\n";' },
                        -- },
                        -- show_success_message    = true,
                })

                local map = _G.smartMap
                local d   = require("refactoring.debug")
                local r   = require("refactoring")

                map({ "<leader>fi", function() return r.inline_var() end, expr = true })
                map({ "<leader>fe", function() return r.extract_var() end, expr = true })
                map({ "<leader>fu", function() return r.extract_func() .. "_" end, expr = true })
                map({ "<leader>fU", function() return r.extract_func_to_file() end, expr = true })

                map({ "<leader>pv", function() return d.print_var({ output_location = "below", expr = true }) end })
                map({ "<leader>pV", function() return d.print_var({ output_location = "above", expr = true }) end })
                -- k({ "n" }, "<leader>rp", function() return d.printf({ below = false }) end)
                map({ "<leader>pc", function() return d.cleanup({ restore_view = true }) end })

                map({ "<LocalLeader>z", function() return r.select_refactor() end })
        end,
}
