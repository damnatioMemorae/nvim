local _repeat = { lhs = nil, buf = nil }

vim.keymap.set("n", ".", function()
                       local b = vim.api.nvim_get_current_buf()
                       if _repeat.lhs and _repeat.buf == b then
                               return vim.api.nvim_feedkeys(
                                       vim.keycode((vim.v.count > 0 and vim.v.count or "") .. _repeat.lhs), "m", false)
                       end
                       vim.api.nvim_feedkeys(vim.keycode("."), "n", false)
               end, { silent = true })

---@class MyConfig.Keymap : vim.keymap.set.Opts
---@field [1] string
---@field [2] string|function
---@field mode? string|string[]
---@field ft? string|string[]
---@field dotmap? boolean

---@param map MyConfig.Keymap
function _G.smartMap(map)
        local mode = map.mode or "n"
        local lhs  = map[1]
        local rhs  = map[2]
        local opts = vim.deepcopy(map)

        opts.ft, opts.mode, opts[1], opts[2] = nil, nil, nil, nil

        local caller = debug.getinfo(2, "Sl")
        local source = vim.fs.basename(caller.source) .. ":" .. caller.currentline

        if map[3] then
                vim.defer_fn(function()
                                     local msg = ("%s  %s"):format(lhs, source)
                                     vim.notify(msg, vim.log.levels.WARN,
                                                { title = "Keymap with 3 args", timeout = false })
                             end, 1000)
                return
        end

        local dotrepeat = opts.dotmap
        opts.dotmap     = nil

        if dotrepeat then
                local f = rhs
                rhs = (type(f) == "function") and function(...)
                        _repeat.lhs, _repeat.buf = lhs, vim.api.nvim_get_current_buf()
                        return f(...)
                end or function()
                        _repeat.lhs, _repeat.buf = lhs, vim.api.nvim_get_current_buf()
                        ---@cast f string
                        vim.api.nvim_feedkeys(vim.keycode(f), "m", false)
                end
        end

        if not map.ft then
                if opts.unique == nil and opts.buf == nil then
                        opts.unique = true
                end

                local success, _ = pcall(vim.keymap.set, mode, lhs, rhs, opts)
                if success then
                        return
                end

                local modes = type(mode) == "table" and table.concat(mode, ", ") or mode
                local msg   = ("[%s]  %s  %s"):format(modes, lhs, source)

                vim.defer_fn(function()
                                     vim.notify(msg, vim.log.levels.WARN, { title = "Duplicate keymap", timeout = false })
                             end, 1000)
        else
                vim.api.nvim_create_autocmd("FileType", {
                        desc     = "User: plugin filetype-keymap",
                        pattern  = map.ft,
                        callback = function(args)
                                opts.buf = args.buf
                                vim.keymap.set(mode, lhs, rhs, opts)
                        end,
                })
        end
end

---@param map MyConfig.Keymap
function _G.bufMap(map)
        map.buf = 0
        _G.smartMap(map)
end

---@param text string
---@param replace string
function _G.bufAbbr(text, replace)
        vim.keymap.set("ia", text, replace, { buf = 0 })
end

---@param module string
function _G.safeRequire(module)
        local success, errmsg = pcall(require, module)
        if success then return end

        local msg = ("Error loading `%s`: %s"):format(module, errmsg)
        vim.defer_fn(function()
                             vim.notify(msg, vim.log.levels.ERROR, { title = "User config", timeout = false })
                     end, 1000)
end

local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

M.extraTextobjMaps = {
        func      = "f",
        call      = "l",
        condition = "o",
        wikilink  = "R",
}

---- SMALL STUFF ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param name string
function M.getHl(name)
        return vim.api.nvim_get_hl(0, { name = name })
end

local function hlLink(group, prefix)
        vim.api.nvim_set_hl(0, prefix .. group[1], { link = group[2] })
end

---@param groups table
---@param prefix? string
function M.hlBulk(groups, prefix)
        prefix = prefix or ""
        vim.iter(groups):each(function(group) hlLink(group, prefix) end)
end

---- COLORS --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
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
                local function hue2rgb(p, q, t)
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

---- MISC ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function M.playSound(file)
        local path = vim.fn.stdpath("config") .. "/sounds/"
        vim.fn.system("paplay " .. path .. file .. ".mp3")
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
