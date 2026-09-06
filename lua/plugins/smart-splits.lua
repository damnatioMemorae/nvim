local function split(mode)
        return function(dir)
                return function()
                        return require "smart-splits"[mode .. "_" .. dir]()
                end
        end
end

return {
        "mrjones2014/smart-splits.nvim",
        keys = {
                { "<C-k>",     split "move_cursor" "up",    desc = "Jump Up" },
                { "<C-j>",     split "move_cursor" "down",  desc = "Jump Down" },
                { "<C-h>",     split "move_cursor" "left",  desc = "Jump Left" },
                { "<C-l>",     split "move_cursor" "right", desc = "Jump Right" },
                { "<C-up>",    split "resize" "up",         desc = "Resize Up" },
                { "<C-down>",  split "resize" "down",       desc = "Resize Down" },
                { "<C-left>",  split "resize" "left",       desc = "Resize Left" },
                { "<C-right>", split "resize" "right",      desc = "Resize Right" },
        },
}
