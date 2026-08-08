local v   = vim.v
local fs  = vim.fs
local api = vim.api
local log = vim.log
local set = vim.keymap.set

local levels  = log.levels
local autocmd = api.nvim_create_autocmd

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

require "utils.functional" ()

---- HIGHLIGHT -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function hlLink(name, link)
        api.nvim_set_hl(0, name, { link = link })
end

local function hlDynLink(name, link)
        hlLink(name, link)
        auq "ColorScheme" { callback = function() hlLink(name, link) end }
end

---@type fun(key: string): fun(acc: table): fun(value: table)
local function linq(key)
        local function step(acc)
                return function(value)
                        unless(nilq(value))(acc)
                        hlDynLink(concat "" (key)(value[1]), value[2])
                        return step(fold(acc))
                end
        end
        return step {}
end

---@type fun(key: string): fun(acc: table): fun(value: table)
local function _linq(key)
        local function step(acc)
                return function(value)
                        unless(nilq(value))(acc)
                        hlDynLink(value, concat "" (key) "")
                        return step(fold(acc))
                end
        end
        return step {}
end

---@param a string
local function hl(a)
        local lhs = a[1]
        local rhs = a[2]

        if strq(rhs) then
                api.nvim_set_hl(0, lhs, { link = rhs })
        elseif tblq(rhs) then
                local fg = rhs[1] or nil
                local bg = rhs[2] or nil
                api.nvim_set_hl(0, lhs, { fg = fg, bg = bg })
        end
end

---- AUTOCMD -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function auq(event)
        return function(opts)
                return autocmd(event, opts)
        end
end

---- KEYMAP --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local _repeat = { lhs = nil, buf = nil }
set("n", ".", function()
            local b = api.nvim_get_current_buf()
            if _repeat.lhs and _repeat.buf == b then
                    return api.nvim_feedkeys(vim.keycode((v.count > 0 and v.count or "") .. _repeat.lhs), "m", false)
            end
            api.nvim_feedkeys(vim.keycode ".", "n", false)
    end, { silent = true })

---@class MyConfig.Keymap : vim.keymap.set.Opts
---@field [1] string
---@field [2] string | function
---@field mode? string | string[]
---@field ft? string | string[]

---@param keymap MyConfig.Keymap
-- local function smartMap(keymap)
local function keyq(keymap)
        local mode = keymap.mode or "n"
        local lhs  = keymap[1]
        local rhs  = keymap[2]
        local opts = vim.deepcopy(keymap)

        opts.ft, opts.mode, opts[1], opts[2] = nil, nil, nil, nil

        local caller = debug.getinfo(2, "Sl")
        local source = fs.basename(caller.source) .. ":" .. caller.currentline

        if keymap[3] then
                vim.defer_fn(function()
                                     local msg = ("%s %s"):format(lhs, source)
                                     vim.notify(msg, levels.WARN, { title = "Keymap with 3 args" })
                             end, 1000)
                return
        end

        if not keymap.ft then
                if opts.unique == nil and opts.buf == nil then
                        opts.unique = true
                end

                local success, _ = pcall(set, mode, lhs, rhs, opts)
                if success then return end

                local modes = type(mode) == "table" and table.concat(mode, ", ") or mode
                local msg   = ("[%s] %s %s"):format(modes, lhs, source)

                vim.defer_fn(function()
                                     vim.notify(msg, levels.WARN, { title = "Duplicate keymap" })
                             end, 1000)
        else
                auq "FileType" {
                        desc     = "User: plugin filetype-keymap",
                        pattern  = keymap.ft,
                        callback = function(args)
                                opts.buf = args.buf
                                set(mode, lhs, rhs, opts)
                        end,
                }
        end
end

-- local function keyq(keymap)
--         return smartMap(keymap)
-- end

local function bufq(keymap)
        keymap.buf = 0
        keyq(keymap)
end

-- local function bufq(keymap)
--         return bufMap(keymap)
-- end

local function bufAbbr(text)
        return function(replace)
                set("ia", text, replace, { buf = 0 })
        end
end

local function pcmd(command)
        return function(fallback)
                local success = pcall(vim.cmd, command) ---@diagnostic disable-line: param-type-mismatch
                if not success then
                        pcall(vim.cmd, fallback) ---@diagnostic disable-line: param-type-mismatch
                end
        end
end

local function try(command)
        local function step(acc)
                return function(fallback)
                        unless(nilq(fallback))(acc)
                        pcmd(command)(fallback)
                        return step(fold(acc))
                end
        end
        return step {}
end

---- MODULES -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param exports table
local function exporter(exports)
        return setmetatable(exports, {
                __call = function(self, override)
                        for _, group in pairs(self) do
                                if type(group) == "table" then
                                        for key, value in pairs(group) do
                                                if rawget(_G, key) ~= nil then
                                                        if override then
                                                                print(("WARNING: global '%s' already exists. Overwritten.")
                                                                        :format(key))
                                                                rawset(_G, key, value)
                                                        else
                                                                print(("NOTICE: global '%s' already exists. Skipped.")
                                                                        :format(key))
                                                        end
                                                else
                                                        rawset(_G, key, value)
                                                end
                                        end
                                end
                        end
                end,
        })
end

---@param modname string
local function safeRequire(modname)
        local success, errmsg = pcall(require, modname)
        if success then return end

        local msg = ("Error loading `%s`: %s"):format(modname, errmsg)
        vim.defer_fn(function()
                             vim.notify(msg, levels.ERROR, { title = "User config", timeout = false })
                     end, 1000)
        return errmsg
end

---@type fun(modname: string): fun(event?: vim.api.keyset.events): fun(pattern?: string)
local function lazyReq(modname)
        return function(event)
                return function(pattern)
                        when(nilq(event))(function() safeRequire(modname) end)(function()
                                auq(event) {
                                        pattern  = pattern,
                                        once     = true,
                                        callback = function() safeRequire(modname) end,
                                }
                        end)
                end
        end
end

---@type fun(dir: string): fun(value: string|table)
local function req(dir)
        local function step(acc)
                return function(value)
                        unless(nilq(value))(acc)
                        lazyReq(concat "." (dir)(ext(value)(1)))(_ext(value)(2))(_ext(value)(3))
                        return step(fold(acc))
                end
        end
        return step {}
end

---@type fun(): fun(value: string|table)
local function areq()
        local function step(acc)
                return function(value)
                        unless(nilq(value))(acc)
                        lazyReq(concat "." (dir)(ext(value)(1)))(_ext(value)(2))(_ext(value)(3))
                        return step(fold(acc))
                end
        end
        return step {}
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

M.autocmds   = {
        auq = auq,
}
M.highlights = {
        hl    = hl,
        linq  = linq,
        _linq = _linq,
}
M.keymaps    = {
        smartMap = smartMap,
        bufMap   = bufMap,
        abbr     = bufAbbr,
        bufq     = bufq,
        keyq     = keyq,
        pcmd     = pcmd,
        try      = try,
}
M.modules    = {
        req         = req,
        areq        = areq,
        lazyReq     = lazyReq,
        exporter    = exporter,
        safeRequire = safeRequire,
}

setmetatable(M, {
        __call = function(self)
                for _, group in pairs(self) do
                        if type(group) == "table" then
                                for key, value in pairs(group) do
                                        rawset(_G, key, value)
                                end
                        end
                end
        end,
})

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
