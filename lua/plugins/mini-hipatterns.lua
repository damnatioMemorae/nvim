local words = {
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
        ["colors.crust1"]    = "#11111b",
        ["colors.crust"]     = "#0e0e16",
}

return {
        "mini-nvim/mini.hipatterns",
        version = false,
        event   = "VeryLazy",
        config  = function()
                local hipatterns = require("mini.hipatterns")

                local function wordColorGroup(_, match)
                        local hex = words[match]
                        if hex == nil then return nil end
                        return hipatterns.compute_hex_color_group(hex, "bg")
                end

                local function hslToHex(h, s, l)
                        -- Actually convert h, s, l numbers into hex color in '#RRGGBB' format
                        return "#111111"
                end

                local function hslColor(_, match)
                        local h, s, l   = match:match("hsl%((%d+) (%d+)%% (%d+)%%%)")
                        h, s, l         = tonumber(h), tonumber(s), tonumber(l)
                        local hex_color = hslToHex(h, s, l)
                        return hipatterns.compute_hex_color_group(hex_color, "bg")
                end

                hipatterns.setup({
                        highlighters = {
                                hex_color  = hipatterns.gen_highlighter.hex_color(),
                                word_color = { pattern = "%f[%w]()%S+()%f[%W]", group = wordColorGroup },
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

                local groups = {
                        { "Note",  "@comment.note" },
                        { "Todo",  "@comment.todo" },
                        { "Hack",  "@comment.hack" },
                        { "Fixme", "@comment.error" },
                }
                require("core.utils").linkHl(groups, "MiniHipatterns")
        end,
}
