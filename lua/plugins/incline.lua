return {
        "b0o/incline.nvim",
        event  = "BufReadPre",
        opts   = {
                window    = {
                        padding = 0,
                        margin  = { horizontal = 0 },
                        overlap = { winbar = true },
                },
                highlight = {
                        groups = {
                                InclineNormal   = { default = true, group = "LspInlayHint" },
                                InclineNormalNC = { default = true, group = "LspInlayHint" },
                        },
                },
                render    = function(props)
                        local devicons = require("nvim-web-devicons")
                        local filtype  = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t")
                        local filename = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(props.buf), ":t:r")

                        if filename == "" then
                                filename = "[No Name]"
                        end

                        local ft_icon, ft_color = devicons.get_icon_color(filtype)

                        local function getFt()
                                if vim.bo[props.buf].modified then
                                        return { { filename, group = "Comment" }, { "*" .. " ", group = "Special" } }
                                else
                                        return { filename .. " ", group = "Comment" }
                                end
                        end

                        local function getGitDiff()
                                local icons  = { removed = "", changed = "", added = "" }
                                local signs  = vim.b[props.buf].gitsigns_status_dict
                                local labels = {}

                                if signs == nil then
                                        return labels
                                end

                                for name, icon in pairs(icons) do
                                        if tonumber(signs[name]) and signs[name] > 0 then
                                                table.insert(labels,
                                                             { icon .. signs[name] .. " ", group = "Diff" .. name })
                                        end
                                end

                                if #labels > 0 then
                                        table.insert(labels, { "┊ " })
                                end

                                return labels
                        end

                        local function getDiagnostic()
                                local groups = { "error", "warn", "hint" }
                                local label  = {}

                                for _, severity in pairs(groups) do
                                        local count = #vim.diagnostic.get(props.buf, {
                                                severity = vim.diagnostic.severity[string.upper(severity)] })

                                        if count >= 0 then
                                                table.insert(label, {
                                                        count .. " ",
                                                        group = "DiagnosticSign" .. severity,
                                                })
                                        end
                                end

                                return label
                        end

                        local function lspStatus()
                                local label = {}
                                vim.api.nvim_create_autocmd("LspProgress", {
                                        callback = function(args)

                                        end,
                                })
                                return label
                        end

                        return {
                                { " " },
                                { getGitDiff() },
                                { getDiagnostic() },
                                -- { ft_icon .. " ",        guifg = ft_color },
                                { getFt() },
                                -- { filename .. " ", group = "Comment" },
                        }
                end,
        },
        config = function(_, opts)
                local incline = require("incline")
                incline.setup(opts)
        end,
}
