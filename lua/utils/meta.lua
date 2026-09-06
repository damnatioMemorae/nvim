local v   = vim.v
local fs  = vim.fs
local api = vim.api
local log = vim.log
local set = vim.keymap.set

local levels  = log.levels
local autocmd = api.nvim_create_autocmd

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

require "utils.functional" ()

---- AUTOCMD -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@type fun(event: vim.api.keyset.events): fun(opts: vim.api.keyset.create_autocmd)
local function auq(event)
        return function(opts)
                return autocmd(event, opts)
        end
end

---- HIGHLIGHT -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function hlLink(name, link)
        api.nvim_set_hl(0, name, { link = link })
end

local function hlDynLink(name, link)
        hlLink(name, link)
        auq "ColorScheme" { callback = function() hlLink(name, link) end }
end

---@type fun(key: string): fun(acc: table): fun(value: table)
local function linq(prefix)
        local function step(acc)
                return function(link)
                        unless(nilq(link))(acc)
                        hlDynLink(concat "" (prefix)(link[1]), link[2])
                        return step(fold { acc, link })
                end
        end
        return step {}
end

---@type fun(key: string): fun(acc: table): fun(value: table)
local function _linq(link)
        local function step(acc)
                return function(name)
                        unless(nilq(name))(acc)
                        hlDynLink(name, concat "" (link) "")
                        return step(fold { acc, name })
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

---- OPTIONS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function option(scope)
        return function(opt)
                if opt then
                        vim[scope][opt[1]] = opt[2]
                end
        end
end

---@type fun(dir: string): fun(value: string|table)
local function optq(scope)
        local function step(acc)
                return function(value)
                        unless(nilq(value))(acc)
                        option(scope) { value[1], value[2] }
                        return step(fold { acc, value })
                end
        end
        return step {}
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
local function keymapq(keymap)
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

                -- local modes = type(mode) == "table" and table.concat(mode, ", ") or mode
                -- local msg   = ("[%s] %s %s"):format(modes, lhs, source)

                -- vim.defer_fn(function()
                --                      vim.notify(msg, levels.WARN, { title = "Duplicate keymap" })
                --              end, 1000)
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

local function kq()
        local function step(acc)
                return function(km)
                        unless(nilq(km))(acc)
                        keymapq(km)
                        return step(fold { acc, km })
                end
        end
        return step {}
end

local function bufq(keymap)
        keymap.buf = 0
        keymapq(keymap)
end

local function bufAbbr(text)
        return function(replace)
                set("ia", text, replace, { buf = 0 })
        end
end

local function pcmd(command)
        return function(fallback)
                local ok = pcall(vim.cmd, command) ---@diagnostic disable-line: param-type-mismatch
                if not ok then
                        pcall(vim.cmd, fallback) ---@diagnostic disable-line: param-type-mismatch
                end
        end
end

---- MODULES -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

local function lazyReq(modname)
        return function(lazy)
                if lazy[1] == nil then return safeRequire(modname) end
                auq(lazy[1]) {
                        pattern  = lazy[2],
                        once     = true,
                        callback = function() safeRequire(modname) end,
                }
        end
end

---@type fun(dir: string): fun(value: string|table)
local function req(dir)
        local function step(acc)
                return function(modname)
                        unless(nilq(modname))(acc)
                        lazyReq(concat "." (dir)(modname[1] or modname)) { modname[2], modname[3] }
                        return step(fold { acc, modname })
                end
        end
        return step {}
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

M.autocmds   = { auq = auq }
M.options    = { optq = optq }
M.highlights = { hl = hl, linq = linq, _linq = _linq }
M.keymaps    = { abbr = bufAbbr, bufq = bufq, keymapq = keymapq, pcmd = pcmd, kq = kq }
M.modules    = {
        req         = req,
        lazyReq     = lazyReq,
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
