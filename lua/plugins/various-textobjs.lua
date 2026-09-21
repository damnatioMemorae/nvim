local fn  = vim.fn
local hl  = vim.hl
local ui  = vim.ui
local api = vim.api
local cmd = vim.cmd
local xo  = { "x", "o" }
local function to(_)
        return function(...)
                local args = { ... }
                return function()
                        return require "various-textobjs"[_](unpack(args))
                end
        end
end

return {
        "chrisgrieser/nvim-various-textobjs",
        enabled = true,
        event   = "BufReadPost",
        keys    = {
                { "<Space>",  to "subword" "inner",                mode = "o", desc = "inner subword" },
                { "i<Space>", to "subword" "outer",                mode = xo,  desc = "outer subword" },
                { "a<Space>", to "subword" "outer",                mode = xo,  desc = "outer subword" },
                -- { "v",        to "value" "inner",                  mode = "o", desc = "inner value" },
                { "iv",       to "value" "inner",                  mode = xo,  desc = "inner value" },
                { "av",       to "value" "outer",                  mode = xo,  desc = "outer value" },
                { "ik",       to "key" "inner",                    mode = xo,  desc = "inner key" },
                { "ak",       to "key" "outer",                    mode = xo,  desc = "outer key" },
                { "n",        to "nearEoL" (),                     mode = xo,  desc = "near EoL" },
                { "iQ",       to "doubleSquareBrackets" "inner",   mode = xo,  desc = "inner doubleSquareBrackets" },
                { "aQ",       to "doubleSquareBrackets" "outer",   mode = xo,  desc = "outer doubleSquareBrackets" },
                { "rp",       to "restOfParagraph" (),             mode = "o", desc = "rest of paragraph" },
                { "ri",       to "restOfIndentation" (),           mode = "o", desc = "rest of indentation" },
                { "rg",       "G",                                 mode = "o", desc = "rest of buffer" },
                { "L",        to "url" (),                         mode = "o", desc = "URL" },
                { "#",        to "cssColor" "outer",               mode = xo,  desc = "outer color" },
                { ".",        to "emoji" (),                       mode = xo,  desc = "outer color" },
                { "ii",       to "indentation" ("inner", "inner"), mode = xo,  desc = "inner indent" },
                { "ai",       to "indentation" ("outer", "outer"), mode = xo,  desc = "outer indent" },
                { "aj",       to "indentation" ("outer", "inner"), mode = xo,  desc = "top-border indent" },
                { "iI",       to "greedyOuterIndentation" "inner", mode = xo,  desc = "inner greedy indent" },
                { "aI",       to "greedyOuterIndentation" "outer", mode = xo,  desc = "outer greedy indent" },
                { "i.",       to "chainMember" "inner",            mode = xo,  desc = "inner chainMember" },
                { "a.",       to "chainMember" "outer",            mode = xo,  desc = "outer chainMember" },
                { "iy",       to "pyTripleQuotes" "inner",         mode = xo,  desc = "inner tripleQuotes",        ft = "python" },
                { "ay",       to "pyTripleQuotes" "outer",         mode = xo,  desc = "outer tripleQuotes",        ft = "python" },
                { "iE",       to "mdFencedCodeBlock" "inner",      mode = xo,  desc = "inner CodeBlock",           ft = "markdown" },
                { "aE",       to "mdFencedCodeBlock" "outer",      mode = xo,  desc = "outer CodeBlock",           ft = "markdown" },
                { "il",       to "mdlink" "inner",                 mode = xo,  desc = "inner md-link",             ft = "markdown" },
                { "al",       to "mdlink" "outer",                 mode = xo,  desc = "outer md-link",             ft = "markdown" },
                { "is",       to "cssSelector" "inner",            mode = xo,  desc = "inner selector",            ft = "css" },
                { "as",       to "cssSelector" "outer",            mode = xo,  desc = "outer selector",            ft = "css" },
                { "i|",       to "shellPipe" "inner",              mode = "o", desc = "inner pipe",                ft = "sh" },
                { "a|",       to "shellPipe" "outer",              mode = "o", desc = "outer pipe",                ft = "sh" },
                { -- DELETE SURROUNDING INDENTATION
                        "dsi",
                        function()
                                to "indentation" ("outer", "outer")()
                                if not fn.mode() == "V" then return end

                                cmd.normal { "<", bang = true }
                                local start_border_ln = api.nvim_buf_get_mark(0, "<")[1]
                                local end_border_ln   = api.nvim_buf_get_mark(0, ">")[1]
                                local before          = api.nvim_win_get_cursor(0)
                                cmd(end_border_ln .. " delete")
                                cmd(start_border_ln .. " delete")
                                vim.defer_fn(function() api.nvim_win_set_cursor(0, before) end, 1)
                        end,
                        desc = "Delete surrounding indent",
                },
                { -- YANK SURROUNDING INNER INDENTATION
                        "ysii",
                        function()
                                local start_pos = api.nvim_win_get_cursor(0)
                                to "indentation" ("outer", "outer")()
                                if not fn.mode() == "V" then return end
                                cmd.normal { "V", bang = true }
                                api.nvim_win_set_cursor(0, start_pos)

                                local start_ln   = api.nvim_buf_get_mark(0, "<")[1] - 1
                                local end_ln     = api.nvim_buf_get_mark(0, ">")[1] - 1
                                local dur        = { timeout = 500 }
                                local bufnr      = api.nvim_get_current_buf()
                                local ns         = api.nvim_create_namespace "ysii"
                                local start_n    = api.nvim_buf_get_mark(0, "<")[1] - 1
                                local end_n      = api.nvim_buf_get_mark(0, ">")[1] - 1
                                local start_line = api.nvim_buf_get_lines(0, start_ln, start_ln + 1, false)[1]
                                local end_line   = api.nvim_buf_get_lines(0, end_ln, end_ln + 1, false)[1]
                                fn.setreg("+", start_line .. "\n" .. end_line .. "\n")
                                hl.range(bufnr, ns, "CurSearch", { start_n, 0 }, { start_n, -1 }, dur)
                                hl.range(bufnr, ns, "CurSearch", { end_n, 0 },   { end_n, -1 },   dur)
                        end,
                        desc = "Delete surrounding indent",
                },
                { -- OPEN URL (FORWARD SEEKING)
                        "<LocalLeader>x",
                        function()
                                vim.keymap.del("n", "gx")

                                to "url" ()

                                if fn.mode():find "v" then
                                        cmd.normal { '"zy', bang = true }
                                        local url = fn.getreg "z"
                                        ui.open(url)
                                else
                                        cmd.normal "gx"
                                end
                        end,
                        desc = "Smart URL Opener",
                },
        },
        opts    = {
                textobjs = {
                        indentation = { blanksAreDelimiter = false },
                        subword     = { noCamelToPascalCase = true },
                        diagnostic  = { wrap = true },
                        url         = { patterns = { [[%l%l%l+://[^%s)%]}"'`>]+]] } },
                },
        },
}
