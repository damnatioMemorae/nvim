local o       = vim.o
local bo      = vim.bo
local wo      = vim.wo
local fn      = vim.fn
local api     = vim.api
local autocmd = api.nvim_create_autocmd

---- TEXTOBJ -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local extra_textobj_maps = {
        func      = "f",
        call      = "l",
        condition = "o",
        wikilink  = "R",
}

---- BACKDROP ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function isFloatingWin()
        local win = api.nvim_get_current_win()
        return api.nvim_win_get_config(win).relative ~= ""
end

local function addBackdrop(delEvents, delPattern, backdropLevel)
        delEvents     = delEvents or "WinClosed"
        delPattern    = delPattern or nil
        backdropLevel = backdropLevel or vim.g.backdrop

        local backdrop_name  = "Backdrop"
        local zindex         = api.nvim_win_get_config(api.nvim_get_current_win()).zindex
        local backdrop_bufnr = api.nvim_create_buf(false, true)
        local win            = api.nvim_open_win(backdrop_bufnr, false, {
                relative  = "editor",
                row       = 0,
                col       = 0,
                width     = o.columns,
                height    = o.lines,
                focusable = false,
                style     = "minimal",
                zindex    = zindex - 10,
        })

        api.nvim_set_hl(0, backdrop_name, { bg = "#000000" })

        wo[win].winhighlight        = "Normal:" .. backdrop_name
        wo[win].winblend            = backdropLevel
        bo[backdrop_bufnr].buftype  = "nofile"
        bo[backdrop_bufnr].filetype = "backdrop"

        autocmd(delEvents, {
                pattern  = delPattern,
                callback = function()
                        if isFloatingWin() then
                                if api.nvim_buf_is_valid(backdrop_bufnr) then
                                        api.nvim_buf_delete(backdrop_bufnr, { force = true })
                                end
                        else
                                if api.nvim_win_is_valid(win) then
                                        api.nvim_win_close(win, true)
                                end
                        end
                end,
        })
end

---- HIGHLIGHTING --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function parseHex(intColor)
        return string.format("#%x", intColor)
end

local function getHl(name, fallback)
        if fn.hlexists(name) then
                local group = api.nvim_get_hl(0, { name = name })
                local fg    = group.fg
                local bg    = group.bg

                return {
                        fg = fg == nil and "NONE" or parseHex(fg),
                        bg = bg == nil and "NONE" or parseHex(bg),
                }
        end

        return fallback or {}
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

M.extraTextobjMaps = extra_textobj_maps

---@param delEvents? vim.api.keyset.events|vim.api.keyset.events[]
---@param delPattern? (`string|array?`)
function M.addBackdrop(delEvents, delPattern, backdropLevel)
        addBackdrop(delEvents, delPattern, backdropLevel)
end

---@param intColor number
---@return string
function M.parseHex(intColor)
        return parseHex(intColor)
end

---@param name string
---@param fallback? table
---@return table
function M.getHl(name, fallback)
        return getHl(name, fallback)
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
