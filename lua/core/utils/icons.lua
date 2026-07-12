local function isLoaded(iconProvider)
        local loaded, _ = pcall(require, iconProvider)

        return loaded
end

local function makeIcon(provider, category, type)
        local _, module = pcall(require, provider)

        if isLoaded(provider) then
                local segment = module.segment(category, type)
                local text    = segment.text
                local hl      = segment.hl

                return { text, hl }
        end
end

local function renderIcon(bufnr, row, col, icon)
        local _, module = pcall(require, "real-icons")

        if isLoaded("real-icons") then
                module.render(bufnr, row, col, icon)
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param provider string
---@param category string
---@param type string
---@return table<string, string>
function M.makeIcon(provider, category, type)
        return makeIcon(provider, category, type)
end

function M.renderIcon(bufnr, row, col, icon)
        renderIcon(bufnr, row, col, icon)
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
