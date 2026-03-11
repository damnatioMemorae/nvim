local function cmd()
        vim.cmd.normal("^zz")
end

return {
        "mrjones2014/smart-splits.nvim",
        keys  = {
                { -- MOVE LEFT
                        "<C-h>",
                        function()
                                require("smart-splits").move_cursor_left()
                                cmd()
                        end,
                        desc = "Jump Left",
                },
                { -- MOVE DOWN
                        "<C-j>",
                        function()
                                require("smart-splits").move_cursor_down()
                                cmd()
                        end,
                        desc = "Jump Down",
                },
                { -- MOVE UP
                        "<C-k>",
                        function()
                                require("smart-splits").move_cursor_up()
                                cmd()
                        end,
                        desc = "Jump Up",
                },
                { -- MOVE RIGHT
                        "<C-l>",
                        function()
                                require("smart-splits").move_cursor_right()
                                cmd()
                        end,
                        desc = "Jump Right",
                },
                { -- MOVE PREVIOUS
                        "<C-S-o>",
                        function()
                                require("smart-splits").move_cursor_previous()
                                cmd()
                        end,
                        desc = "Jump Previous",
                },
                { -- RESIZE LEFT
                        "<C-left>",
                        function()
                                require("smart-splits").resize_left()
                        end,
                        desc = "Resize Left",
                },
                { -- RESIZE DOWN
                        "<C-down>",
                        function()
                                require("smart-splits").resize_down()
                        end,
                        desc = "Resize Down",
                },
                { -- RESIZE UP
                        "<C-up>",
                        function()
                                require("smart-splits").resize_up()
                        end,
                        desc = "Resize Up",
                },
                { -- RESIZE RIGHT
                        "<C-right>",
                        function()
                                require("smart-splits").resize_right()
                        end,
                        desc = "Resize Right",
                },
        },
}
