local function numberLine()
        if vim.v.virtnum ~= 0 then
                return "%="
        end

        if vim.fn.foldclosed(vim.v.lnum) == vim.v.lnum then
                local line = vim.fn.getline(vim.v.lnum)

                if line:match("^%S") then
                        local count = vim.fn.foldclosedend(vim.v.lnum) - vim.v.lnum + 1
                        local text  = tostring(count)
                        local pad   = (""):rep(math.max(0, vim.wo.numberwidth - #text))
                        return "%#FoldNumber#%=" .. pad .. text .. "%#FoldNumber# "
                end
        end

        local num  = vim.v.relnum > 0 and vim.v.relnum or vim.v.lnum
        local text = tostring(num)
        local pad  = (""):rep(math.max(0, vim.wo.numberwidth - #text))

        return "%=" .. pad .. text .. " "
end

function _G.render()
        return numberLine()
end

vim.o.statuscolumn = "%s%{%v:lua.render()%}"
vim.o.signcolumn   = "yes:1"
