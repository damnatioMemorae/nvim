local textObj = require("core.utils").extraTextobjMaps

local icon = Icons.Kinds
local mode = { "n", "v", "x", "o" }

local function select(obj, pos)
        local textobject = "@" .. obj .. "." .. pos
        return function()
                require("nvim-treesitter-textobjects.select").select_textobject(textobject, "textobjects")
        end
end

local function addDocstring()
        require("nvim-treesitter-textobjects.move").goto_previous_start("@function.outer", "textobjects")

        local ft     = vim.bo.filetype
        local indent = vim.api.nvim_get_current_line():match("^%s*")
        local ln     = vim.api.nvim_win_get_cursor(0)[1]

        if ft == "python" then
                indent = indent .. (" "):rep(4)
                vim.api.nvim_buf_set_lines(0, ln, ln, false, { indent .. ('"'):rep(6) })
                vim.api.nvim_win_set_cursor(0, { ln + 1, #indent + 3 })
                vim.cmd.startinsert()
        elseif ft == "javascript" then
                vim.cmd.normal{ "t)", bang = true } -- go to parameter, since cursor has to be on diagnostic for code action
                vim.lsp.buf.code_action{
                        filter = function(action) return action.title == "Infer parameter types from usage" end,
                        apply  = true,
                }
                -- goto docstring (deferred, so code action can finish first)
                vim.defer_fn(function()
                                     vim.api.nvim_win_set_cursor(0, { ln + 1, 0 })
                                     vim.cmd.normal{ "t)", bang = true }
                             end, 100)
        elseif ft == "typescript" then
                -- add TSDoc
                vim.api.nvim_buf_set_lines(0, ln - 1, ln - 1, false, { indent .. "/**  */" })
                vim.api.nvim_win_set_cursor(0, { ln, #indent + 4 })
                vim.cmd.startinsert()
        elseif ft == "lua" then
                local param_line = vim.api.nvim_get_current_line():match("function.*%((.*)%)$")

                if not param_line then
                        return
                end

                local params       = vim.split(param_line, ", ?")
                local luadoc_lines = vim.iter(params)
                           :map(function(param) return ("%s---@param %s any"):format(indent, param) end)
                           :totable()
                vim.api.nvim_buf_set_lines(0, ln - 1, ln - 1, false, luadoc_lines)
                -- goto 1st param type & edit it
                vim.api.nvim_win_set_cursor(0, { ln, #luadoc_lines[1] })
                vim.cmd.normal{ '"_ciw', bang = true }
                vim.cmd.startinsert{ bang = true }
        else
                vim.notify(ft .. " is not supported.", vim.log.levels.WARN, { title = "docstring" })
        end
end

local function gotoObj(obj, pos, dir)
        local textobject = "@" .. obj .. "." .. pos
        if dir == "prev" then
                require("nvim-treesitter-textobjects.move").goto_previous_start(textobject, "textobjects")
        elseif dir == "next" then
                require("nvim-treesitter-textobjects.move").goto_next_start(textobject, "textobjects")
        end
end

local function swapObj(obj, pos, dir)
        local textobject = "@" .. obj .. "." .. pos
        if dir == "prev" then
                require("nvim-treesitter-textobjects.swap").swap_previous(textobject)
        elseif dir == "next" then
                require("nvim-treesitter-textobjects.swap").swap_next(textobject)
        end
end

return {
        "nvim-treesitter/nvim-treesitter-textobjects",
        dependencies = "nvim-treesitter",
        branch       = "main",
        keys         = {
                ----COMMENTS--------------------------------------------------------------------------------------------

                { "q", select("comment", "outer"), mode = "o", desc = "󰆈 single comment" },
                { "qf", addDocstring, desc = "󰆈 add docstring" },
                { -- CHANGE SINGLE COMMENT
                        "cq",
                        function()
                                -- not using `@comment.inner`, since not supported for many languages
                                local select_obj = require("nvim-treesitter-textobjects.select").select_textobject
                                select_obj("@comment.outer", "textobjects")
                                local com_str = vim.bo.commentstring:format("")
                                vim.cmd.normal{ "c" .. com_str, bang = true }
                                vim.cmd.startinsert{ bang = true }
                        end,
                        desc = "󰆈 Change single comment",
                },
                { -- STICKY DELETE COMMENT
                        "dq",
                        function()
                                -- as opposed to regular usage of the textobj, also trims the line
                                -- and preserves the cursor position
                                local cursor_before = vim.api.nvim_win_get_cursor(0)
                                local select_obj = require("nvim-treesitter-textobjects.select").select_textobject
                                select_obj("@comment.outer", "textobjects")
                                vim.cmd.normal{ "d", bang = true }
                                local trimmed_line = vim.api.nvim_get_current_line():gsub("%s+$", "")
                                vim.api.nvim_set_current_line(trimmed_line)
                                vim.api.nvim_win_set_cursor(0, cursor_before)
                        end,
                        desc = "󰆈 Sticky delete single comment",
                },

                ----MOVE------------------------------------------------------------------------------------------------

                { "<A-q>", function() gotoObj("comment", "outer", "next") end, mode = mode, desc = " Goto next comment" },
                { "<A-Q>", function() gotoObj("comment", "outer", "prev") end, mode = mode, desc = " Goto prev comment" },
                { "<A-f>", function() gotoObj("function", "name", "next") end, mode = mode, desc = icon.Function .. "Goto next function" },
                { "<A-F>", function() gotoObj("function", "name", "prev") end, mode = mode, desc = icon.Function .. "Goto next function" },
                { "<A-a>", function() gotoObj("parameter", "outer", "next") end, mode = mode, desc = icon.Parameter .. "Goto next parameter" },
                { "<A-A>", function() gotoObj("parameter", "outer", "prev") end, mode = mode, desc = icon.Parameter .. "Goto prev parameter" },
                { "<A-o>", function() gotoObj("conditional", "inner", "next") end, mode = mode, desc = icon.IfStatement .. "Goto next condition" },
                { "<A-O>", function() gotoObj("conditional", "inner", "prev") end, mode = mode, desc = icon.IfStatement .. "Goto prev condition" },
                { "<A-c>", function() gotoObj("call", "outer", "next") end, mode = mode, desc = icon.Call .. "Goto next call" },
                { "<A-C>", function() gotoObj("call", "outer", "prev") end, mode = mode, desc = icon.Call .. "Goto prev call" },
                { "<A-u>", function() gotoObj("loop", "outer", "next") end, mode = mode, desc = icon.Repeat .. "Goto next loop" },
                { "<A-U>", function() gotoObj("loop", "outer", "prev") end, mode = mode, desc = icon.Repeat .. "Goto prev loop" },
                { "<A-s>", function() gotoObj("assignment", "lhs", "next") end, mode = mode, desc = icon.Variable .. "Goto next assignment" },
                { "<A-S>", function() gotoObj("assignment", "lhs", "prev") end, mode = mode, desc = icon.Variable .. "Goto prev assignment" },
                { "<A-v>", function() gotoObj("assignment", "rhs", "next") end, mode = mode, desc = icon.Value .. "Goto next value" },
                { "<A-V>", function() gotoObj("assignment", "rhs", "prev") end, mode = mode, desc = icon.Value .. "Goto prev value" },
                { "<A-t>", function() gotoObj("assignment", "outer", "next") end, mode = mode, desc = icon.Type .. "Goto next type" },
                { "<A-T>", function() gotoObj("assignment", "outer", "prev") end, mode = mode, desc = icon.Type .. "Goto prev type" },

                ----SWAP------------------------------------------------------------------------------------------------

                { "<A-}>", function() swapObj("parameter", "inner", "next") end, desc = icon.Parameter .. "Swap arg" },
                { "<A-{>", function() swapObj("parameter", "inner", "prev") end, desc = icon.Parameter .. "Swap arg" },

                { "<A-}>", function() swapObj("md_section", "inner", "next") end, desc = icon.Parameter .. "Swap arg", ft = "markdown" },
                { "<A-{>", function() swapObj("md_section", "inner", "prev") end, desc = icon.Parameter .. "Swap arg", ft = "markdown" },

                ----TEXT OBJECTS----------------------------------------------------------------------------------------

                { "a/", select("regex", "outer"), mode = { "x", "o" }, desc = icon.Regex .. "outer regex" },
                { "i/", select("regex", "inner"), mode = { "x", "o" }, desc = icon.Regex .. "inner regex" },
                { "aa", select("parameter", "outer"), mode = { "x", "o" }, desc = icon.Parameter .. "outer arg" },
                { "ia", select("parameter", "inner"), mode = { "x", "o" }, desc = icon.Parameter .. "inner arg" },
                { "au", select("loop", "outer"), mode = { "x", "o" }, desc = icon.Repeat .. "outer loop" },
                { "iu", select("loop", "inner"), mode = { "x", "o" }, desc = icon.Repeat .. "inner loop" },
                { "a" .. textObj.call, select("call", "outer"), mode = { "x", "o" }, desc = icon.Call .. "outer call" },
                { "i" .. textObj.call, select("call", "inner"), mode = { "x", "o" }, desc = icon.Call .. "inner call" },
                { "a" .. textObj.func, select("function", "outer"), mode = { "x", "o" }, desc = icon.Function .. "outer function" },
                { "i" .. textObj.func, select("function", "inner"), mode = { "x", "o" }, desc = icon.Function .. "inner function" },
                { "a" .. textObj.condition, select("conditional", "outer"), mode = { "x", "o" }, desc = icon.IfStatement .. "outer condition" },
                { "i" .. textObj.condition, select("conditional", "inner"), mode = { "x", "o" }, desc = icon.IfStatement .. "inner condition" },
        },
        opts         = { select = { lookahead = true, include_surrounding_whitespace = true } },
}
