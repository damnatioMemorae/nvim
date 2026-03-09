local M = {}
------------------------------------------------------------------------------------------------------------------------

local api = vim.api
local cmd = vim.cmd
local fn  = vim.fn

M.extraTextobjMaps = {
        func      = "f",
        call      = "l",
        condition = "o",
        wikilink  = "R",
}

---ensures unique keymaps https://www.reddit.com/r/neovim/comments/16h2lla/can_you_make_neovim_warn_you_if_your_config_maps/
---@param mode string|string[]
---@param lhs string|string[]
---@param rhs string|function
---@param opts? {desc?: string, unique?: boolean, buffer?: number|boolean, remap?: boolean, silent?: boolean, nowait?: boolean}
function M.uniqueKeymap(mode, lhs, rhs, opts)
        if not opts then opts = {} end
        if opts.unique == nil then opts.unique = true end
        pcall(vim.keymap.set, mode, lhs, rhs, opts)
end

function M.multiMap(mode, lhs, rhs, opts)
        vim.keymap.set(mode, lhs, rhs, opts)
end

---sets `buffer`, `silent` and `nowait` to true
---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? {desc?: string, unique?: boolean, buffer?: number|boolean, remap?: boolean, silent?:boolean, nowait?: boolean}
function M.bufKeymap(mode, lhs, rhs, opts)
        opts = vim.tbl_extend("force", { buffer = true, silent = true, nowait = true }, opts or {})
        vim.keymap.set(mode, lhs, rhs, opts)
end

---@param text string
---@param replace string
function M.bufAbbrev(text, replace) vim.keymap.set("ia", text, replace, { buffer = true }) end

---@param client string|function
function M.supportsMethod(client)
        ---@param method string
        return function(method, opts)
                ---@diagnostic disable-next-line: undefined-field
                return client.supports_method(client, method, opts)
        end
end

-- craftzdog/utils.lua
-- https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua

local hex_chars = "0123456789abcdef"

function M.hexToRgb(hex)
        hex       = string.lower(hex)
        local ret = {}
        for i = 0, 2 do
                local char1  = string.sub(hex, i * 2 + 2, i * 2 + 2)
                local char2  = string.sub(hex, i * 2 + 3, i * 2 + 3)
                local digit1 = string.find(hex_chars, char1) - 1
                local digit2 = string.find(hex_chars, char2) - 1
                ret[i + 1]   = (digit1 * 16 + digit2) / 255.0
        end
        return ret
end

--[[
 * Converts an RGB color value to HSL. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes r, g, and b are contained in the set [0, 255] and
 * returns h, s, and l in the set [0, 1].
 *
 * @param   Number  r       The red color value
 * @param   Number  g       The green color value
 * @param   Number  b       The blue color value
 * @return  Array           The HSL representation
--]]
function M.rgbToHsl(r, g, b)
        local max, min = math.max(r, g, b), math.min(r, g, b)
        local h        = 0
        local s        = 0
        local l        = 0

        l = (max + min) / 2

        if max == min then
                h, s = 0, 0 -- achromatic
        else
                local d = max - min
                if l > 0.5 then
                        s = d / (2 - max - min)
                else
                        s = d / (max + min)
                end
                if max == r then
                        h = (g - b) / d
                        if g < b then
                                h = h + 6
                        end
                elseif max == g then
                        h = (b - r) / d + 2
                elseif max == b then
                        h = (r - g) / d + 4
                end
                h = h / 6
        end

        return h * 360, s * 100, l * 100
end

--[[
 * Converts an HSL color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSL_color_space.
 * Assumes h, s, and l are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  l       The lightness
 * @return  Array           The RGB representation
--]]
function M.hslToRgb(h, s, l)
        local r, g, b

        if s == 0 then
                r, g, b = l, l, l -- achromatic
        else
                function hue2rgb(p, q, t)
                        if t < 0 then
                                t = t + 1
                        end
                        if t > 1 then
                                t = t - 1
                        end
                        if t < 1 / 6 then
                                return p + (q - p) * 6 * t
                        end
                        if t < 1 / 2 then
                                return q
                        end
                        if t < 2 / 3 then
                                return p + (q - p) * (2 / 3 - t) * 6
                        end
                        return p
                end

                local q
                if l < 0.5 then
                        q = l * (1 + s)
                else
                        q = l + s - l * s
                end
                local p = 2 * l - q

                r = hue2rgb(p, q, h + 1 / 3)
                g = hue2rgb(p, q, h)
                b = hue2rgb(p, q, h - 1 / 3)
        end

        return r * 255, g * 255, b * 255
end

function M.hexToHSL(hex)
        -- local hsluv   = require("solarized-osaka.hsluv")
        local rgb     = M.hexToRgb(hex)
        local h, s, l = M.rgbToHsl(rgb[1], rgb[2], rgb[3])

        return string.format("hsl(%d, %d, %d)", math.floor(h + 0.5), math.floor(s + 0.5), math.floor(l + 0.5))
end

--[[
 * Converts an HSL color value to RGB in Hex representation.
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  l       The lightness
 * @return  String           The hex representation
--]]

------------------------------------------------------------------------------------------------------------------------
-- TREESITTER
-- borrowed forever from https://github.com/nfrid/treesitter-utils

---@param node TSNode
---@param bufnr number | nil
---@return number, number, number, number
local function getNodeRange(node, bufnr)
        local bufnr          = bufnr or 0
        local sr, sc, er, ec = node:range()
        local last_row       = vim.api.nvim_buf_line_count(bufnr) - 1
        -- If the node is the last node in the buffer, then its end row and column might need
        -- to be adjusted to avoid out-of-bounds error when calling nvim_buf_[set|get]_text
        if er > last_row then
                er = last_row
                ec = #vim.api.nvim_buf_get_lines(bufnr, last_row, last_row + 1, false)[1]
        end
        return sr, sc, er, ec
end

--- Find parent node of given type.
---@param node TSNode
---@param type string
---@return TSNode | nil
function M.findParentNode(node, type)
        if (node == node:root()) then return nil end
        if (node:type() == type) then return node end
        return M.findParentNode(node:parent(), type)
end

--- Find child node of given type.
---@param node TSNode
---@param type string
---@return TSNode | nil
function M.findChildNode(node, type)
        local child = node:child(0)
        while child do
                if (child:type() == type) then return child end
                child = child:next_sibling()
        end
        return nil
end

--- Set text of given node.
---@param node TSNode
---@param text string | table
---@param bufnr number | nil
function M.setNodeText(node, text, bufnr)
        local sr, sc, er, ec = getNodeRange(node, bufnr)
        local content        = { text }
        if (type(text) == "table") then content = text end
        vim.api.nvim_buf_set_text(bufnr or 0, sr, sc, er, ec, content)
end

--- Get text of given node.
---@param node TSNode
---@param bufnr number | nil
---@return string[]
function M.getNodeText(node, bufnr)
        local sr, sc, er, ec = getNodeRange(node, bufnr)
        return vim.api.nvim_buf_get_text(bufnr or 0, sr, sc, er, ec, {})
end

--------------------------------------------------------------------------------
return M
