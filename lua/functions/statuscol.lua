local o  = vim.o
local v  = vim.v
local fn = vim.fn

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function cnt()
        return fn.foldclosedend(v.lnum) - v.lnum + 1
end

local function num()
        return v.relnum > 0 and v.relnum or v.lnum
end

local function line()
        return fn.getline(v.lnum)
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function numberLine()
        if v.virtnum ~= 0 then return "%=" end

        if fn.foldclosed(v.lnum) == v.lnum then
                if line():match "^%S" then
                        local text = tostring(cnt())
                        return "%#FoldText#%=" .. text .. "%#FoldText# "
                end
        end

        local text = tostring(num())

        return "%=" .. text .. " "
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function _G.render() return numberLine() end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

o.statuscolumn = "%s%{%v:lua.render()%}"
o.signcolumn   = "yes:1"
