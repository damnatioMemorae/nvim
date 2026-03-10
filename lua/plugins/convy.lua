local prefix = Config.prefix

return {
        "necrom4/convy.nvim",
        cmd  = "Convy",
        keys = { { prefix .. "c", mode = { "n", "v", "x" }, function() require("convy").show_selector() end } },
        opts = { window = { blend = Config.blend, border = Border.borderStyle } },
}
