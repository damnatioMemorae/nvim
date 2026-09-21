local function p(pair)
        return function(neighPattern)
                return function(action, cr)
                        cr = cr or true
                        return { action = action, pair = pair, neigh_pattern = neighPattern, register = { cr = cr } }
                end
        end
end

return {
        "nvim-mini/mini.pairs",
        event   = "InsertEnter",
        version = false,
        opts    = {
                modes    = { insert = true, command = false, terminal = false },
                mappings = {
                        ["{"] = p "{}" "^[^\\]" "open",
                        ["}"] = p "{}" "^[^\\]" "close",
                        ["("] = p "()" "^[^\\]" "open",
                        [")"] = p "()" "^[^\\]" "close",
                        ["["] = p "[]" "^[^\\]" "open",
                        ["]"] = p "[]" "^[^\\]" "close",
                        ["<"] = p "<>" "^[^\\]" "open",
                        [">"] = p "<>" "^[^\\]" "close",
                        ['"'] = p '""' "^[^\\]" ("closeopen", false),
                        ["'"] = p "''" "^[^%a\\]" ("closeopen", false),
                        ["`"] = p "``" "^[^\\]" ("closeopen", false),
                },
        },
}
