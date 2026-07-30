local o    = vim.o
local bo   = vim.bo
local fn   = vim.fn
local api  = vim.api
local diag = vim.diagnostic
local loop = vim.loop

local function getIcon(category, type)
        return require("core.utils.icons").makeIcon("real-icons", type, category)
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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
                bo[props.buf].modified and { { "*", group = "Special" } } or {})
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
                                   return { "0" .. " ", group = "DiagnosticSign" .. severity }
                           end

                           return { count .. " ", group = "DiagnosticSign" .. severity }
                   end)
                   :totable()
end

local function macro()
        local rec  = fn.reg_recording()
        local icon = getIcon("extension", "bin")

        return { rec ~= "" and (icon[1] .. " ") or "", group = icon[2] }
end

local function render(props)
        return {
                { " " },
                { macro() },
                { path(props) },
                { diagnostics(props) },
                { ftType(props) },
                { ftName(props) },
                { " " },
        }
end

return {
        "b0o/incline.nvim",
        event        = "BufReadPost",
        dependencies = { "nvim-tree/nvim-web-devicons" },
        init         = function()
                o.laststatus = 0
                o.statusline = ""
        end,
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

                local timer = loop.new_timer()
                timer:start(0, 50, vim.schedule_wrap(function()
                        require("incline.manager").update({ refresh = true })
                end))
        end,
}
