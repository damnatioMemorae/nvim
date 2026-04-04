return {
        "hmdfrds/focal.nvim",
        event  = "VeryLazy",
        opts   = { enabled = true },
        config = function(_, opts)
                local focal = require("focal")
                focal.setup(opts)
                focal.register_renderer({
                        name           = "pdf-renderer",
                        extensions     = { "pdf" },
                        priority       = 80,
                        needs_terminal = true,
                        is_available   = function()
                                return vim.fn.executable("pdftoppm") == 1
                        end,
                        get_geometry   = function(_path, _stat, env)
                                return { width = env.max_width, height = env.max_height }
                        end,
                        render         = function(_ctx, done)
                                done(true, { output = "...", fit = { width = 40, height = 30 } })
                        end,
                        clear          = function() end,
                        cleanup        = function() end,
                })
        end,
}
