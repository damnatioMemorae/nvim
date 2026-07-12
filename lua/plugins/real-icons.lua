return {
        "Mirsmog/real-icons.nvim",
        event = "BufReadPre",
        build = ":RealIconsInstallPack material",
        opts  = {
                pack         = "datapack",
                packs        = {
                        datapack = {
                                type = "vscode",
                                path = vim.fn.expand("~/.vscode-oss/extensions/superant.mc-dp-icons-4.0.2-universal/"),
                        },
                },
                size         = {
                        cols    = 2,
                        rows    = 1,
                        pixels  = 128,
                        padding = 6,
                        trim    = true,
                },
                integrations = {
                        fzf_lua       = true,
                        mini_files    = true,
                        snacks_picker = true,
                },
        },
}
