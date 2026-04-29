return {
        "necrom4/convy.nvim",
        cmd  = "Convy",
        keys = { { "<LocalLeader>h", mode = { "n", "v", "x" }, function() require("convy").show_selector() end } },
        opts = { window = { blend = Config.blend, border = Border.borderStyle } },
}
