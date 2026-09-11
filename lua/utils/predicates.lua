return {
        gt    = function(b) return function(a) return a > b and b end end,
        lt    = function(b) return function(a) return a < b and b end end,
        eq    = function(b) return function(a) return a == b and b end end,
        neq   = function(b) return function(a) return a ~= b and b end end,
        gtq   = function(b) return function(a) return a >= b and b end end,
        ltq   = function(b) return function(a) return a <= b and b end end,
        lower = function(_) return _:lower() end,
        upper = function(_) return _:upper() end,
        nilq  = function(_) return _ ~= nil and _ end,
        self  = function(_) return _ end,
}
