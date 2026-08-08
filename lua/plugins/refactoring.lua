return {
        "ThePrimeagen/refactoring.nvim",
        dependencies = { "lewis6991/async.nvim" },
        event        = "BufReadPost",
        opts         = {
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
                printf_statements       = { cpp = { 'std::cout << "%s" << "\\n";' } },
                print_var_statements    = { cpp = { 'std::cout << "%s" << %s << "\\n";' } },
                show_success_message    = true,
        },
        config       = function()
                local d = require "refactoring.debug"
                local r = require "refactoring"

                keyq { "<leader>fi", function() return r.inline_var() end, expr = true }
                keyq { "<leader>fe", function() return r.extract_var() end, expr = true }
                keyq { "<leader>fu", function() return r.extract_func() .. "_" end, expr = true }
                keyq { "<leader>fU", function() return r.extract_func_to_file() end, expr = true }

                keyq { "<leader>pv", function() return d.print_var { output_location = "below" } end, expr = true }
                keyq { "<leader>pV", function() return d.print_var { output_location = "above" } end, expr = true }
                -- k({ "n" }, "<leader>rp", function() return d.printf({ below = false }) end)
                keyq { "<leader>pc", function() return d.cleanup { restore_view = true } end }

                keyq { "<LocalLeader>z", function() return r.select_refactor() end }
        end,
}
