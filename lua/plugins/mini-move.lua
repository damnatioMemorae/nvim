local function move(mode)
        return function(direction)
                return function() return require "mini.move"["move_" .. mode](direction) end
        end
end

return {
        "nvim-mini/mini.move",
        version = false,
        keys    = {
                { "<M-left>",  move "line" "left" },
                { "<M-down>",  move "line" "down" },
                { "<M-up>",    move "line" "up" },
                { "<M-right>", move "line" "right" },
                { "<M-left>",  move "selection" "left",  mode = "x" },
                { "<M-down>",  move "selection" "down",  mode = "x" },
                { "<M-up>",    move "selection" "up",    mode = "x" },
                { "<M-right>", move "selection" "right", mode = "x" },
        },
        opts    = { options = { reindent_linewise = true } },
}
