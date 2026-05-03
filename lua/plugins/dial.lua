---@param increment boolean
---@param g? boolean
local function dial(increment, g)
        local mode      = vim.fn.mode(true)
        local is_visual = mode == "v" or mode == "V" or mode == "\22"
        local func      = (increment and "inc" or "dec") .. (g and "_g" or "_") .. (is_visual and "visual" or "normal")
        local group     = vim.g.dials_by_ft[vim.bo.filetype] or "default"
        return require("dial.map")[func](group)
end

return {
        "monaqa/dial.nvim",
        keys   = {
                { "<C-a>",  function() return dial(true) end,        expr = true, desc = "Increment", mode = { "n", "v" } },
                { "<C-x>",  function() return dial(false) end,       expr = true, desc = "Decrement", mode = { "n", "v" } },
                { "g<C-a>", function() return dial(true, true) end,  expr = true, desc = "Increment", mode = { "n", "v" } },
                { "g<C-x>", function() return dial(false, true) end, expr = true, desc = "Decrement", mode = { "n", "v" } },
                { "+",      function() return dial(true) end,        expr = true, desc = "Increment", mode = { "n", "v" } },
                { "-",      function() return dial(false) end,       expr = true, desc = "Decrement", mode = { "n", "v" } },
                { "g+",     function() return dial(true, true) end,  expr = true, desc = "Increment", mode = { "n", "v" } },
                { "g-",     function() return dial(false, true) end, expr = true, desc = "Decrement", mode = { "n", "v" } },
        },
        opts   = function()
                local augend = require("dial.augend")

                local ordinal_numbers            = augend.constant.new({
                        elements = { "first", "second", "third", "fourth", "fifth", "sixth", "seventh", "eighth", "ninth", "tenth" },
                        word     = false,
                        cyclic   = true,
                })
                local weekdays                   = augend.constant.new({
                        elements = { "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday" },
                        word     = true,
                        cyclic   = true,
                })
                local months                     = augend.constant.new({
                        elements = { "January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December" },
                        word     = true,
                        cyclic   = true,
                })
                local logical_alias              = augend.constant.new({ elements = { "&&", "||" }, word = false, cyclic = true })
                local yes_no                     = augend.constant.new({ elements = { "yes", "no" }, word = true, cyclic = true })
                local yes_no_capitalized         = augend.constant.new({ elements = { "Yes", "No" }, word = true, cyclic = true })
                local on_off                     = augend.constant.new({ elements = { "on", "off" }, word = true, cyclic = true })
                local on_off_capitalized         = augend.constant.new({ elements = { "On", "Off" }, word = true, cyclic = true })
                local enable_disable             = augend.constant.new({ elements = { "enable", "disable" }, word = true, cyclic = true })
                local enable_disable_capitalized = augend.constant.new({ elements = { "Enable", "Disable" }, word = true, cyclic = true })
                -- local case                         = augend.case.new({ types = { "camelCase", "PascalCase", "kebab-case", "snake_case", "SCREAMING_SNAKE_CASE" }, cyclic = true })

                return {
                        dials_by_ft = {
                                css             = "css",
                                javascript      = "typescript",
                                typescript      = "typescript",
                                typescriptreact = "typescript",
                                javascriptreact = "typescript",
                                json            = "json",
                                lua             = "lua",
                                markdown        = "markdown",
                                python          = "python",
                        },
                        groups      = {
                                default        = {
                                        augend.integer.alias.decimal,
                                        augend.integer.alias.decimal_int,
                                        augend.integer.alias.hex,
                                        augend.integer.alias.octal,
                                        augend.integer.alias.binary,
                                        augend.constant.alias.en_weekday,
                                        augend.constant.alias.en_weekday,
                                        augend.constant.alias.en_weekday_full,
                                        augend.constant.alias.bool,
                                        augend.constant.alias.Bool,
                                        augend.semver.alias.semver,
                                        augend.date.alias["%Y/%m/%d"],
                                        -- case,
                                        ordinal_numbers,
                                        weekdays,
                                        months,
                                        logical_alias,
                                        yes_no,
                                        yes_no_capitalized,
                                        on_off,
                                        on_off_capitalized,
                                        enable_disable,
                                        enable_disable_capitalized,
                                },
                                only_in_visual = {
                                        augend.constant.alias.alpha,
                                        augend.constant.alias.Alpha,
                                },
                                css            = {
                                        augend.hexcolor.new({
                                                case = "lower",
                                        }),
                                        augend.hexcolor.new({
                                                case = "upper",
                                        }),
                                },
                                markdown       = {
                                        augend.constant.new({
                                                elements = { "[ ]", "[x]" },
                                                word     = false,
                                                cyclic   = true,
                                        }),
                                        augend.misc.alias.markdown_header,
                                },
                                json           = {
                                        augend.semver.alias.semver,
                                },
                                lua            = {
                                        augend.constant.new({ elements = { "and", "or" }, word = true, cyclic = true }),
                                        augend.constant.new({ elements = { "==", "~=" }, word = false, cyclic = true }),
                                },
                                python         = {
                                        augend.constant.new({
                                                elements = { "and", "or" },
                                        }),
                                },
                        },
                }
        end,
        config = function(_, opts)
                for name, group in pairs(opts.groups) do
                        if name ~= "default" then
                                vim.list_extend(group, opts.groups.default)
                        end
                end
                require("dial.config").augends:register_group(opts.groups)
                vim.g.dials_by_ft = opts.dials_by_ft
        end,
}
