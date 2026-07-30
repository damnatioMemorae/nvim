local v   = vim.v
local fs  = vim.fs
local api = vim.api
local log = vim.log
local set = vim.keymap.set

local levels        = log.levels
local autocmd       = api.nvim_create_autocmd
local exec_autocmds = api.nvim_exec_autocmds

---@return table | any
local function copy(obj)
        if type(obj) ~= "table" then
                return obj
        end
        return vim.iter(obj):totable()
end

local function eq(a)
        return function(b)
                return a == b
        end
end

local function nilq(a)
        return eq(a)(nil)
end

local function ext(tbl)
        return function(idx)
                return copy(tbl)[copy(idx)] or copy(tbl)
        end
end

local function extN(tbl)
        return function(idx)
                return copy(tbl)[copy(idx)] or nil
        end
end

local function concat(sep)
        return function(head)
                return function(tail)
                        return copy(head) .. copy(sep) .. copy(tail)
                end
        end
end

local function fold(acc)
        return function(list)
                local new_acc         = copy(acc)
                new_acc[#new_acc + 1] = list
                return new_acc
        end
end

local function when(condition)
        return function(value)
                return function(action)
                        return function(otherwise)
                                local ok = type(condition) == "function"
                                           and condition(value)
                                           or condition

                                local branch = ok
                                           and action
                                           or otherwise

                                if branch ~= nil then
                                        return type(branch) ~= "function"
                                                   and branch(value)
                                                   or branch
                                end
                        end
                end
        end
end

local function q(f)
        local function step(acc)
                return function(p)
                        if copy(p) == nil then
                                return copy(acc)
                        end
                        f(p)
                        return step(fold(acc))
                end
        end
        return step({})
end

---- HIGHLIGHT -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function hlLink(name, link)
        api.nvim_set_hl(0, name, { link = link })
end

local function hlDyn(groups, prefix)
        prefix = prefix or ""
        local function helper(_groups, _prefix)
                vim.iter(_groups):each(function(group)
                        api.nvim_set_hl(0, concat("")(prefix)(group[1]), group[2])
                end)
        end
        helper(groups, prefix)
        autocmd("ColorScheme", {
                callback = function()
                        helper(groups, prefix)
                end,
        })
end

local function hlDynLink(name, link)
        hlLink(name, link)
        autocmd("ColorScheme", {
                callback = function()
                        hlLink(name, link)
                end,
        })
end

local function linq(key)
        local function step(acc)
                return function(value)
                        when(nilq(value))(acc)
                        hlDynLink(concat("")(key)(value[1]), value[2])
                        return step(fold(acc))
                end
        end
        return step({})
end

local function revLinq(key)
        local function step(acc)
                return function(value)
                        when(nilq(value))(acc)
                        hlDynLink(value, concat("")(key)(""))
                        return step(fold(acc))
                end
        end
        return step({})
end

---@class MyConfig.Highlight
---@field [1] string
---@field [2] string
---@field [3] string

---@param hl MyConfig.Highlight
local function hi(hl)
        local name = hl[1]
        local fg   = hl[2]
        local bg   = hl[3]

        api.nvim_set_hl(0, name, {})
end

---- KEYMAP --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local _repeat = { lhs = nil, buf = nil }
set("n", ".", function()
            local b = api.nvim_get_current_buf()
            if _repeat.lhs and _repeat.buf == b then
                    return api.nvim_feedkeys(vim.keycode((v.count > 0 and v.count or "") .. _repeat.lhs), "m", false)
            end
            api.nvim_feedkeys(vim.keycode("."), "n", false)
    end, { silent = true })

local function smartMap(map)
        local mode = map.mode or "n"
        local lhs  = map[1]
        local rhs  = map[2]
        local opts = vim.deepcopy(map)

        opts.ft, opts.mode, opts[1], opts[2] = nil, nil, nil, nil

        local caller = debug.getinfo(2, "Sl")
        local source = fs.basename(caller.source) .. ":" .. caller.currentline

        if map[3] then
                vim.defer_fn(function()
                                     local msg = ("%s  %s"):format(lhs, source)
                                     vim.notify(msg, levels.WARN, { title = "Keymap with 3 args" })
                             end, 1000)
                return
        end

        local _dotrepeat = opts.dotmap
        opts.dotmap      = nil

        -- if _dotrepeat then
        --         local f  = rhs
        --         rhs  = (type(f) == "function") and function(...)
        --                 _repeat.lhs, _repeat.buf  = lhs, api.nvim_get_current_buf()
        --                 return f(...)
        --         end or function()
        --                 _repeat.lhs, _repeat.buf  = lhs, api.nvim_get_current_buf()
        --                 ---@cast f string
        --                 api.nvim_feedkeys(vim.keycode(f), "m", false)
        --         end
        -- end

        if not map.ft then
                if opts.unique == nil and opts.buf == nil then
                        opts.unique = true
                end

                local success, _ = pcall(set, mode, lhs, rhs, opts)
                if success then
                        return
                end

                local modes = type(mode) == "table" and table.concat(mode, ", ") or mode
                local msg   = ("[%s]  %s  %s"):format(modes, lhs, source)

                vim.defer_fn(function()
                                     vim.notify(msg, levels.WARN, { title = "Duplicate keymap" })
                             end, 1000)
        else
                autocmd("FileType", {
                        desc     = "User: plugin filetype-keymap",
                        pattern  = map.ft,
                        callback = function(args)
                                opts.buf = args.buf
                                set(mode, lhs, rhs, opts)
                        end,
                })
        end
end

local function bufAbbr(text, replace)
        set("ia", text, replace, { buf = 0 })
end

---- REQUIRE -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function safeRequire(modname)
        local success, errmsg = pcall(require, modname)
        if success then
                return
        end

        local msg = ("Error loading `%s`: %s"):format(modname, errmsg)
        vim.defer_fn(function()
                             vim.notify(msg, levels.ERROR, { title = "User config", timeout = false })
                     end, 1000)
        return errmsg
end

local function lazyReq(modname)
        return function(event)
                return function(pattern)
                        if not event then
                                safeRequire(modname)
                                return
                        end

                        -- when(nilq(event))(safeRequire(modname))(false)
                        autocmd(event, {
                                pattern  = pattern,
                                once     = true,
                                callback = function()
                                        safeRequire(modname)
                                end,
                        })
                end
        end
end

local function req(key)
        local function step(acc)
                return function(value)
                        if copy(value) == nil then
                                return copy(acc)
                        end
                        lazyReq(concat(".")(key)(ext(value)(1)))(extN(value)(2))(extN(value)(3))
                        return step(fold(acc))
                end
        end
        return step({})
end

---- EVENT ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function emit(group, buf)
        if buf == 0 or buf == nil then
                buf = api.nvim_get_current_buf()
        end
        if type(group) == "string" then
                api.nvim_create_augroup(group, { clear = false })
        end

        exec_autocmds("User", {
                pattern = "CustomEvent",
                group   = group,
                data    = { buf = buf },
        })
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EXPOSE
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param hl string
function _G.linq(hl) return linq(hl) end

---@param hl string
function _G.hi(hl) return revLinq(hl) end

---@param groups table<string, vim.api.keyset.highlight>
---@param prefix? string
function _G.hlDyn(groups, prefix) hlDyn(groups, prefix) end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@class MyConfig.Keymap : vim.keymap.set.Opts
---@field [1] string
---@field [2] string | function
---@field mode? string | string[]
---@field ft? string | string[]
---@field dotmap? boolean

---@param map MyConfig.Keymap
function _G.smartMap(map) smartMap(map) end

---@param map MyConfig.Keymap
function _G.bufMap(map)
        map.buf = 0
        smartMap(map)
end

---@param text string
---@param replace string
function _G.bufAbbr(text, replace) bufAbbr(text, replace) end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param f string | function
function _G.q(f) q(f) end

---@param key string | table<string, vim.api.keyset.events>
function _G.req(key) return req(key) end

---@param modname string
function _G.safeRequire(modname) safeRequire(modname) end

---@param modname string
---@param event? vim.api.keyset.events | vim.api.keyset.events[]
---@param pattern? string | table
function _G.safeRequireLazy(modname, event, pattern) safeRequireLazy(modname, event, pattern) end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param group string | integer
---@param buf? integer
function _G.emit(group, buf) emit(group, buf) end
