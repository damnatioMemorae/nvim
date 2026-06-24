local function apply(spec)
        for _, group in pairs(spec) do
                for scope, opts in pairs(group) do
                        for k, v in pairs(opts) do
                                if type(v) == "table" and v.when then
                                        if v.when() then
                                                vim[scope][k] = v.value
                                        end
                                else
                                        vim[scope][k] = v
                                end
                        end
                end
        end
end
apply(require("core.options"))
