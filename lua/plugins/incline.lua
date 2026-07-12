local fn   = vim.fn
local api  = vim.api
local diag = vim.diagnostic

local function getIcon(category, type)
        return require("core.utils.icons").makeIcon("real-icons", category, type)
end

local function diff(props)
        local signs = vim.b[props.buf].minidiff_summary

        if not signs then
                return {}
        end

        return vim
                   .iter({ { "add", "+" }, { "change", "~" }, { "delete", "-" } })
                   :map(function(i)
                           local n = signs[i[1]]
                           return (n and n > 0) and { i[2] .. n .. " ", group = "Diff" .. i[1] }
                   end)
                   :totable()
end

local function path(props)
        local relhead = fn.fnamemodify(api.nvim_buf_get_name(props.buf), ":~:.:h")
        local arrow   = " " .. Icon.Arrows.rightBig .. " "
        local parts   = vim.split(relhead, "/")

        return vim
                   .iter(parts)
                   :enumerate()
                   :map(function(i, item)
                           return {
                                   {
                                           getIcon("directory", "general")[1],
                                           group = getIcon("directory", "general")[2],
                                   },
                                   { " " .. item, group = "Comment" },
                                   {
                                           i < #parts and arrow or " ",
                                           group = "Comment",
                                   },
                           }
                   end)
                   :totable()
end

local function ftName(props)
        local filename = fn.fnamemodify(api.nvim_buf_get_name(props.buf), ":t:r")

        return vim.list_extend(
                { { filename, group = "Comment" } },
                vim.bo[props.buf].modified and { { "*", group = "Special" } } or {})
end

local function ftType(props)
        local filetype = fn.fnamemodify(api.nvim_buf_get_name(props.buf), ":e")

        return { getIcon("extension", filetype)[1] .. " ", group = getIcon("extension", filetype)[2] }
end

local function diagnostics(props)
        return vim
                   .iter({ "error", "warn", "hint" })
                   :map(function(severity)
                           local count = #diag.get(props.buf, { severity = diag.severity[string.upper(severity)] })

                           if count == 0 then
                                   return { "-" .. " ", group = "DiagnosticSign" .. severity }
                           end

                           return { count .. " ", group = "DiagnosticSign" .. severity }
                   end)
                   :totable()
end

local function macro()
        local rec  = fn.reg_recording()
        local icon = getIcon("extension", "mcfunction")

        return { rec ~= "" and (icon[1] .. " ") or "", group = icon[2] }
end

local function render(props)
        return {
                { " " },
                { macro() },
                { path(props) },
                -- { diff(props) },
                { diagnostics(props) },
                { ftType(props) },
                { ftName(props) },
                { " " },
        }
end

return {
        "b0o/incline.nvim",
        event        = "BufReadPre",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        opts         = {
                debounce_threshold = 0,
                hide               = { only_win = false },
                window             = {
                        padding = 0,
                        margin  = { horizontal = 0 },
                        overlap = { winbar = true },
                        width   = "fit",
                },
                highlight          = {
                        groups = {
                                InclineNormal   = { default = true, group = "PmenuDoc" },
                                InclineNormalNC = { default = true, group = "PmenuDoc" },
                        },
                },
                render             = render,
        },
        config       = function(_, opts)
                require("incline").setup(opts)

                local timer = vim.loop.new_timer()
                timer:start(0, 50, vim.schedule_wrap(function()
                        require("incline.manager").update({ refresh = true })
                end))
        end,
}
