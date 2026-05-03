return {
        "gruvw/strudel.nvim",
        event  = "VeryLazy",
        build  = "npm ci",
        opts   = { ui = { hide_menu_panel = true, hide_top_bar = true } },
        config = function(_, opts)
                require("strudel").setup(opts)
        end,
}
