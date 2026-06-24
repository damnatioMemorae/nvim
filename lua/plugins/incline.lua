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
                                InclineNormal   = { default = true, group = "LspInlayHint" },
                                InclineNormalNC = { default = true, group = "LspInlayHint" },
                        },
                },
                render             = function(props)
                        local loaded_d, devicons   = pcall(require, "nvim-web-devicons")
                        local loaded_r, real_icons = pcall(require, "real-icons")
                        local filename             = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")

                        local ft_icon  = (function()
                                if loaded_r then
                                        local render  = require("real-icons.render.placeholder")
                                        local icon    = real_icons.get(filename, { is_dir = false })
                                        local segment = render.segment(icon)

                                        return { segment.text, segment.hl }
                                elseif loaded_d then
                                        return { devicons.get_icon(filename) }
                                end
                        end)()
                        local dir_icon = (function()
                                if loaded_r then
                                        local render  = require("real-icons.render.placeholder")
                                        local icon    = real_icons.get(filename, { is_dir = true })
                                        local segment = render.segment(icon)

                                        return { segment.text, segment.hl }
                                else
                                        return { devicons.get_icon(filename) }
                                end
                        end)()

                        local function getDiff()
                                local signs = vim.b[props.buf].gitsigns_status_dict
                                if not signs then return {} end

                                return vim.iter({ { "added", "" }, { "changed", "" }, { "removed", "" } })
                                           :map(function(i)
                                                   local n = signs[i[1]]
                                                   return (n and n > 0) and {
                                                           n .. i[2] .. " ",
                                                           group = "Diff" .. i[1],
                                                   }
                                           end)
                                           :totable()
                        end

                        local function getPath()
                                local arrow = " " .. Icons.Arrows.rightBig .. " "
                                local parts = vim.split(vim.fn.fnamemodify(
                                                                vim.api.nvim_buf_get_name(props.buf), ":~:.:h"), "/")

                                return vim.iter(parts)
                                           :enumerate()
                                           :map(function(i, item)
                                                   return {
                                                           { dir_icon[1], group = dir_icon[2] },
                                                           { " " .. item, group = "Comment" },
                                                           {
                                                                   i < #parts and arrow or " ",
                                                                   group = "Comment",
                                                           },
                                                   }
                                           end)
                                           :totable()
                        end

                        local function getFt()
                                local label = { { vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t:r"), group = "Comment" } }

                                if vim.bo[props.buf].modified then
                                        label[#label + 1] = { "*", group = "Special" }
                                end

                                return label
                        end

                        local function getDiagnostic()
                                return vim.iter({ "error", "warn", "hint" })
                                           :map(function(severity)
                                                   local count = #vim.diagnostic.get(props.buf, {
                                                           severity = vim.diagnostic.severity[string.upper(severity)] })

                                                   return { count .. " ", group = "DiagnosticSign" .. severity }
                                           end)
                                           :totable()
                        end

                        local function breadCrumbs(source)
                                local ok, dropbar = pcall(require, "dropbar.sources")
                                if not ok or not props.focused then
                                        return {}
                                end
                                local arrow   = " " .. Icons.Arrows.rightBig .. " "
                                local symbols = dropbar[source].get_symbols(props.buf, 0, vim.api.nvim_win_get_cursor(0))

                                return vim.iter(symbols or {})
                                           :enumerate()
                                           :map(function(i, item)
                                                   return {
                                                           { item._.icon, group = item._.icon_hl },
                                                           { item._.name, group = item._.name_hl },
                                                           {
                                                                   i < #symbols and arrow or " ",
                                                                   group = "Comment",
                                                           },
                                                   }
                                           end)
                                           :totable()
                        end

                        return {
                                { " " },
                                { getPath() },
                                -- { breadCrumbs("lsp") },
                                { getDiagnostic() },
                                { ft_icon[1],     group = ft_icon[2] },
                                { " " },
                                { getFt() },
                                { " " },
                                -- { getDiff() },
                        }
                end,
        },
        config       = function(_, opts)
                require("incline").setup(opts)
        end,
}
