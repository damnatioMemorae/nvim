local function merge(tbl)
        return vim
            .iter(tbl)
            :fold({ g = {}, o = {}, opt = {} }, function(acc, _, scope)
                    acc.g   = vim.tbl_extend("force", acc.g, scope.g or {})
                    acc.o   = vim.tbl_extend("force", acc.o, scope.o or {})
                    acc.opt = vim.tbl_extend("force", acc.opt, scope.opt or {})
                    return acc
            end)
end

vim
    .iter(merge(require "core.options"))
    :each(function(scope, opts)
            local target = vim[scope]
            vim
                .iter(opts)
                :each(function(k, v)
                        if type(v) == "table" and v.when then
                                if not v.when() then return end
                                v = v.value
                        end
                        target[k] = v
                end)
    end)
