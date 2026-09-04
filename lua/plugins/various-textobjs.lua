local fn     = vim.fn
local fs     = vim.fs
local hl     = vim.hl
local ui     = vim.ui
local uv     = vim.uv
local api    = vim.api
local cmd    = vim.cmd
local log    = vim.log
local levels = log.levels

local function obj(_)
        return function(...)
                local args = { ... }
                return function()
                        return require "various-textobjs"[_](unpack(args))
                end
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "chrisgrieser/nvim-various-textobjs",
        enabled = true,
        event   = "BufReadPost",
        keys    = {
                { "<Space>",  obj "subword" "inner",                mode = { "o" },      desc = "inner subword" },
                { "i<Space>", obj "subword" "outer",                mode = { "o", "x" }, desc = "outer subword" },
                { "a<Space>", obj "subword" "outer",                mode = { "o", "x" }, desc = "outer subword" },

                { "v",        obj "value" "inner",                  mode = { "o" },      desc = "inner value" },
                { "iv",       obj "value" "inner",                  mode = { "o", "x" }, desc = "inner value" },
                { "av",       obj "value" "outer",                  mode = { "o", "x" }, desc = "outer value" },
                { "k",        obj "key" "inner",                    mode = { "o" },      desc = "inner key" },
                { "ik",       obj "key" "inner",                    mode = { "o", "x" }, desc = "inner key" },
                { "ak",       obj "key" "outer",                    mode = { "o", "x" }, desc = "outer key" },

                { "n",        obj "nearEoL" (),                     mode = { "o", "x" }, desc = "near EoL" },
                { "iQ",       obj "doubleSquareBrackets" "inner",   mode = { "o", "x" }, desc = "inner doubleSquareBrackets" },
                { "aQ",       obj "doubleSquareBrackets" "outer",   mode = { "o", "x" }, desc = "outer doubleSquareBrackets" },

                { "rp",       obj "restOfParagraph" (),             mode = { "o" },      desc = "rest of paragraph" },
                { "ri",       obj "restOfIndentation" (),           mode = { "o" },      desc = "rest of indentation" },
                { "rg",       "G",                                  mode = { "o" },      desc = "rest of buffer" },

                { "L",        obj "url" (),                         mode = { "o" },      desc = "URL" },
                { "#",        obj "cssColor" "outer",               mode = { "o", "x" }, desc = "outer color" },
                { ".",        obj "emoji" (),                       mode = { "o", "x" }, desc = "outer color" },

                -- { "in",       obj "number" "inner",                                           mode = { "x", "o" }, desc = "inner number" },
                -- { "an",       obj "number" "outer",                                           mode = { "x", "o" }, desc = "outer number" },

                { "ii",       obj "indentation" ("inner", "inner"), mode = { "o", "x" }, desc = "inner indent" },
                { "ai",       obj "indentation" ("outer", "outer"), mode = { "o", "x" }, desc = "outer indent" },
                { "aj",       obj "indentation" ("outer", "inner"), mode = { "o", "x" }, desc = "top-border indent" },
                { "ig",       obj "greedyOuterIndentation" "inner", mode = { "o", "x" }, desc = "inner greedy indent" },
                { "ag",       obj "greedyOuterIndentation" "outer", mode = { "o", "x" }, desc = "outer greedy indent" },

                { "i.",       obj "chainMember" "inner",            mode = { "o", "x" }, desc = "inner chainMember" },
                { "a.",       obj "chainMember" "outer",            mode = { "o", "x" }, desc = "outer chainMember" },

                ---- PYTHON ----------------------------------------------------------------------------------------------------------------------------------------------------------------

                { "iy",       obj "pyTripleQuotes" "inner",         mode = { "o", "x" }, desc = "inner tripleQuotes",        ft = "python" },
                { "ay",       obj "pyTripleQuotes" "outer",         mode = { "o", "x" }, desc = "outer tripleQuotes",        ft = "python" },

                ---- MARKDOWN --------------------------------------------------------------------------------------------------------------------------------------------------------------

                { "iE",       obj "mdFencedCodeBlock" "inner",      mode = { "o", "x" }, desc = "inner CodeBlock",           ft = "markdown" },
                { "aE",       obj "mdFencedCodeBlock" "outer",      mode = { "o", "x" }, desc = "outer CodeBlock",           ft = "markdown" },
                { "il",       obj "mdlink" "inner",                 mode = { "o", "x" }, desc = "inner md-link",             ft = "markdown" },
                { "al",       obj "mdlink" "outer",                 mode = { "o", "x" }, desc = "outer md-link",             ft = "markdown" },

                ---- CSS -------------------------------------------------------------------------------------------------------------------------------------------------------------------

                { "is",       obj "cssSelector" "inner",            mode = { "o", "x" }, desc = "inner selector",            ft = "css" },
                { "as",       obj "cssSelector" "outer",            mode = { "o", "x" }, desc = "outer selector",            ft = "css" },

                ---- SHELL -----------------------------------------------------------------------------------------------------------------------------------------------------------------

                { "i|",       obj "shellPipe" "inner",              mode = "o",          desc = "inner pipe",                ft = "sh" },
                { "a|",       obj "shellPipe" "outer",              mode = "o",          desc = "outer pipe",                ft = "sh" },

                { -- DELETE SURROUNDING INDENTATION
                        "dsi",
                        function()
                                obj "indentation" ("outer", "outer")()
                                if not fn.mode() == "V" then return end

                                cmd.normal { "<", bang = true }
                                where(function(_)
                                        cmd(_.end_border_ln .. " delete")
                                        cmd(_.start_border_ln .. " delete")
                                        vim.defer_fn(function() api.nvim_win_set_cursor(0, _.before) end, 1)
                                end) {
                                            start_border_ln = api.nvim_buf_get_mark(0, "<")[1],
                                            end_border_ln   = api.nvim_buf_get_mark(0, ">")[1],
                                            before          = api.nvim_win_get_cursor(0),
                                            -- before          = vim.pos.cursor(0),
                                    }
                        end,
                        desc = "Delete surrounding indent",
                },
                { -- YANK SURROUNDING INNER INDENTATION
                        "ysii",
                        function()
                                local start_pos = api.nvim_win_get_cursor(0)
                                -- local start_pos = vim.pos.cursor(0)
                                obj "indentation" ("outer", "outer")()
                                if not fn.mode() == "V" then return end
                                cmd.normal { "V", bang = true }
                                api.nvim_win_set_cursor(0, start_pos)

                                local start_ln = api.nvim_buf_get_mark(0, "<")[1] - 1
                                local end_ln   = api.nvim_buf_get_mark(0, ">")[1] - 1
                                where(function(_)
                                        fn.setreg("+", _.start_line .. "\n" .. _.end_line .. "\n")
                                        hl.range(_.bufnr, _.ns, "CurSearch", { _.start_n, 0 }, { _.start_n, -1 }, _.dur)
                                        hl.range(_.bufnr, _.ns, "CurSearch", { _.end_n, 0 },   { _.end_n, -1 },   _.dur)
                                end) {
                                            dur        = { timeout = 500 },
                                            bufnr      = api.nvim_get_current_buf(),
                                            ns         = api.nvim_create_namespace "ysii",
                                            start_n    = api.nvim_buf_get_mark(0, "<")[1] - 1,
                                            end_n      = api.nvim_buf_get_mark(0, ">")[1] - 1,
                                            start_line = api.nvim_buf_get_lines(0, start_ln, start_ln + 1, false)[1],
                                            end_line   = api.nvim_buf_get_lines(0, end_ln, end_ln + 1, false)[1],
                                    }
                        end,
                        desc = "Delete surrounding indent",
                },
                { -- OPEN URL (FORWARD SEEKING)
                        "<LocalLeader>x",
                        function()
                                vim.keymap.del("n", "gx")

                                obj "url" ()()

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
