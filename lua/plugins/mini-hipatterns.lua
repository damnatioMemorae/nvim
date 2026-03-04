local words = {
        ["ivory"]            = "#dce0e8",
        ["spark"]            = "#add8e6",
        ["C.ivory"]          = "#dce0e8",
        ["C.spark"]          = "#add8e6",
        ["C.rosewater"]      = "#f5e0dc",
        ["C.flamingo"]       = "#f2cdcd",
        ["C.pink"]           = "#f5c2e7",
        ["C.mauve"]          = "#cba6f7",
        ["C.red"]            = "#f38ba8",
        ["C.maroon"]         = "#eba0ac",
        ["C.peach"]          = "#fab387",
        ["C.yellow"]         = "#f9e2af",
        ["C.green"]          = "#a6e3a1",
        ["C.teal"]           = "#94e2d5",
        ["C.sky"]            = "#89dceb",
        ["C.sapphire"]       = "#74c7ec",
        ["C.blue"]           = "#89b4fa",
        ["C.lavender"]       = "#b4befe",
        ["C.text"]           = "#cdd6f4",
        ["C.subtext1"]       = "#bac2de",
        ["C.subtext0"]       = "#a6adc8",
        ["C.overlay2"]       = "#9399b2",
        ["C.overlay1"]       = "#7f849c",
        ["C.overlay0"]       = "#6c7086",
        ["C.surface2"]       = "#585b70",
        ["C.surface1"]       = "#45475a",
        ["C.surface0"]       = "#313244",
        ["C.base"]           = "#1e1e2e",
        ["C.mantle"]         = "#14141f",
        ["C.crust"]          = "#0e0e16",
        ["colors.ivory"]     = "#dce0e8",
        ["colors.spark"]     = "#add8e6",
        ["colors.rosewater"] = "#f5e0dc",
        ["colors.flamingo"]  = "#f2cdcd",
        ["colors.pink"]      = "#f5c2e7",
        ["colors.mauve"]     = "#cba6f7",
        ["colors.red"]       = "#f38ba8",
        ["colors.maroon"]    = "#eba0ac",
        ["colors.peach"]     = "#fab387",
        ["colors.yellow"]    = "#f9e2af",
        ["colors.green"]     = "#a6e3a1",
        ["colors.teal"]      = "#94e2d5",
        ["colors.sky"]       = "#89dceb",
        ["colors.sapphire"]  = "#74c7ec",
        ["colors.blue"]      = "#89b4fa",
        ["colors.lavender"]  = "#b4befe",
        ["colors.text"]      = "#cdd6f4",
        ["colors.subtext1"]  = "#bac2de",
        ["colors.subtext0"]  = "#a6adc8",
        ["colors.overlay2"]  = "#9399b2",
        ["colors.overlay1"]  = "#7f849c",
        ["colors.overlay0"]  = "#6c7086",
        ["colors.surface2"]  = "#585b70",
        ["colors.surface1"]  = "#45475a",
        ["colors.surface0"]  = "#313244",
        ["colors.base"]      = "#1e1e2e",
        ["colors.mantle"]    = "#14141f",
        ["colors.crust"]     = "#0e0e16",
}

return {
        "echasnovski/mini.hipatterns",
        version = false,
        event   = "VeryLazy",
        config  = function()
                local hipatterns = require("mini.hipatterns")

                local word_color_group = function(_, match)
                        local hex = words[match]
                        if hex == nil then return nil end
                        return hipatterns.compute_hex_color_group(hex, "bg")
                end

                local hsl_to_hex = function(h, s, l)
                        -- Actually convert h, s, l numbers into hex color in '#RRGGBB' format
                        return "#111111"
                end

                local hsl_color = function(_, match)
                        local h, s, l   = match:match("hsl%((%d+) (%d+)%% (%d+)%%%)")
                        h, s, l         = tonumber(h), tonumber(s), tonumber(l)
                        local hex_color = hsl_to_hex(h, s, l)
                        return hipatterns.compute_hex_color_group(hex_color, "bg")
                end

                hipatterns.setup({
                        highlighters = {
                                hex_color  = hipatterns.gen_highlighter.hex_color(),
                                word_color = { pattern = "%f[%w]()%S+()%f[%W]", group = word_color_group },
                                hsl_color  = {
                                        pattern = "hsl%(%d+,? %d+,? %d+%)",
                                        -- group  = hsl_color()
                                        group   = function(_, match)
                                                local utils     = require("core.utils")
                                                local h, s, l   = match:match("hsl%((%d+),? (%d+),? (%d+)%)")
                                                h, s, l         = tonumber(h), tonumber(s), tonumber(l)
                                                local hex_color = utils.hslToHex(h, s, l)
                                                return hipatterns.compute_hex_color_group(hex_color, "bg")
                                        end,
                                },
                        },
                })
        end,
}
