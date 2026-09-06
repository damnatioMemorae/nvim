---- PREDICATES ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local eq   = function(a) return function(b) return a == b end end
local typq = function(a) return function(t) return type(a) == t end end

local nilq = function(_) return _ == nil end
local tblq = function(_) return type(_) == "table" end
local strq = function(_) return type(_) == "string" end
local numq = function(_) return type(_) == "number" end
local booq = function(_) return type(_) == "boolean" end
local funq = function(_) return type(_) == "function" end

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

local _gt    = function() return function(a) return function(_) return _ > a end end end
local _lt    = function() return function(a) return function(_) return _ < a end end end
local _eq    = function() return function(a) return function(_) return _ == a end end end
local _neq   = function() return function(a) return function(_) return _ ~= a end end end
local _gtq   = function() return function(a) return function(_) return _ >= a end end end
local _ltq   = function() return function(a) return function(_) return _ <= a end end end
local _lower = function() return function(_) return _:lower() end end
local _upper = function() return function(_) return _:upper() end end

local function matches(value, pattern)
        if type(pattern) == "function" then
                return value == pattern(value)
        end
        if type(pattern) == "table" then
                for _, candidate in ipairs(pattern) do
                        if matches(value, candidate) then
                                return true
                        end
                end
                return false
        end
        return value == pattern
end

local function execute(action, value)
        if type(action) == "function" then
                return action(value)
        end
        return action
end

---@type fun(value: any): fun(cases: table): any
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

---@type fun(expr: function): fun(bindings: table): function
local function where(expr)
        return function(bindings)
                return expr(bindings)
        end
end

local function unless(condition)
        return function(value)
                if not condition then return nil end
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

---@param pair { acc: table, val: any }
local function fold(pair)
        local acc     = pair[1]
        local val     = pair[2]
        acc[#acc + 1] = val
        return acc
end

---@type fun(f: function): fun(acc: table): fun(tbl: table): function
local function foldl(f)
        return function(acc)
                return function(tbl)
                        local function doStuff(i, _acc)
                                unless(i > #tbl)(_acc)
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
                        unless(nilq(head))(tail)
                        return head .. sep .. tail
                end
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

M.combinator   = {
        revq    = revq,
        curry   = curry,
        uncurry = uncurry,
}
M.predicates   = {
        eq    = eq,
        typq  = typq,
        nilq  = nilq,
        tblq  = tblq,
        numq  = numq,
        strq  = strq,
        booq  = booq,
        funq  = funq,
        _eq   = not eq,
        _typq = not typq,
        _nilq = not nilq,
        _tblq = not tblq,
        _numq = not numq,
        _strq = not strq,
        _booq = not booq,
        _funq = not funq,
}
M.lists        = {
        extl   = extl,
        map    = map,
        mapl   = mapl,
        fold   = fold,
        foldl  = foldl,
        concat = concat,
}
M.matching     = {
        _gt    = _gt,
        _lt    = _lt,
        _eq    = _eq,
        _neq   = _neq,
        _lower = _lower,
        _upper = _upper,
}
M.conditionals = {
        guard  = guard,
        match  = match,
        where  = where,
        unless = unless,
}

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
