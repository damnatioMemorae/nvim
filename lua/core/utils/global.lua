local api     = vim.api
local set     = vim.keymap.set
local autocmd = api.nvim_create_autocmd

---- HIGHLIGHT -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function hlLink(groups, prefix)
        prefix = prefix or ""
        local function helper(_groups, _prefix)
                vim
                           .iter(_groups)
                           :each(function(group)
                                   api.nvim_set_hl(0, _prefix .. group[1], { link = group[2] })
                           end)
        end

        helper(groups, prefix)
        autocmd("ColorScheme", {
                callback = function() helper(groups, prefix) end,
        })
end

local function hlDyn(groups, prefix)
        prefix = prefix or ""
        local function helper(_groups, _prefix)
                vim
                           .iter(_groups)
                           :each(function(group)
                                   api.nvim_set_hl(0, _prefix .. group[1], group[2])
                           end)
        end

        helper(groups, prefix)
        autocmd("ColorScheme", {
                callback = function() helper(groups, prefix) end,
        })
end

---- KEYMAP --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local _repeat = { lhs = nil, buf = nil }

set("n", ".", function()
            local b = api.nvim_get_current_buf()
            if _repeat.lhs and _repeat.buf == b then
                    return api.nvim_feedkeys(
                            vim.keycode((vim.v.count > 0 and vim.v.count or "") .. _repeat.lhs), "m", false)
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
                        _repeat.lhs, _repeat.buf = lhs, api.nvim_get_current_buf()
                        return f(...)
                end or function()
                        _repeat.lhs, _repeat.buf = lhs, api.nvim_get_current_buf()
                        ---@cast f string
                        api.nvim_feedkeys(vim.keycode(f), "m", false)
                end
        end

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
                                     vim.notify(msg, vim.log.levels.WARN, { title = "Duplicate keymap", timeout = false })
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

---- LOAD ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function safeRequire(module)
        local success, errmsg = pcall(require, module)
        if success then return end

        local msg = ("Error loading `%s`: %s"):format(module, errmsg)
        vim.defer_fn(function()
                             vim.notify(msg, vim.log.levels.ERROR, { title = "User config", timeout = false })
                     end, 1000)
end

local function lazySafeRequire(module, event, pattern)
        if event then
                autocmd(event, {
                        pattern  = pattern or nil,
                        once     = true,
                        callback = function()
                                safeRequire(module)
                                vim.notify(module)
                        end,
                })
        else
                safeRequire(module)
                vim.notify(module)
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- EXPOSE
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param groups table<string, string>
---@param prefix? string
function _G.hlLink(groups, prefix)
        hlLink(groups, prefix)
end

---@param groups table<string, vim.api.keyset.highlight>
---@param prefix? string
function _G.hlDyn(groups, prefix)
        hlDyn(groups, prefix)
end

---@param module string
function _G.safeRequire(module)
        safeRequire(module)
end

---@param module string
---@param event? vim.api.keyset.events|vim.api.keyset.events[]
---@param pattern? (`string|array?`)
function _G.lazySafeRequire(module, event, pattern)
        lazySafeRequire(module, event, pattern)
end

---@class MyConfig.Keymap : vim.keymap.set.Opts
---@field [1] string
---@field [2] string|function
---@field mode? string|string[]
---@field ft? string|string[]
---@field dotmap? boolean

---@param map MyConfig.Keymap
function _G.smartMap(map)
        smartMap(map)
end

---@param map MyConfig.Keymap
function _G.bufMap(map)
        map.buf = 0
        smartMap(map)
end

---@param text string
---@param replace string
function _G.bufAbbr(text, replace)
        bufAbbr(text, replace)
end
