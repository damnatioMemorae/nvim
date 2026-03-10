return {
        "mikavilpas/yazi.nvim",
        version = "*",
        event   = "VeryLazy",
        keys    = {
                {
                        "<leader><leader>y",
                        mode = { "n", "v" },
                        "<cmd>Yazi<CR>",
                        desc = "Open yazi at the current file",
                },
                {
                        "<leader><leader>Y",
                        "<cmd>Yazi cwd<CR>",
                        desc = "Open yazi in current working directory",
                },
        },
        opts    = {
                open_for_directories                 = true,
                open_multiple_tabs                   = true,
                yazi_floating_window_winblend        = Config.winblend,
                yazi_floating_window_border          = Border.borderStyle,
                bufdelete_implementation             = "bundled-snacks",
                picker_add_copy_relative_path_action = "snacks.picker",
        },
}
