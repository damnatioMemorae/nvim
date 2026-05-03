return {
        "chrisgrieser/nvim-various-textobjs",
        event = "BufReadPre",
        keys  = {
                { "<Space>", function() require("various-textobjs").subword("inner") end, mode = "o", desc = "󰬞 inner subword" },
                { "a<Space>", function() require("various-textobjs").subword("outer") end, mode = { "o", "x" }, desc = "󰬞 outer subword" },

                { "iv", function() require("various-textobjs").value("inner") end, mode = { "x", "o" }, desc = " inner value" },
                { "v", function() require("various-textobjs").value("inner") end, mode = "o", desc = " inner value" },
                { "av", function() require("various-textobjs").value("outer") end, mode = { "x", "o" }, desc = " outer value" },
                { "ak", function() require("various-textobjs").key("outer") end, mode = { "x", "o" }, desc = "󰌆 outer key" },
                { "ik", function() require("various-textobjs").key("inner") end, mode = { "x", "o" }, desc = "󰌆 inner key" },

                { "n", function() require("various-textobjs").nearEoL() end, mode = "o", desc = "󰑀 near EoL" },
                -- { "m", function()  require('various-textobjs').toNextClosingBracket()end, mode = { "o", "x" }, desc = "󰅪 to next anyBracket" },
                -- { "w", function()  require('various-textobjs').toNextQuotationMark()end, mode = "o", desc = " to next anyQuote", nowait = true },
                { "b", function() require("various-textobjs").anyBracket("inner") end, mode = "o", desc = "󰅪 inner anyBracket" },
                { "B", function() require("various-textobjs").anyBracket("outer") end, mode = "o", desc = "󰅪 outer anyBracket" },
                { "'", function() require("various-textobjs").anyQuote("inner") end, mode = "o", desc = " inner anyQuote" },
                { '"', function() require("various-textobjs").anyQuote("outer") end, mode = "o", desc = " outer anyQuote" },

                { "rp", function() require("various-textobjs").restOfParagraph() end, mode = "o", desc = "¶ rest of paragraph" },
                { "ri", function() require("various-textobjs").restOfIndentation() end, mode = "o", desc = "󰉶 rest of indentation" },
                { "rg", "G", mode = "o", desc = " rest of buffer" },

                { "ge", function() require("various-textobjs").diagnostic() end, mode = { "x", "o" }, desc = " diagnostic" },
                { "L", function() require("various-textobjs").url() end, mode = "o", desc = " URL" },
                { "o", function() require("various-textobjs").column() end, mode = "o", desc = "ﴳ column" },
                { "#", function() require("various-textobjs").cssColor("outer") end, mode = { "x", "o" }, desc = " outer color" },

                -- { "in", function() require("various-textobjs").number("inner") end, mode = { "x", "o" }, desc = " inner number" },
                -- { "an", function() require("various-textobjs").number("outer") end, mode = { "x", "o" }, desc = " outer number" },

                { "ii", function() require("various-textobjs").indentation("inner", "inner") end, mode = { "x", "o" }, desc = "󰉶 inner indent" },
                { "ai", function() require("various-textobjs").indentation("outer", "outer") end, mode = { "x", "o" }, desc = "󰉶 outer indent" },
                { "aj", function() require("various-textobjs").indentation("outer", "inner") end, mode = { "x", "o" }, desc = "󰉶 top-border indent" },
                { "ig", function() require("various-textobjs").greedyOuterIndentation("inner") end, mode = { "x", "o" }, desc = "󰉶 inner greedy indent" },
                { "ag", function() require("various-textobjs").greedyOuterIndentation("outer") end, mode = { "x", "o" }, desc = "󰉶 outer greedy indent" },

                { "i.", function() require("various-textobjs").chainMember("inner") end, mode = { "x", "o" }, desc = "󰌷 inner chainMember" },
                { "a.", function() require("various-textobjs").chainMember("outer") end, mode = { "x", "o" }, desc = "󰌷 outer chainMember" },

                -- python
                { "iy", function() require("various-textobjs").pyTripleQuotes("inner") end, ft = "python", mode = { "x", "o" }, desc = " inner tripleQuotes" },
                { "ay", function() require("various-textobjs").pyTripleQuotes("outer") end, ft = "python", mode = { "x", "o" }, desc = " outer tripleQuotes" },

                -- markdown
                { "iE", function() require("various-textobjs").mdFencedCodeBlock("inner") end, mode = { "x", "o" }, ft = "markdown", desc = " inner CodeBlock" },
                { "aE", function() require("various-textobjs").mdFencedCodeBlock("outer") end, mode = { "x", "o" }, ft = "markdown", desc = " outer CodeBlock" },
                -- { "il", function() require("various-textobjs").mdlink("inner") end, mode = { "x", "o" }, ft = "markdown", desc = " inner md-link" },
                -- { "al", function() require("various-textobjs").mdlink("outer") end, mode = { "x", "o" }, ft = "markdown", desc = " outer md-link" },

                -- css
                { "is", function() require("various-textobjs").cssSelector("inner") end, mode = { "x", "o" }, ft = "css", desc = " inner selector" },
                { "as", function() require("various-textobjs").cssSelector("outer") end, mode = { "x", "o" }, ft = "css", desc = " outer selector" },

                -- shell
                { "i|", function() require("various-textobjs").shellPipe("inner") end, mode = "o", ft = "sh", desc = "󰟥 inner pipe" },
                { "a|", function() require("various-textobjs").shellPipe("outer") end, mode = "o", ft = "sh", desc = "󰟥 outer pipe" },

                -- { "in", function() require("vim.treesitter._select").select_prev(vim.v.count1) end, mode = "x", desc = "select previous node" },
                -- { "an", function() require("vim.treesitter._select").select_next(vim.v.count1) end, mode = "x", desc = "select next node" },

                { -- delete surrounding indentation
                        "dsi",
                        function()
                                require("various-textobjs").indentation("outer", "outer")

                                if not vim.fn.mode():find("V") then
                                        return
                                end

                                vim.cmd.normal{ "<", bang = true } -- dedent indentation

                                vim.cmd(tostring(vim.api.nvim_buf_get_mark(0, ">")[1]) .. " delete")
                                vim.cmd(tostring(vim.api.nvim_buf_get_mark(0, "<")[1]) .. " delete")
                        end,
                        desc = " Delete surrounding indent",
                },
                { -- open URL (forward seeking)
                        "<LocalLeader>x",
                        function()
                                vim.keymap.del("n", "gx")

                                require("various-textobjs").url()

                                if vim.fn.mode():find("v") then
                                        vim.cmd.normal({ '"zy', bang = true })
                                        local url = vim.fn.getreg("z")
                                        vim.ui.open(url)
                                else
                                        vim.cmd.normal("gx")
                                end
                        end,
                        desc = " Smart URL Opener",
                },
                --[[ open URL (first in a file)
                {
                        "<A-u>",
                        function()
                                local url_pattern = require("various-textobjs.charwise-textobjs").urlPattern
                                local url_line    = vim.iter(vim.api.nvim_buf_get_lines(0, 0, -1, false))
                                           :find(function(line) return line:match(url_pattern) end)
                                if url_line then
                                        vim.ui.open(url_line:match(url_pattern))
                                else
                                        vim.notify("No URL found in file.", vim.log.levels.WARN)
                                end
                        end,
                        desc = " Open First URL in File",
                },
                --]]
        },
}
