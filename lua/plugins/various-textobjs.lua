return { -- pattern-based textobjs
        "chrisgrieser/nvim-various-textobjs",
        keys = {
                { "<Space>", "<cmd>lua require('various-textobjs').subword('inner')<CR>", mode = "o", desc = "󰬞 inner subword" },
                { "a<Space>", "<cmd>lua require('various-textobjs').subword('outer')<CR>", mode = { "o", "x" }, desc = "󰬞 outer subword" },

                { "iv", "<cmd>lua require('various-textobjs').value('inner')<CR>", mode = { "x", "o" }, desc = " inner value" },
                { "v", "<cmd>lua require('various-textobjs').value('inner')<CR>", mode = "o", desc = " inner value" },
                { "av", "<cmd>lua require('various-textobjs').value('outer')<CR>", mode = { "x", "o" }, desc = " outer value" },
                { "ak", "<cmd>lua require('various-textobjs').key('outer')<CR>", mode = { "x", "o" }, desc = "󰌆 outer key" },
                { "ik", "<cmd>lua require('various-textobjs').key('inner')<CR>", mode = { "x", "o" }, desc = "󰌆 inner key" },

                { "n", "<cmd>lua require('various-textobjs').nearEoL()<CR>", mode = "o", desc = "󰑀 near EoL" },
                -- { "m", "<cmd>lua require('various-textobjs').toNextClosingBracket()<CR>", mode = { "o", "x" }, desc = "󰅪 to next anyBracket" },
                -- { "w", "<cmd>lua require('various-textobjs').toNextQuotationMark()<CR>", mode = "o", desc = " to next anyQuote", nowait = true },
                { "b", "<cmd>lua require('various-textobjs').anyBracket('inner')<CR>", mode = "o", desc = "󰅪 inner anyBracket" },
                { "B", "<cmd>lua require('various-textobjs').anyBracket('outer')<CR>", mode = "o", desc = "󰅪 outer anyBracket" },
                { "'", "<cmd>lua require('various-textobjs').anyQuote('inner')<CR>", mode = "o", desc = " inner anyQuote" },
                { '"', "<cmd>lua require('various-textobjs').anyQuote('outer')<CR>", mode = "o", desc = " outer anyQuote" },

                -- INFO not setting in visual mode, to keep visual block mode replace
                { "rp", "<cmd>lua require('various-textobjs').restOfParagraph()<CR>", mode = "o", desc = "¶ rest of paragraph" },
                { "ri", "<cmd>lua require('various-textobjs').restOfIndentation()<CR>", mode = "o", desc = "󰉶 rest of indentation" },
                { "rg", "G", mode = "o", desc = " rest of buffer" },

                { "ge", "<cmd>lua require('various-textobjs').diagnostic()<CR>", mode = { "x", "o" }, desc = " diagnostic" },
                { "L", "<cmd>lua require('various-textobjs').url()<CR>", mode = "o", desc = " URL" },
                { "o", "<cmd>lua require('various-textobjs').column()<CR>", mode = "o", desc = "ﴳ column" },
                { "#", "<cmd>lua require('various-textobjs').cssColor('outer')<CR>", mode = { "x", "o" }, desc = " outer color" },

                { "in", "<cmd>lua require('various-textobjs').number('inner')<CR>", mode = { "x", "o" }, desc = " inner number" },
                { "an", "<cmd>lua require('various-textobjs').number('outer')<CR>", mode = { "x", "o" }, desc = " outer number" },

                { "ii", "<cmd>lua require('various-textobjs').indentation('inner', 'inner')<CR>", mode = { "x", "o" }, desc = "󰉶 inner indent" },
                { "ai", "<cmd>lua require('various-textobjs').indentation('outer', 'outer')<CR>", mode = { "x", "o" }, desc = "󰉶 outer indent" },
                { "aj", "<cmd>lua require('various-textobjs').indentation('outer', 'inner')<CR>", mode = { "x", "o" }, desc = "󰉶 top-border indent" },
                { "ig", "<cmd>lua require('various-textobjs').greedyOuterIndentation('inner')<CR>", mode = { "x", "o" }, desc = "󰉶 inner greedy indent" },
                { "ag", "<cmd>lua require('various-textobjs').greedyOuterIndentation('outer')<CR>", mode = { "x", "o" }, desc = "󰉶 outer greedy indent" },

                { "i.", "<cmd>lua require('various-textobjs').chainMember('inner')<CR>", mode = { "x", "o" }, desc = "󰌷 inner chainMember" },
                { "a.", "<cmd>lua require('various-textobjs').chainMember('outer')<CR>", mode = { "x", "o" }, desc = "󰌷 outer chainMember" },

                -- python
                { "iy", "<cmd>lua require('various-textobjs').pyTripleQuotes('inner')<CR>", ft = "python", mode = { "x", "o" }, desc = " inner tripleQuotes" },
                { "ay", "<cmd>lua require('various-textobjs').pyTripleQuotes('outer')<CR>", ft = "python", mode = { "x", "o" }, desc = " outer tripleQuotes" },

                -- markdown
                { "iE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('inner')<CR>", mode = { "x", "o" }, ft = "markdown", desc = " inner CodeBlock" },
                { "aE", "<cmd>lua require('various-textobjs').mdFencedCodeBlock('outer')<CR>", mode = { "x", "o" }, ft = "markdown", desc = " outer CodeBlock" },
                { "il", "<cmd>lua require('various-textobjs').mdlink('inner')<CR>", mode = { "x", "o" }, ft = "markdown", desc = " inner md-link" },
                { "al", "<cmd>lua require('various-textobjs').mdlink('outer')<CR>", mode = { "x", "o" }, ft = "markdown", desc = " outer md-link" },

                -- css
                { "is", "<cmd>lua require('various-textobjs').cssSelector('inner')<CR>", mode = { "x", "o" }, ft = "css", desc = " inner selector" },
                { "as", "<cmd>lua require('various-textobjs').cssSelector('outer')<CR>", mode = { "x", "o" }, ft = "css", desc = " outer selector" },

                -- shell
                { "i|", "<cmd>lua require('various-textobjs').shellPipe('inner')<CR>", mode = "o", ft = "sh", desc = "󰟥 inner pipe" },
                { "a|", "<cmd>lua require('various-textobjs').shellPipe('outer')<CR>", mode = "o", ft = "sh", desc = "󰟥 outer pipe" },

                { -- delete surrounding indentation
                        "dsi",
                        function()
                                require("various-textobjs").indentation("outer", "outer")
                                local indentationFound = vim.fn.mode():find("V")
                                if not indentationFound then return end

                                vim.cmd.normal{ "<", bang = true } -- dedent indentation
                                local endBorderLn   = vim.api.nvim_buf_get_mark(0, ">")[1]
                                local startBorderLn = vim.api.nvim_buf_get_mark(0, "<")[1]
                                vim.cmd(tostring(endBorderLn) .. " delete") -- delete end first so line index is not shifted
                                vim.cmd(tostring(startBorderLn) .. " delete")
                        end,
                        desc = " Delete surrounding indent",
                },
                { -- open URL (forward seeking)
                        ",x",
                        function()
                                require("various-textobjs").url()
                                local foundURL = vim.fn.mode():find("v")
                                if foundURL then
                                        vim.cmd.normal{ '"zy', bang = true }
                                        local url = vim.fn.getreg("z")
                                        vim.ui.open(url)
                                end
                        end,
                        desc = " Smart URL Opener",
                },
                { -- open URL (first in a file)
                        "<D-U>",
                        function()
                                local urlPattern = require("various-textobjs.charwise-textobjs").urlPattern
                                local urlLine    = vim.iter(vim.api.nvim_buf_get_lines(0, 0, -1, false))
                                           :find(function(line) return line:match(urlPattern) end)
                                if urlLine then
                                        vim.ui.open(urlLine:match(urlPattern))
                                else
                                        vim.notify("No URL found in file.", vim.log.levels.WARN)
                                end
                        end,
                        desc = " Open First URL in File",
                },
        },
}
