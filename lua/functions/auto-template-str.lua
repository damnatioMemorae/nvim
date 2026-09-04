---@diagnostic disable: missing-parameter

local bo  = vim.bo
local fn  = vim.fn
local ts  = vim.treesitter
local api = vim.api
local log = vim.log

local ft     = bo.ft
local levels = log.levels

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param msg string
local function warn(msg)
        vim.notify(msg, levels.WARN, { title = "Auto-template-string", icon = "󰅳" })
end

---@param strNode? TSNode
---@param insertAtCursor string text to insert at cursor location
---@param textTransformer fun(nodeText: string): string
---@param cursorMove "nodeEnd"|nil where to move the cursor before applying `cursorOffset`
---@param cursorOffset number number of columns to move to the right
local function updateNode(strNode, insertAtCursor, textTransformer, cursorMove, cursorOffset)
        if not strNode then return end
        local node_text = ts.get_node_text(strNode, 0)
        if node_text:find "[\n\r]" then
                warn "Multiline strings not supported yet."
                return
        end
        local node_row, node_start_col, _, node_end_col = strNode:range()
        local cursor_col                                = api.nvim_win_get_cursor(0)[2]
        -- local cursor_col                                = vim.pos.cursor(0)[2]

        -- 1. `insertAtCursor`
        local pos_in_node = cursor_col - node_start_col
        node_text         = node_text:sub(1, pos_in_node) .. insertAtCursor .. node_text:sub(pos_in_node + 1)

        -- 2. `textTransformer`
        node_text = textTransformer(node_text)
        api.nvim_buf_set_text(0, node_row, node_start_col, node_row, node_end_col, { node_text })

        -- 3. `cursorMove` & `cursorOffset`
        if cursorMove == "nodeEnd" then cursor_col = node_end_col end
        api.nvim_win_set_cursor(0, { node_row + 1, cursor_col + cursorOffset })
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local FiletypeFuncs = {}

---@param node TSNode
function FiletypeFuncs.lua(node)
        where(function(_) updateNode(_.node, "%s", _.transformer, "nodeEnd", 12) end) {
                transformer = function(nodeText) return "(" .. nodeText .. "):format()" end,
                node        = match(node.type()) {
                        string                               = node,
                        escape_sequence                      = node.parent():parent(),
                        -- node.type():find "^string_", node:parent(),
                        [node.type():find "^string_content"] = node:parent(),
                },
        }
end

---@param node TSNode
function FiletypeFuncs.python(node)
        where(function(_) updateNode(_.node, "{}", _.transformer, nil, 2) end) {
                transformer = function(nodeText) return "f" .. nodeText end,
                node        = match(node.type()) {
                        string                        = node,
                        escape_sequence               = node.parent():parent(),
                        -- node.type():find "^string_", node:parent(),
                        [node.type():find "^string_"] = node:parent(),
                },
        }
end

---@param node TSNode
function FiletypeFuncs.javascript(node)
        where(function(_) updateNode(_.node, "${}", _.transformer, nil, 2) end) {
                transformer = function(nodeText) return "`" .. nodeText:sub(2, -2) .. "`" end,
                node        = match(node.type()) {
                        [{ "string", "template_string" }]          = node,
                        [{ "string_fragment", "escape_sequence" }] = node:parent(),
                },
        }
end

FiletypeFuncs.typescript = FiletypeFuncs.javascript

---@param node TSNode
function FiletypeFuncs.swift(node)
        where(function(_) updateNode(_.node, "\\()", _.transformer, nil, 2) end) {
                transformer = function(nodeText) return nodeText end,
                node        = match(node.type()) {
                        line_srt_text       = node,
                        line_string_literal = node,
                },
        }
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function M.insertTemplateStr()
        if fn.mode() ~= "i" then return warn "Only works in insert mode." end

        local update_func = FiletypeFuncs[ft]
        if not update_func then return warn("Not configured for " .. ft) end
        local node_at_cursor = ts.get_node()
        if not node_at_cursor then return warn "No node at cursor" end

        update_func(node_at_cursor)
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
