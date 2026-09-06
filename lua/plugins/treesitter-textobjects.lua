local bo  = vim.bo
local api = vim.api
local cmd = vim.cmd
local log = vim.log

local levels = log.levels

local mode = { "n", "v", "x", "o" }
local to   = require "utils.misc".extraTextobjMaps

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function addDocstring()
        require "nvim-treesitter-textobjects.move".goto_previous_start("@function.outer", "textobjects")
        match(bo.filetype) {
                lua = function()
                        local line       = api.nvim_win_get_cursor(0)[1]
                        -- local line       = vim.pos.cursor(0)[1]
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
        enabled = true,
        branch  = "main",
        event   = "BufReadPost",
        keys    = {
                { "<M-[>",        swap "function" "inner" "previous",    desc = "Swap function" },
                { "<M-]>",        swap "function" "inner" "next",        desc = "Swap function" },
                { "<M-{>",        swap "parameter" "inner" "previous",   desc = "Swap arg" },
                { "<M-}>",        swap "parameter" "inner" "next",       desc = "Swap arg" },
                { "<M-{>",        swap "md_section" "inner" "previous",  desc = "Swap arg",     ft = "markdown" },
                { "<M-}>",        swap "md_section" "inner" "next",      desc = "Swap arg",     ft = "markdown" },

                { "<M-q>",        jump "comment" "outer" "next",         mode = mode,           desc = "Goto next comment" },
                { "<M-Q>",        jump "comment" "outer" "previous",     mode = mode,           desc = "Goto previous comment" },
                { "<M-a>",        jump "parameter" "outer" "next",       mode = mode,           desc = "Goto next parameter" },
                { "<M-A>",        jump "parameter" "outer" "previous",   mode = mode,           desc = "Goto previous parameter" },
                { "<M-f>",        jump "function" "name" "next",         mode = mode,           desc = "Goto next function" },
                { "<M-F>",        jump "function" "name" "previous",     mode = mode,           desc = "Goto next function" },
                { "<M-o>",        jump "conditional" "inner" "next",     mode = mode,           desc = "Goto next condition" },
                { "<M-O>",        jump "conditional" "inner" "previous", mode = mode,           desc = "Goto previous condition" },
                { "<M-c>",        jump "call" "outer" "next",            mode = mode,           desc = "Goto next call" },
                { "<M-C>",        jump "call" "outer" "previous",        mode = mode,           desc = "Goto previous call" },
                { "<M-u>",        jump "loop" "outer" "next",            mode = mode,           desc = "Goto next loop" },
                { "<M-U>",        jump "loop" "outer" "previous",        mode = mode,           desc = "Goto previous loop" },
                { "<M-s>",        jump "assignment" "lhs" "next",        mode = mode,           desc = "Goto next assignment" },
                { "<M-S>",        jump "assignment" "lhs" "previous",    mode = mode,           desc = "Goto previous assignment" },
                { "<M-v>",        jump "assignment" "rhs" "next",        mode = mode,           desc = "Goto next value" },
                { "<M-V>",        jump "assignment" "rhs" "previous",    mode = mode,           desc = "Goto previous value" },
                { "<M-t>",        jump "assignment" "outer" "next",      mode = mode,           desc = "Goto next type" },
                { "<M-T>",        jump "assignment" "outer" "previous",  mode = mode,           desc = "Goto previous type" },

                { "aa",           sel "parameter" "outer",               mode = { "x", "o" },   desc = "outer arg" },
                { "ia",           sel "parameter" "inner",               mode = { "x", "o" },   desc = "inner arg" },
                { "a/",           sel "regex" "outer",                   mode = { "x", "o" },   desc = "outer regex" },
                { "i/",           sel "regex" "inner",                   mode = { "x", "o" },   desc = "inner regex" },
                { "au",           sel "loop" "outer",                    mode = { "x", "o" },   desc = "outer loop" },
                { "iu",           sel "loop" "inner",                    mode = { "x", "o" },   desc = "inner loop" },
                { "aE",           sel "codeblock" "outer",               mode = { "x", "o" },   desc = "outer codeblock" },
                { "iE",           sel "codeblock" "inner",               mode = { "x", "o" },   desc = "inner codeblock" },
                { "a" .. to.call, sel "call" "outer",                    mode = { "x", "o" },   desc = "outer call" },
                { "i" .. to.call, sel "call" "inner",                    mode = { "x", "o" },   desc = "inner call" },
                { "a" .. to.func, sel "function" "outer",                mode = { "x", "o" },   desc = "outer function" },
                { "i" .. to.func, sel "function" "inner",                mode = { "x", "o" },   desc = "inner function" },
                { "a" .. to.cond, sel "conditional" "outer",             mode = { "x", "o" },   desc = "outer condition" },
                { "i" .. to.cond, sel "conditional" "inner",             mode = { "x", "o" },   desc = "inner condition" },

                { "q",            sel "comment" "outer",                 mode = "o",            desc = "single comment" },
                { "qf",           addDocstring,                          desc = "add docstring" },
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
                                -- local cursor_before = vim.pos.cursor(0)
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
        opts    = { move = { set_jumps = true }, select = { lookahead = true, include_surrounding_whitespace = false } },
}
