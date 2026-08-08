local function customMap(action)
        return function(txtobj)
                return function(line)
                        return function(sel)
                                where(function(_)
                                        require "mini.operators".make_mappings(action, _)
                                end) { textobject = txtobj, line = line, selection = sel }
                        end
                end
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

return {
        "nvim-mini/mini.operators",
        version = false,
        event   = "BufReadPost",
        opts    = {
                evaluate = { prefix = ",e" },
                replace  = { prefix = "", reindent_linewise = true },
                exchange = { prefix = "se", reindent_linewise = true },
                sort     = { prefix = "<LocalLeader>y" },
                -- multiply = { prefix = "w" },
        },
        config  = function(_, opts)
                local op = require "mini.operators"
                op.setup(opts)

                customMap "sort" "<LocalLeader>y" "<LocalLeader>yy" "<LocalLeader>y"
        end,
}
