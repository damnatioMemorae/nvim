vim
           .iter(require("core.options"))
           :each(function(_, group)
                   vim
                              .iter(group)
                              :each(function(scope, opts)
                                      vim
                                                 .iter(opts)
                                                 :each(function(key, value)
                                                         if type(value) == "table" and value.when then
                                                                 if not value.when() then
                                                                         return
                                                                 end
                                                                 value = value.value
                                                         end

                                                         vim[scope][key] = value
                                                 end)
                              end)
           end)
