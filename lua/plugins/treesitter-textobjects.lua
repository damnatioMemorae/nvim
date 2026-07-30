local bo  = vim.bo
local api = vim.api
local cmd = vim.cmd
local log = vim.log

local levels = log.levels

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local icon     = Icon.Kinds
local mode     = { "n", "v", "x", "o" }
local text_obj = require("core.utils.misc").extraTextobjMaps

local function selectNode(obj, pos)
        local textobject = "@" .. obj .. "." .. pos
        return function()
                require("nvim-treesitter-textobjects.select").select_textobject(textobject, "textobjects")
        end
end

local function addDocstring()
        require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")

        local ft     = bo.filetype
        local indent = api.nvim_get_current_line():match("^%s*")
        local ln     = api.nvim_win_get_cursor(0)[1]

        if ft == "lua" then
                local param_line = api.nvim_get_current_line():match("function.*%((.*)%)$")
                if not param_line then
                        return
                end

                local params       = vim.split(param_line, ", ?")
                local luadoc_lines = vim
                           .iter(params)
                           :map(function(param)
                                   return ("%s---@param %s "):format(indent, param)
                           end)
                           :totable()
                api.nvim_buf_set_lines(0, ln - 1, ln - 1, false, luadoc_lines)
                api.nvim_win_set_cursor(0, { ln, #luadoc_lines[1] })
                cmd.normal { '"_ciw', bang = true }
                cmd.startinsert { bang = true }
        else
                vim.notify(ft .. " is not supported.", levels.WARN, { title = "docstring" })
        end
end

local function gotoNode(obj, pos, dir)
        local textobject = "@" .. obj .. "." .. pos
        if dir == "prev" then
                require("nvim-treesitter-textobjects.move").goto_previous_start(textobject, "textobjects")
        elseif dir == "next" then
                require("nvim-treesitter-textobjects.move").goto_next_start(textobject, "textobjects")
        end
end

local function swapNode(obj, pos, dir)
        local textobject = "@" .. obj .. "." .. pos
        if dir == "prev" then
                require("nvim-treesitter-textobjects.swap").swap_previous(textobject)
        elseif dir == "next" then
                require("nvim-treesitter-textobjects.swap").swap_next(textobject)
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch = "main",
        event  = "BufReadPost",
        keys   = {
                ---- COMMENTS --------------------------------------------------------------------------------------------------------------------------------------------------------------

                { "q",  selectNode("comment", "outer"), mode = "o",            desc = "single comment" },
                { "qf", addDocstring,                   desc = "add docstring" },
                {
                        "cq",
                        function()
                                -- local select_obj = require("nvim-treesitter-textobjects.select").select_textobject
                                -- select_obj("@comment.inner", "textobjects")
                                selectNode("comment", "inner")
                                local com_str = bo.commentstring:format("")
                                cmd.normal { "c" .. com_str, bang = true }
                                cmd.startinsert { bang = true }
                        end,
                        desc = "Change single comment",
                }, -- CHANGE SINGLE COMMENT
                {
                        "dq",
                        function()
                                local cursor_before = api.nvim_win_get_cursor(0)
                                local select_obj = require("nvim-treesitter-textobjects.select").select_textobject
                                select_obj("@comment.outer", "textobjects")
                                cmd.normal { "d", bang = true }
                                local trimmed_line = api.nvim_get_current_line():gsub("%s+$", "")
                                api.nvim_set_current_line(trimmed_line)
                                api.nvim_win_set_cursor(0, cursor_before)
                        end,
                        desc = "Sticky delete single comment",
                }, -- STICKY DELETE COMMENT

                ---- MOVE ------------------------------------------------------------------------------------------------------------------------------------------------------------------

                { "<M-q>",                   function() gotoNode("comment", "outer", "next") end,     mode = mode,                         desc = "Goto next comment" },
                { "<M-Q>",                   function() gotoNode("comment", "outer", "prev") end,     mode = mode,                         desc = "Goto prev comment" },
                { "<M-f>",                   function() gotoNode("function", "name", "next") end,     mode = mode,                         desc = icon.Function .. "Goto next function" },
                { "<M-F>",                   function() gotoNode("function", "name", "prev") end,     mode = mode,                         desc = icon.Function .. "Goto next function" },
                { "<M-a>",                   function() gotoNode("parameter", "outer", "next") end,   mode = mode,                         desc = icon.Parameter .. "Goto next parameter" },
                { "<M-A>",                   function() gotoNode("parameter", "outer", "prev") end,   mode = mode,                         desc = icon.Parameter .. "Goto prev parameter" },
                { "<M-o>",                   function() gotoNode("conditional", "inner", "next") end, mode = mode,                         desc = icon.IfStatement .. "Goto next condition" },
                { "<M-O>",                   function() gotoNode("conditional", "inner", "prev") end, mode = mode,                         desc = icon.IfStatement .. "Goto prev condition" },
                { "<M-c>",                   function() gotoNode("call", "outer", "next") end,        mode = mode,                         desc = icon.Call .. "Goto next call" },
                { "<M-C>",                   function() gotoNode("call", "outer", "prev") end,        mode = mode,                         desc = icon.Call .. "Goto prev call" },
                { "<M-u>",                   function() gotoNode("loop", "outer", "next") end,        mode = mode,                         desc = icon.Repeat .. "Goto next loop" },
                { "<M-U>",                   function() gotoNode("loop", "outer", "prev") end,        mode = mode,                         desc = icon.Repeat .. "Goto prev loop" },
                { "<M-s>",                   function() gotoNode("assignment", "lhs", "next") end,    mode = mode,                         desc = icon.Variable .. "Goto next assignment" },
                { "<M-S>",                   function() gotoNode("assignment", "lhs", "prev") end,    mode = mode,                         desc = icon.Variable .. "Goto prev assignment" },
                { "<M-v>",                   function() gotoNode("assignment", "rhs", "next") end,    mode = mode,                         desc = icon.Value .. "Goto next value" },
                { "<M-V>",                   function() gotoNode("assignment", "rhs", "prev") end,    mode = mode,                         desc = icon.Value .. "Goto prev value" },
                { "<M-t>",                   function() gotoNode("assignment", "outer", "next") end,  mode = mode,                         desc = icon.Type .. "Goto next type" },
                { "<M-T>",                   function() gotoNode("assignment", "outer", "prev") end,  mode = mode,                         desc = icon.Type .. "Goto prev type" },

                ---- SWAP ------------------------------------------------------------------------------------------------------------------------------------------------------------------

                { "<M-}>",                   function() swapNode("parameter", "inner", "next") end,   desc = icon.Parameter .. "Swap arg" },
                { "<M-{>",                   function() swapNode("parameter", "inner", "prev") end,   desc = icon.Parameter .. "Swap arg" },

                { "<M-}>",                   function() swapNode("md_section", "inner", "next") end,  desc = icon.Parameter .. "Swap arg", ft = "markdown" },
                { "<M-{>",                   function() swapNode("md_section", "inner", "prev") end,  desc = icon.Parameter .. "Swap arg", ft = "markdown" },

                ---- TEXT OBJECTS ----------------------------------------------------------------------------------------------------------------------------------------------------------

                { "a/",                      selectNode("regex", "outer"),                            mode = { "x", "o" },                 desc = icon.Regex .. "outer regex" },
                { "i/",                      selectNode("regex", "inner"),                            mode = { "x", "o" },                 desc = icon.Regex .. "inner regex" },
                { "aa",                      selectNode("parameter", "outer"),                        mode = { "x", "o" },                 desc = icon.Parameter .. "outer arg" },
                { "ia",                      selectNode("parameter", "inner"),                        mode = { "x", "o" },                 desc = icon.Parameter .. "inner arg" },
                { "au",                      selectNode("loop", "outer"),                             mode = { "x", "o" },                 desc = icon.Repeat .. "outer loop" },
                { "iu",                      selectNode("loop", "inner"),                             mode = { "x", "o" },                 desc = icon.Repeat .. "inner loop" },
                { "aE",                      selectNode("codeblock", "outer"),                        mode = { "x", "o" },                 desc = icon.Repeat .. "outer codeblock" },
                { "iE",                      selectNode("codeblock", "inner"),                        mode = { "x", "o" },                 desc = icon.Repeat .. "inner codeblock" },
                { "a" .. text_obj.call,      selectNode("call", "outer"),                             mode = { "x", "o" },                 desc = icon.Call .. "outer call" },
                { "i" .. text_obj.call,      selectNode("call", "inner"),                             mode = { "x", "o" },                 desc = icon.Call .. "inner call" },
                { "a" .. text_obj.func,      selectNode("function", "outer"),                         mode = { "x", "o" },                 desc = icon.Function .. "outer function" },
                { "i" .. text_obj.func,      selectNode("function", "inner"),                         mode = { "x", "o" },                 desc = icon.Function .. "inner function" },
                { "a" .. text_obj.condition, selectNode("conditional", "outer"),                      mode = { "x", "o" },                 desc = icon.IfStatement .. "outer condition" },
                { "i" .. text_obj.condition, selectNode("conditional", "inner"),                      mode = { "x", "o" },                 desc = icon.IfStatement .. "inner condition" },
        },
        opts   = {
                move   = { set_jumps = true },
                select = { lookahead = true, include_surrounding_whitespace = false },
        },
}
