local function isLoaded(iconProvider)
        local loaded, _ = pcall(require, iconProvider)

        return loaded
end

local function makeIcon(provider, type, category)
        local _, module = pcall(require, provider)

        if isLoaded(provider) and provider == "real-icons" then
                local segment = module.segment(category, type)
                local text    = segment.text
                local hl      = segment.hl

                return { text, hl }
        elseif isLoaded(provider) and provider == "nvim-web-devicons" then
                local segment = require"nvim-web-devicons".get_icon_color("*." .. type, type)
                local text    = segment.icon
                local hl      = segment.color

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
---@param type string
---@param category? string
---@return table<string, string>
function M.makeIcon(provider, type, category)
        return makeIcon(provider, type, category)
end

function M.renderIcon(bufnr, row, col, icon)
        renderIcon(bufnr, row, col, icon)
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
