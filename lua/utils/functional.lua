---- PREDICATES ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local eq = function(a) return function(b) return a == b end end
local typq = function(a) return function(t) return type(a) == t end end

local nilq = function(a) return a == nil end
local tblq = function(a) return type(a) == "table" end
local strq = function(a) return type(a) == "string" end
local numq = function(a) return type(a) == "number" end
local booq = function(a) return type(a) == "boolean" end
local funq = function(a) return type(a) == "function" end

---- PATTERN MATCHING ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

---@type fun(value: any): fun(cases: table): function
function match(value)
        return function(cases)
                for pattern, action in pairs(cases) do
                        if pattern ~= "_" and type(pattern) == "string" then
                                if value == pattern then
                                        return execute(action, value)
                                end
                        end
                end
                for i = 1, #cases, 2 do
                        local pattern = cases[i]
                        local action  = cases[i + 1]
                        if matches(value, pattern) then
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

---@type fun(condition: any): fun(_then: function|any): fun(otherwise: function|any): function|any
local function when(condition)
        return function(_then)
                if condition then
                        return funq(_then)
                          and _then()
                          or _then
                end
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
                return funq(value) and value() or value
        end
end

---- LISTS ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function callIfNotEmpty(fun, stateX, ...)
        if stateX == nil then return nil end
        return stateX, fun(...)
end

local function each(fun, gen, param, state)
        repeat
                state = callIfNotEmpty(fun, gen(param, state))
        until state == nil
end

---@type fun(t1: table): fun(t2: table): table
local function extl(dst)
        return function(src)
                for i = 1, #src do
                        table.insert(dst, src[i])
                end
                return dst
        end
end

---@type fun(acc: table): fun(list: table): table
local function fold(acc)
        return function(list)
                local new_acc         = acc
                new_acc[#new_acc + 1] = list
                return new_acc
        end
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

---@type fun(tbl: table, pred: function): fun(acc: table): fun(x: any): table
local function filter(tbl, pred)
        return foldl(function(acc)
                return function(x)
                        unless(pred(x))(fold(acc))
                        return acc
                end
        end) {} (tbl)
end

---- OPERATORS -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@type fun(tbl: table): fun(idx: number): table|table
local function ext(tbl)
        return function(idx)
                return tbl[idx] or tbl
        end
end

---@type fun(tbl: table): fun(idx: number): table|nil
local function _ext(tbl)
        return function(idx)
                return tbl[idx] or nil
        end
end

---@type fun(sep: string): fun(head: string): fun(tail: string): string
local function concat(sep)
        return function(head)
                return function(tail)
                        unless(nilq(head))(tail)
                        return head .. sep .. tail
                end
        end
end

---- PIPELINES -----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function pipeline(...)
        local funs = { ... }
        return function(input)
                return foldl(function(x)
                        return function(f) return f(x) end
                end)(input)(funs)
        end
end

local function q(f)
        local function step(acc)
                return function(a)
                        unless(nilq(a))(acc)
                        f(a)
                        return step(fold(acc)) ---@diagnostic disable-line: param-type-mismatch
                end
        end
        return step {}
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
M.conditionals = { when = when, guard = guard, match = match, where = where, unless = unless, }
M.lists        = { map = map, mapl = mapl, each = each, extl = extl, fold = fold, foldl = foldl, filter = filter, }
M.operators    = { ext = ext, _ext = _ext, concat = concat, }
M.pipelines    = { q = q, pipeline = pipeline, }

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
