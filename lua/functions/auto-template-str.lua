local M = {}
------------------------------------------------------------------------------------------------------------------------

---@param msg string
local function warn(msg)
        vim.notify(msg, vim.log.levels.WARN, { title = "Auto-template-string", icon = "󰅳" })
end

---@param strNode? TSNode
---@param insertAtCursor string
---@param textTransformer fun(nodeText: string): string
---@param cursorMove "nodeEnd"|nil
---@param cursorOffset number
local function updateNode(strNode, insertAtCursor, textTransformer, cursorMove, cursorOffset)
        if not strNode then
                return
        end

        local node_text = vim.treesitter.get_node_text(strNode, 0)
        if node_text:find("[\n\r]") then
                warn("Multiline strings not supported yet.")
                return
        end

        local node_row, node_start_col, _, node_end_col = strNode:range()
        local cursor_col                                = vim.api.nvim_win_get_cursor(0)[2]

        local pos_in_node = cursor_col - node_start_col
        node_text         = node_text:sub(1, pos_in_node) .. insertAtCursor .. node_text:sub(pos_in_node + 1)

        node_text = textTransformer(node_text)
        vim.api.nvim_buf_set_text(0, node_row, node_start_col, node_row, node_end_col, { node_text })

        if cursorMove == "nodeEnd" then cursor_col = node_end_col end
        vim.api.nvim_win_set_cursor(0, { node_row + 1, cursor_col + cursorOffset })
end

------------------------------------------------------------------------------------------------------------------------

local filetypeFuncs = {}

---@param node TSNode
function filetypeFuncs.lua(node)
        local str_node

        if node:type() == "string" then
                str_node = node
        elseif node:type():find("string_content") then
                str_node = node:parent()
        elseif node:type() == "escape_sequence" then
                str_node = node:parent():parent()
        end

        local transformer = function(nodeText) return "(" .. nodeText .. "):format()" end
        updateNode(str_node, "%s", transformer, "nodeEnd", 12)
end

---@param node TSNode
function filetypeFuncs.python(node)
        local str_node

        if node:type() == "string" then
                str_node = node
        elseif node:type():find("^string_") then
                str_node = node:parent()
        elseif node:type() == "escape_sequence" then
                str_node = node:parent():parent()
        end

        local transformer = function(nodeText) return "f" .. nodeText end
        updateNode(str_node, "{}", transformer, nil, 2)
end

------------------------------------------------------------------------------------------------------------------------

function M.insertTemplateStr()
        if vim.fn.mode() ~= "i" then
                return warn("Only works in insert mode.")
        end

        local update_func = filetypeFuncs[vim.bo.ft]
        if not update_func then
                return warn("Not configured for " .. vim.bo.ft)
        end

        local node_at_cursor = vim.treesitter.get_node()
        if not node_at_cursor then
                return warn("No node at cursor")
        end

        update_func(node_at_cursor)
end

------------------------------------------------------------------------------------------------------------------------
return M
