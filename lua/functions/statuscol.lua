local function numberLine()
        local v = vim.v

        if v.virtnum ~= 0 then
                return "%="
        end

        local lnum     = v.relnum > 0 and v.relnum or v.lnum
        local lnum_str = tostring(lnum)
        local pad      = (""):rep(vim.wo.numberwidth - #lnum_str)

        return "%=" .. pad .. lnum_str .. " "
end

function _G.render()
        if vim.bo[0].buftype == "quickfix" then
                return numberLine()
        end

        return numberLine()
end

vim.o.statuscolumn = "%s%{%v:lua.render()%}"
