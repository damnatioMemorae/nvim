return {
        "monkoose/neocodeium",
        event  = "InsertEnter",
        cmd    = "NeoCodeium",
        keys   = {
                { "<leader>oa", function() vim.cmd.NeoCodeium("toggle") end, desc = "󰚩 NeoCodeium" },
                { "<A-s>", function() require("neocodeium").accept() end, mode = "i", desc = "󰚩 Accept full suggestion" },
                { "<A-S>", function() require("neocodeium").accept_word() end, mode = "i", desc = "󰚩 Accept word" },
                { "<A-a>", function() require("neocodeium").cycle_or_complete(1) end, mode = "i", desc = "󰚩 Next suggestion" },
                { "<A-A>", function() require("neocodeium").cycle_or_complete(-1) end, mode = "i", desc = "󰚩 Prev suggestion" },
        },
        opts   = {
                silent     = true,
                show_label = true,
                filetypes  = { bib = false, text = false },
                filter     = require("core.utils").allowBufferForAi,
        },
        config = function(_, opts)
                local codeium = require("neocodeium")
                codeium.setup(opts)

                _G.lualineAdd(
                        "sections",
                        "lualine_x",
                        function()
                                local status, server = codeium.get_status()
                                if status == 0 and server == 0 then return "" end
                                if server == 1 then return "connecting…" end
                                if server == 2 then return "server" end
                                if status == 1 then return "global" end
                                if status == 2 or status == 3 or status == 4 then return "buffer" end
                                if status == 5 then return "encoding" end
                                if status == 6 then return "buftype" end
                                return "Unknown error"
                        end,
                        "before"
                )
        end,
}
