local M = {}
------------------------------------------------------------------------------------------------------------------------

M.extraTextobjMaps = {
        func      = "f",
        call      = "l",
        condition = "o",
        wikilink  = "R",
}

---@param mode string|string[]
---@param lhs string
---@param rhs string|function
---@param opts? vim.keymap.set.Opts
function M.uniqueKeymap(mode, lhs, rhs, opts)
        if not opts then opts = {} end

        if opts.unique == nil then opts.unique = true end

        local success, _ = pcall(vim.keymap.set, mode, lhs, rhs, opts)
        if not success then
                local modes = type(mode) == "table" and table.concat(mode, ", ") or mode
                local msg   = ("Duplicate keymap\n[%s] %s"):format(modes, lhs)
                vim.defer_fn(
                        function()
                                vim.notify(msg, vim.log.levels.WARN, { title = "Keymaps", timeout = 4000 })
                        end, 1000)
        end
        pcall(vim.keymap.set, mode, lhs, rhs, opts)
end

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

---@param name string
function M.getHl(name)
        return vim.api.nvim_get_hl(0, { name = name })
end

---- SMALL STUFF -------------------------------------------------------------------------------------------------------

---@param groups table
---@param shortName? string
function M.linkHl(groups, shortName)
        shortName = shortName or ""

        for _, group in ipairs(groups) do
                vim.api.nvim_set_hl(0, shortName .. group[1], { link = group[2] })
        end
end

function M.getRowCol()
        local cursor = unpack(vim.api.nvim_win_get_cursor(0))
        return cursor[1], cursor[2]
end

function M.merge(...)
        local args = { ... }
        return vim.tbl_extend("force", {}, unpack(args))
end

function M.concat(...)
        local result = {}
        local args   = { ... }
        for _, i in ipairs(args) do
                for _, j in ipairs(i) do
                        table.insert(result, j)
                end
        end
        return result
end

function M.exec(cmd)
        return vim.trim(vim.fn.system(cmd))
end

---- COLORS ------------------------------------------------------------------------------------------------------------
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
]]
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
]]
function M.hslToRgb(h, s, l)
        local r, g, b

        if s == 0 then
                r, g, b = l, l, l
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
]]

---@param bufnr integer
---@param filepath string
---@return boolean
function M.allowBufferForAi(bufnr, filepath)
        if not filepath then filepath = vim.api.nvim_buf_get_name(bufnr) end
        local ft, filename = vim.bo[bufnr].filetype, vim.fs.basename(filepath)
        if vim.fn.reg_recording() ~= "" then return false end
        if vim.bo[bufnr].buftype ~= "" then return false end
        if ft == "text" then return false end
        if ft == "bib" then return false end
        if ft == "csv" then return false end
        if filename == "config.local" then return false end
        if not filename:find("%.") then return false end

        local paths_to_ignore = {
                "security",
                "leetcode/",
                "/private/var/",
                "api-key",
                ".env",
                "recovery",
        }
        local ignore_path     = vim.iter(paths_to_ignore)
                   :any(function(ignored) return filepath:lower():find(ignored, 1, true) ~= nil end)

        if ignore_path then
                vim.notify_once("Disabled AI on this buffer.")
                return false
        else
                return true
        end
end

---- MISC --------------------------------------------------------------------------------------------------------------

function M.playSound(file)
        local path = vim.fn.stdpath("config") .. "/sounds/"
        vim.fn.system("paplay " .. path .. file .. ".mp3")
end

------------------------------------------------------------------------------------------------------------------------
return M
