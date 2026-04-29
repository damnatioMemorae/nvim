return {
        "nvim-mini/mini.diff",
        enabled = true,
        version = false,
        event   = "VeryLazy",
        opts    = {
                view    = {
                        style = "sign",
                        signs = {
                                add    = "▐",
                                change = "🮍",
                                delete = "🭻",
                        },
                },
                options = {
                        algorithm         = "myers",
                        indent_heuristics = true,
                },
        },
        config  = function(_, opts)
                require("mini.diff").setup(opts)

                local groups = {
                        { "Add",    "DiffChanged" },
                        { "Change", "DiffChanged" },
                        { "Delete", "DiffRemoved" },
                }
                require("core.utils").linkHl(groups, "MiniDiffSign")
        end,
}
