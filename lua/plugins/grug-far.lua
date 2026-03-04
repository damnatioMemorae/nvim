local modes = { "n", "v" }

return {
        "MagicDuck/grug-far.nvim",
        enabled = false,
        event   = "VeryLazy",
        cmd     = "GrugFar",
        keys    = {
                {
                        "<leader>sr",
                        mode = modes,
                        desc = "Search and Replace in project (GrugFar)",
                        function()
                                require("grug-far").open({ transient = true })
                        end,
                },
                {
                        "<leader>sb",
                        mode = modes,
                        desc = "Search and Replace in buffer (GrugFar)",
                        function()
                                require("grug-far").open({
                                        transient = true,
                                        prefills  = { paths = vim.fn.expand("%") },
                                })
                        end,
                },
                {
                        "<leader>sg",
                        mode = modes,
                        desc = "Search and Replace selection (GrugFar)",
                        function()
                                require("grug-far").with_visual_selection({
                                        transient = true,
                                        prefills  = { paths = vim.fn.expand("%") },
                                })
                        end,
                },
                opts = { engine = "ripgrep" },
        },
}
