---- FUNCITONS -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function curry(f, n)
        n = n or debug.getinfo(f, "u").nparams
        local function curried(args, count)
                return function(...)
                        local argc     = select("#", ...)
                        local new_args = { unpack(args) }
                        for i = 1, argc do
                                new_args[count + i] = select(i, ...)
                        end
                        local new_count = count + argc
                        if new_count >= n then
                                return f(unpack(new_args, 1, n))
                        end
                        return curried(new_args, new_count)
                end
        end
        return curried({}, 0)
end

local function uncurry(f)
        return function(...)
                local args = { ... }
                local result = f
                for i = 1, #args do
                        result = result(args[i])
                end
                return result
        end
end

local function revq(f, n)
        local function collect(args)
                return function(...)
                        local new_args = { unpack(args) }
                        for i = 1, select("#", ...) do
                                new_args[#new_args + 1] = select(i, ...)
                        end
                        if #new_args >= n then
                                local reversed = {}
                                for i = 1, n do
                                        reversed[i] = new_args[n - i + 1]
                                end
                                local result = f
                                for i = 1, n do
                                        result = result(reversed[i])
                                end
                                return result
                        end
                        return collect(new_args)
                end
        end
        return collect {}
end

---- PATTERN MATCHING ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param f function|any
---@param ... any
local function thunk(f, ...)
        if type(f) ~= "function" then
                return function() return f end
        end
        local args = { ... }
        return function() return f(unpack(args)) end
end

---@param value any
---@param pattern any
local function matches(value, pattern)
        -- if type(pattern) == "function" then
        --         return pattern(value)
        -- end
        if type(pattern) == "function" then return value == pattern(value) end
        if type(pattern) == "table" then
                for _, candidate in ipairs(pattern) do
                        if matches(value, candidate) then return true end
                end
                return false
        end
        return value == pattern
end

---@param action function
---@param value any
local function execute(action, value)
        if type(action) == "function" then return action(value) end
        return action
end

---@alias MatchAction any|fun(value: any): any
---@alias MatchCases table<any, MatchAction>
---@param value any
---@return fun(cases: MatchCases): any
local function match(value)
        return function(cases)
                for pattern, action in pairs(cases) do
                        if pattern ~= "_" and matches(value, pattern) then
                                return execute(action, value)
                        end
                end
                if cases._ ~= nil then
                        return execute(cases._, value)
                end
                return nil
        end
end

---- CONDITIONALS --------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function cond()

end

local function guard(args)
        local n = #args
        assert(n > 0, "cond requires at least one argument")
        for i = 1, n - (n % 2), 2 do
                assert(type(args[i + 1]) == "function", "cond action must be a function")
                if args[i] then return args[i + 1]() end
        end
        if n % 2 == 1 then
                assert(type(args[n]) == "function", "cond otherwise must be a function")
                return args[n]()
        end
end

local function when(condition)
        return function(value)
                if not condition then return end
                return type(value) == "function" and value() or value
        end
end

local function unless(condition)
        return function(value)
                if condition then return end
                return type(value) == "function" and value() or value
        end
end

---- LISTS ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@type fun(t1: table): fun(t2: table): table
local function extl(dst)
        return function(src)
                for i = 1, #src do
                        table.insert(dst, src[i])
                end
                return dst
        end
end

---@param acc table
---@param val any
local function fold(acc, val)
        local new_acc = acc
        new_acc[#new_acc + 1] = val
        return new_acc
end

---@type fun(f: function): fun(acc: table): fun(tbl: table): function
local function foldl(f)
        return function(acc)
                return function(tbl)
                        local function doStuff(i, _acc)
                                when(i > #tbl)(_acc)
                                return doStuff(i + 1, f(_acc)(tbl[i]))
                        end
                        return doStuff(1, acc)
                end
        end
end

---@type fun(f: function): fun(tbl: table): table
local function map(f)
        local res = {}
        return function(t)
                for k, v in pairs(t) do
                        res[k] = f(v)
                end
                return res
        end
end

---@type fun(f: function): fun(tbl: table): table
local function mapl(f)
        local res = {}
        return function(t)
                for i = 1, #t do
                        res[i] = f(t[i])
                end
                return res
        end
end

---- OPERATORS -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@type fun(sep: string): fun(head: string): fun(tail: string): string
local function concat(sep)
        return function(head)
                return function(tail)
                        when(head == nil)(tail)
                        return head .. sep .. tail
                end
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

M.currying     = {
        revq    = revq,
        curry   = curry,
        uncurry = uncurry,
}
M.lists        = {
        extl   = extl,
        map    = map,
        mapl   = mapl,
        fold   = fold,
        foldl  = foldl,
        concat = concat,
}
M.conditionals = {
        when   = when,
        unless = unless,
        guard  = guard,
        cond   = cond,
}
M.combinator   = {
        K = function(x) return function(...) return x end end, ---@diagnostic disable-line: unused-vararg
        I = function(x) return x end,
}
M.predicates   = {
        gt    = function(x) return function(_) return _ > x and _ end end, ---@param x number
        lt    = function(x) return function(_) return _ < x and _ end end, ---@param x number
        eq    = function(x) return function(_) return _ == x and _ end end, ---@param x number
        neq   = function(x) return function(_) return _ ~= x and _ end end, ---@param x number
        gtq   = function(x) return function(_) return _ >= x and _ end end, ---@param x number
        ltq   = function(x) return function(_) return _ <= x and _ end end, ---@param x number
        andq  = function(p) return function(_) return p[1](_) and p[2](_) end end,
        _nilq = function(_) return _ ~= nil and _ end, ---@param _ any
        nilq  = function(_) return _ == nil and _ end, ---@param _ any
        self  = function(_) return _ end, ---@param _ any
        lower = function(_) return _:lower() end, ---@param _ string
        upper = function(_) return _:upper() end, ---@param _ string
}
M.matching     = {
        match = match,
        thunk = thunk,
}

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

setmetatable(M, {
        __call = function(self)
                for _, group in pairs(self) do
                        if type(group) == "table" then
                                for key, value in pairs(group) do
                                        -- rawset(_G, key, value)
                                        _G[key] = value
                                end
                        end
                end
        end,
})

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
