local function r(_) return function() return require "refactoring"[_]() end end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "ThePrimeagen/refactoring.nvim",
        dependencies = { "lewis6991/async.nvim" },
        keys         = {
                { "<leader>ri",     r "inline_var",     expr = true, mode = { "n", "x" } },
                { "<leader>rI",     r "inline_func",    expr = true, mode = { "n", "x" } },
                { "<leader>re",     r "extract_var",    expr = true, mode = { "n", "x" } },
                { "<leader>rE",     r "extract_func",   expr = true, mode = { "n", "x" } },
                { "<LocalLeader>z", r "select_refactor" },
        },
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
}
