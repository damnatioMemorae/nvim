local bo     = vim.bo
local api    = vim.api
local cmd    = vim.cmd
local levels = vim.log.levels

local xo  = { "x", "o" }
local nxo = { "n", "x", "o" }
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function addDocstring()
        require "nvim-treesitter-textobjects.move".goto_previous_start("@function.outer", "textobjects")
        match(bo.filetype) {
                lua = function()
                        local line       = api.nvim_win_get_cursor(0)[1]
                        local indent     = api.nvim_get_current_line():match "^%s*"
                        local param_line = api.nvim_get_current_line():match "function.*%((.*)%)$"
                        if nilq(param_line) then return end
                        local params       = vim.split(param_line, ", ?")
                        local luadoc_lines = vim
                            .iter(params)
                            :map(function(param)
                                    return ("%s---@param %s "):format(indent, param)
                            end)
                            :totable()
                        api.nvim_buf_set_lines(0, line - 1, line - 1, false, luadoc_lines)
                        api.nvim_win_set_cursor(0, { line, #luadoc_lines[1] })
                        cmd.normal { '"_ciw', bang = true }
                        cmd.startinsert { bang = true }
                end,
                _   = function()
                        vim.notify(bo.filetype .. " is not supported.", levels.WARN, { title = "docstring" })
                end,
        }
end

local tst = "nvim-treesitter-textobjects."

local function swap(obj)
        return function(pos)
                return function(dir)
                        return function()
                                return require(tst .. "swap")["swap_" .. dir]("@" .. obj .. "." .. pos)
                        end
                end
        end
end

local function jump(obj)
        return function(pos)
                return function(dir)
                        return function()
                                require(tst .. "move")["goto_" .. dir .. "_start"]("@" .. obj .. "." .. pos,
                                                                                   "textobjects")
                                cmd "norm zv"
                        end
                end
        end
end

local function sel(obj)
        return function(pos)
                return function()
                        return require(tst .. "select").select_textobject("@" .. obj .. "." .. pos, "textobjects")
                end
        end
end

return {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        event  = "BufReadPost",
        keys   = {
                { "<M-[>", swap "function" "inner" "previous",    desc = "Swap function" },
                { "<M-]>", swap "function" "inner" "next",        desc = "Swap function" },
                { "<M-{>", swap "parameter" "inner" "previous",   desc = "Swap arg" },
                { "<M-}>", swap "parameter" "inner" "next",       desc = "Swap arg" },
                { "<M-{>", swap "md_section" "inner" "previous",  desc = "Swap markdown section",    ft = "markdown" },
                { "<M-}>", swap "md_section" "inner" "next",      desc = "Swap markdown section",    ft = "markdown" },

                { "<M-q>", jump "comment" "outer" "next",         desc = "Goto next comment",        mode = nxo },
                { "<M-Q>", jump "comment" "outer" "previous",     desc = "Goto previous comment",    mode = nxo },
                { "<M-a>", jump "parameter" "outer" "next",       desc = "Goto next parameter",      mode = nxo },
                { "<M-A>", jump "parameter" "outer" "previous",   desc = "Goto previous parameter",  mode = nxo },
                { "<M-f>", jump "function" "name" "next",         desc = "Goto next function",       mode = nxo },
                { "<M-F>", jump "function" "name" "previous",     desc = "Goto next function",       mode = nxo },
                { "<M-o>", jump "conditional" "inner" "next",     desc = "Goto next condition",      mode = nxo },
                { "<M-O>", jump "conditional" "inner" "previous", desc = "Goto previous condition",  mode = nxo },
                { "<M-c>", jump "call" "outer" "next",            desc = "Goto next call",           mode = nxo },
                { "<M-C>", jump "call" "outer" "previous",        desc = "Goto previous call",       mode = nxo },
                -- { "<M-u>", jump "loop" "outer" "next",            desc = "Goto next loop",           mode = nxo },
                -- { "<M-U>", jump "loop" "outer" "previous",        desc = "Goto previous loop",       mode = nxo },
                { "<M-s>", jump "assignment" "lhs" "next",        desc = "Goto next assignment",     mode = nxo },
                { "<M-S>", jump "assignment" "lhs" "previous",    desc = "Goto previous assignment", mode = nxo },
                { "<M-v>", jump "assignment" "rhs" "next",        desc = "Goto next value",          mode = nxo },
                { "<M-V>", jump "assignment" "rhs" "previous",    desc = "Goto previous value",      mode = nxo },
                { "<M-t>", jump "assignment" "outer" "next",      desc = "Goto next type",           mode = nxo },
                { "<M-T>", jump "assignment" "outer" "previous",  desc = "Goto previous type",       mode = nxo },

                { "a/",    sel "regex" "outer",                   desc = "outer regex",              mode = xo },
                { "i/",    sel "regex" "inner",                   desc = "inner regex",              mode = xo },
                { "aE",    sel "codeblock" "outer",               desc = "outer codeblock",          mode = xo },
                { "iE",    sel "codeblock" "inner",               desc = "inner codeblock",          mode = xo },
                { "aa",    sel "parameter" "outer",               desc = "outer arg",                mode = xo },
                { "ia",    sel "parameter" "inner",               desc = "inner arg",                mode = xo },
                { "af",    sel "function" "outer",                desc = "outer function",           mode = xo },
                { "if",    sel "function" "inner",                desc = "inner function",           mode = xo },
                { "aF",    sel "call" "outer",                    desc = "outer call",               mode = xo },
                { "iF",    sel "call" "inner",                    desc = "inner call",               mode = xo },
                { "ao",    sel "conditional" "outer",             desc = "outer condition",          mode = xo },
                { "io",    sel "conditional" "inner",             desc = "inner condition",          mode = xo },
                { "aO",    sel "loop" "outer",                    desc = "outer loop",               mode = xo },
                { "iO",    sel "loop" "inner",                    desc = "inner loop",               mode = xo },
                { "qf",    addDocstring,                          desc = "add docstring" },
                { -- CHANGE SINGLE COMMENT
                        "cq",
                        function()
                                -- local select_obj = require("nvim-treesitter-textobjects.select").select_textobject
                                -- select_obj("@comment.inner", "textobjects")
                                sel "comment" "inner"
                                local com_str = bo.commentstring:format ""
                                cmd.normal { "c" .. com_str, bang = true }
                                cmd.startinsert { bang = true }
                        end,
                        desc = "Change single comment",
                },
                { -- STICKY DELETE COMMENT
                        "dq",
                        function()
                                local cursor_before = api.nvim_win_get_cursor(0)
                                local select_obj = require "nvim-treesitter-textobjects.select".select_textobject
                                select_obj("@comment.outer", "textobjects")
                                cmd.normal { "d", bang = true }
                                local trimmed_line = api.nvim_get_current_line():gsub("%s+$", "")
                                api.nvim_set_current_line(trimmed_line)
                                api.nvim_win_set_cursor(0, cursor_before)
                        end,
                        desc = "Sticky delete single comment",
                },
        },
        opts   = { move = { set_jumps = true }, select = { lookahead = true, include_surrounding_whitespace = false } },
}
