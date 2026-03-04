return {
        "echasnovski/mini.operators",
        enabled = false,
        keys    = {
                { "g", desc = "󰅪 Substitute Operator" }, -- in visual mode, `s` surrounds
                { "gw", mode = { "n", "x" }, desc = "󰅪 Multiply Operator" },
                { "gy", desc = "󰅪 Sort Operator" },
                { "gx", desc = "󰅪 Exchange Operator" },
                { "G", "s$", desc = "󰅪 Substitute to EoL", remap = true },
                { "gW", "w$", desc = "󰅪 Multiply to EoL", remap = true },
                { "gX", "sx$", desc = "󰅪 Exchange to EoL", remap = true },
        },
        opts    = {
                evaluate = { prefix = "" }, -- disable
                replace  = { prefix = "s", reindent_linewise = true },
                exchange = { prefix = "sx", reindent_linewise = true },
                sort     = { prefix = "sy" },
                multiply = {
                        prefix = "<C-w>",
                        func   = function(content)
                                -- IF LINEWISE, TRANSFORM 1ST LNE
                                if content.submode == "V" then
                                        local line = content.lines[1]
                                        local ft   = vim.bo.filetype

                                        if ft == "css" then
                                                if line:find("top:") then
                                                        line = line:gsub("top:", "bottom:")
                                                elseif line:find("bottom:") then
                                                        line = line:gsub("bottom:", "top:")
                                                end
                                                if line:find("right:") then
                                                        line = line:gsub("right:", "left:")
                                                elseif line:find("left:") then
                                                        line = line:gsub("left:", "right:")
                                                end
                                        elseif ft == "javascript" or ft == "typescript" then
                                                if line:find("^%s*if.+{$") then
                                                        line = line:gsub("^(%s*)if", "%1} else if")
                                                end
                                        elseif ft == "lua" then
                                                if line:find("^%s*if.+then%s*$") then
                                                        line = line:gsub("^(%s*)if", "%1elseif")
                                                end
                                        elseif ft == "sh" then
                                                if line:find("^%s*if.+then$") then line = line:gsub("^(%s*)if", "%1elif") end
                                        elseif ft == "python" then
                                                if line:find("^%s*if.+:$") then line = line:gsub("^(%s*)if", "%1elif") end
                                        end

                                        content.lines[1] = line
                                end

                                -- MOVE CURSOR TO VALUE
                                -- HACK: needs to work with `defer_fn`, since the transformer function is
                                -- called only *before* multiplication
                                local rowBefore = vim.api.nvim_win_get_cursor(0)[1]
                                vim.defer_fn(function()
                                                     local rowAfter       = vim.api.nvim_win_get_cursor(0)[1]
                                                     local line           = vim.api.nvim_get_current_line()
                                                     local _, valuePos    = line:find("[:=] %S")   -- find value
                                                     local _, _, fieldPos = line:find("@.-()%w+$") -- luadoc
                                                     local col            = fieldPos or valuePos
                                                     if rowBefore ~= rowAfter and col then
                                                             vim.api.nvim_win_set_cursor(0, { rowAfter, col - 1 })
                                                     end
                                             end, 1)

                                return content.lines
                        end,
                },
        },
}
