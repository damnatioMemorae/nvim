local fn  = vim.fn
local opt = vim.opt

local ignore_patterns = {
        "node_modules",
        "%.git",
        "%.cache",
        "dist",
        "build",
        "%.tmp",
        "%.log",
}

function _G.fuzzyFind(text, _)
        local files  = fn.glob("**/*", true, true)
        local result = {}
        for _, f in ipairs(files) do
                if fn.isdirectory(f) == 0 then
                        local skip = false
                        for _, pat in ipairs(ignore_patterns) do
                                if f:match(pat) then
                                        skip = true
                                        break
                                end
                        end
                        if not skip then
                                result[#result + 1] = f
                        end
                end
        end
        return fn.matchfuzzy(result, text)
end

opt.findfunc = [[v:lua.fuzzyFind]]
