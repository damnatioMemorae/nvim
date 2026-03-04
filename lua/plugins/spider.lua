local modes = { "n", "v", "x", "o" }

return {
        "chrisgrieser/nvim-spider",
        keys = {
                { -- e
                        "e",
                        function() require("spider").motion("e") end,
                        mode = modes,
                        desc = "󱇫 end of subword",
                },
                { -- w
                        "w",
                        function() require("spider").motion("w") end,
                        mode = modes,
                        desc = "󱇫 end of subword",
                },
                { -- b
                        "b",
                        function() require("spider").motion("b") end,
                        mode = { "n", "v", "x" },
                        desc = "󱇫 beginning of subword",
                },
                { -- W
                        "W",
                        function() require("spider").motion("ge") end,
                        mode = modes,
                        desc = "󱇫 beginning of subword",
                },
        },
        opts = {
                skipInsignificantPunctuation = false,
                subwordMovement              = true,
                consistentOperatorPending    = false,
                customPattern                = { "%d+" },
        },
}
