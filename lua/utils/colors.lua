-- https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua

local hex_chars = "0123456789abcdef"

local function rgbToHsl(r, g, b, a)
        r, g, b = r / 255, g / 255, b / 255

        local max, min = math.max(r, g, b), math.min(r, g, b)
        local h, s, l

        l = (max + min) / 2

        if max == min then
                h, s = 0, 0
        else
                local d = max - min
                local s
                if l > 0.5 then s = d / (2 - max - min) else s = d / (max + min) end
                if max == r then
                        h = (g - b) / d
                        if g < b then h = h + 6 end
                elseif max == g then
                        h = (b - r) / d + 2
                elseif max == b then
                        h = (r - g) / d + 4
                end
                h = h / 6
        end

        return h, s, l, a or 255
end

local function hslToRgb(h, s, l, a)
        local r, g, b

        if s == 0 then
                r, g, b = l, l, l
        else
                function hue2rgb(p, q, t)
                        if t < 0 then t = t + 1 end
                        if t > 1 then t = t - 1 end
                        if t < 1 / 6 then return p + (q - p) * 6 * t end
                        if t < 1 / 2 then return q end
                        if t < 2 / 3 then return p + (q - p) * (2 / 3 - t) * 6 end
                        return p
                end

                local q
                if l < 0.5 then q = l * (1 + s) else q = l + s - l * s end
                local p = 2 * l - q

                r = hue2rgb(p, q, h + 1 / 3)
                g = hue2rgb(p, q, h)
                b = hue2rgb(p, q, h - 1 / 3)
        end

        return r * 255, g * 255, b * 255, a * 255
end

local function rgbToHsv(r, g, b, a)
        r, g, b, a = r / 255, g / 255, b / 255, a / 255
        local max, min = math.max(r, g, b), math.min(r, g, b)
        local h, s, v
        v = max

        local d = max - min
        if max == 0 then s = 0 else s = d / max end

        if max == min then
                h = 0
        else
                if max == r then
                        h = (g - b) / d
                        if g < b then h = h + 6 end
                elseif max == g then
                        h = (b - r) / d + 2
                elseif max == b then
                        h = (r - g) / d + 4
                end
                h = h / 6
        end

        return h, s, v, a
end

local function hsvToRgb(h, s, v, a)
        local r, g, b

        local i = math.floor(h * 6);
        local f = h * 6 - i;
        local p = v * (1 - s);
        local q = v * (1 - f * s);
        local t = v * (1 - (1 - f) * s);

        i = i % 6

        if i == 0 then
                r, g, b = v, t, p
        elseif i == 1 then
                r, g, b = q, v, p
        elseif i == 2 then
                r, g, b = p, v, t
        elseif i == 3 then
                r, g, b = p, q, v
        elseif i == 4 then
                r, g, b = t, p, v
        elseif i == 5 then
                r, g, b = v, p, q
        end

        return r * 255, g * 255, b * 255, a * 255
end

local function hexToRgb(hex)
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

local function hexToHSL(hex)
        -- local hsluv   = require("solarized-osaka.hsluv")
        local rgb     = hexToRgb(hex)
        local h, s, l = rgbToHsl(rgb[1], rgb[2], rgb[3])

        return string.format("hsl(%d, %d, %d)", math.floor(h + 0.5), math.floor(s + 0.5), math.floor(l + 0.5))
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
function M.rgbToHsl(r, g, b, a)
        rgbToHsl(r, g, b, a)
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
function M.hslToRgb(h, s, l, a)
        hslToRgb(h, s, l, a)
end

--[[
 * Converts an RGB color value to HSV. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 * Assumes r, g, and b are contained in the set [0, 255] and
 * returns h, s, and v in the set [0, 1].
 *
 * @param   Number  r       The red color value
 * @param   Number  g       The green color value
 * @param   Number  b       The blue color value
 * @return  Array           The HSV representation
]]
function M.rgbToHsv(r, g, b, a)
        rgbToHsv(r, g, b, a)
end

--[[
 * Converts an HSV color value to RGB. Conversion formula
 * adapted from http://en.wikipedia.org/wiki/HSV_color_space.
 * Assumes h, s, and v are contained in the set [0, 1] and
 * returns r, g, and b in the set [0, 255].
 *
 * @param   Number  h       The hue
 * @param   Number  s       The saturation
 * @param   Number  v       The value
 * @return  Array           The RGB representation
]]
function M.hsvToRgb(h, s, v, a)
        hsvToRgb(h, s, v, a)
end

function M.hexToRgb(hex)
        hexToRgb(hex)
end

function M.hexToHSL(hex)
        hexToHSL(hex)
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
