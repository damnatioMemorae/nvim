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

local function selectNode(obj, pos)
        require "nvim-treesitter-textobjects.select".select_textobject("@" .. obj .. "." .. pos, "textobjects")
end

local function gotoNode(obj, pos, dir)
        require "nvim-treesitter-textobjects.move"["goto_" .. dir .. "_start"]("@" .. obj .. "." .. pos, "textobjects")
        cmd "norm zv"
end

local function swapNode(obj, pos, dir)
        require "nvim-treesitter-textobjects.swap"["swap_" .. dir]("@" .. obj .. "." .. pos)
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "nvim-treesitter/nvim-treesitter-textobjects",
        enabled = true,
        branch  = "main",
        event   = "BufReadPost",
        keys    = {
                { "<M-[>",        function() swapNode("function", "inner", "previous") end,    desc = "Swap function" },
                { "<M-]>",        function() swapNode("function", "inner", "next") end,        desc = "Swap function" },
                { "<M-{>",        function() swapNode("parameter", "inner", "previous") end,   desc = "Swap arg" },
                { "<M-}>",        function() swapNode("parameter", "inner", "next") end,       desc = "Swap arg" },
                { "<M-{>",        function() swapNode("md_section", "inner", "previous") end,  desc = "Swap arg",     ft = "markdown" },
                { "<M-}>",        function() swapNode("md_section", "inner", "next") end,      desc = "Swap arg",     ft = "markdown" },

                { "<M-q>",        function() gotoNode("comment", "outer", "next") end,         mode = mode,           desc = "Goto next comment" },
                { "<M-Q>",        function() gotoNode("comment", "outer", "previous") end,     mode = mode,           desc = "Goto previous comment" },
                { "<M-a>",        function() gotoNode("parameter", "outer", "next") end,       mode = mode,           desc = "Goto next parameter" },
                { "<M-A>",        function() gotoNode("parameter", "outer", "previous") end,   mode = mode,           desc = "Goto previous parameter" },
                { "<M-f>",        function() gotoNode("function", "name", "next") end,         mode = mode,           desc = "Goto next function" },
                { "<M-F>",        function() gotoNode("function", "name", "previous") end,     mode = mode,           desc = "Goto next function" },
                { "<M-o>",        function() gotoNode("conditional", "inner", "next") end,     mode = mode,           desc = "Goto next condition" },
                { "<M-O>",        function() gotoNode("conditional", "inner", "previous") end, mode = mode,           desc = "Goto previous condition" },
                { "<M-c>",        function() gotoNode("call", "outer", "next") end,            mode = mode,           desc = "Goto next call" },
                { "<M-C>",        function() gotoNode("call", "outer", "previous") end,        mode = mode,           desc = "Goto previous call" },
                { "<M-u>",        function() gotoNode("loop", "outer", "next") end,            mode = mode,           desc = "Goto next loop" },
                { "<M-U>",        function() gotoNode("loop", "outer", "previous") end,        mode = mode,           desc = "Goto previous loop" },
                { "<M-s>",        function() gotoNode("assignment", "lhs", "next") end,        mode = mode,           desc = "Goto next assignment" },
                { "<M-S>",        function() gotoNode("assignment", "lhs", "previous") end,    mode = mode,           desc = "Goto previous assignment" },
                { "<M-v>",        function() gotoNode("assignment", "rhs", "next") end,        mode = mode,           desc = "Goto next value" },
                { "<M-V>",        function() gotoNode("assignment", "rhs", "previous") end,    mode = mode,           desc = "Goto previous value" },
                { "<M-t>",        function() gotoNode("assignment", "outer", "next") end,      mode = mode,           desc = "Goto next type" },
                { "<M-T>",        function() gotoNode("assignment", "outer", "previous") end,  mode = mode,           desc = "Goto previous type" },

                { "aa",           function() selectNode("parameter", "outer") end,             mode = { "x", "o" },   desc = "outer arg" },
                { "ia",           function() selectNode("parameter", "inner") end,             mode = { "x", "o" },   desc = "inner arg" },
                { "a/",           function() selectNode("regex", "outer") end,                 mode = { "x", "o" },   desc = "outer regex" },
                { "i/",           function() selectNode("regex", "inner") end,                 mode = { "x", "o" },   desc = "inner regex" },
                { "au",           function() selectNode("loop", "outer") end,                  mode = { "x", "o" },   desc = "outer loop" },
                { "iu",           function() selectNode("loop", "inner") end,                  mode = { "x", "o" },   desc = "inner loop" },
                { "aE",           function() selectNode("codeblock", "outer") end,             mode = { "x", "o" },   desc = "outer codeblock" },
                { "iE",           function() selectNode("codeblock", "inner") end,             mode = { "x", "o" },   desc = "inner codeblock" },
                { "a" .. to.call, function() selectNode("call", "outer") end,                  mode = { "x", "o" },   desc = "outer call" },
                { "i" .. to.call, function() selectNode("call", "inner") end,                  mode = { "x", "o" },   desc = "inner call" },
                { "a" .. to.func, function() selectNode("function", "outer") end,              mode = { "x", "o" },   desc = "outer function" },
                { "i" .. to.func, function() selectNode("function", "inner") end,              mode = { "x", "o" },   desc = "inner function" },
                { "a" .. to.cond, function() selectNode("conditional", "outer") end,           mode = { "x", "o" },   desc = "outer condition" },
                { "i" .. to.cond, function() selectNode("conditional", "inner") end,           mode = { "x", "o" },   desc = "inner condition" },

                { "q",            function() selectNode("comment", "outer") end,               mode = "o",            desc = "single comment" },
                { "qf",           addDocstring,                                                desc = "add docstring" },
                { -- CHANGE SINGLE COMMENT
                        "cq",
                        function()
                                -- local select_obj = require("nvim-treesitter-textobjects.select").select_textobject
                                -- select_obj("@comment.inner", "textobjects")
                                selectNode("comment", "inner")
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
