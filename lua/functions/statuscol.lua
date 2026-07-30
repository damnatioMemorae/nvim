local o  = vim.o
local v  = vim.v
local fn = vim.fn
local wo = vim.wo

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function numberLine()
        if v.virtnum ~= 0 then
                return "%="
        end

        if fn.foldclosed(v.lnum) == v.lnum then
                local line = fn.getline(v.lnum)

                if line:match("^%S") then
                        local count = fn.foldclosedend(v.lnum) - v.lnum + 1
                        local text  = tostring(count)
                        local pad   = (""):rep(math.max(0, wo.numberwidth - #text))
                        return "%#FoldText#%=" .. pad .. text .. "%#FoldText# "
                end
        end

        local num  = v.relnum > 0 and v.relnum or v.lnum
        local text = tostring(num)
        local pad  = (""):rep(math.max(0, wo.numberwidth - #text))

        return "%=" .. pad .. text .. " "
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function _G.render() return numberLine() end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

o.statuscolumn = "%s%{%v:lua.render()%}"
o.signcolumn   = "yes:1"
