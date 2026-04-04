vim.api.nvim_set_hl(0, "SnacksNotifierBorderInfo",  { link = "DiagnosticInfo" })
vim.api.nvim_set_hl(0, "SnacksNotifierBorderWarn",  { link = "DiagnosticWarn" })
vim.api.nvim_set_hl(0, "SnacksNotifierBorderError", { link = "DiagnosticError" })
vim.api.nvim_set_hl(0, "SnacksNotifierBorderTrace", { link = "FloatBorder" })
vim.api.nvim_set_hl(0, "SnacksNotifierBorderDebug", { link = "FloatBorder" })

vim.api.nvim_set_hl(0, "SnacksNotifierFooterInfo",  { link = "DiagnosticInfo" })
vim.api.nvim_set_hl(0, "SnacksNotifierFooterWarn",  { link = "DiagnosticWarn" })
vim.api.nvim_set_hl(0, "SnacksNotifierFooterError", { link = "DiagnosticError" })
vim.api.nvim_set_hl(0, "SnacksNotifierFooterTrace", { link = "NormalFloat" })
vim.api.nvim_set_hl(0, "SnacksNotifierFooterDebug", { link = "NormalFloat" })

vim.api.nvim_set_hl(0, "SnacksNotifierTitleInfo",  { link = "DiagnosticInfo" })
vim.api.nvim_set_hl(0, "SnacksNotifierTitleWarn",  { link = "DiagnosticWarn" })
vim.api.nvim_set_hl(0, "SnacksNotifierTitleError", { link = "DiagnosticError" })
vim.api.nvim_set_hl(0, "SnacksNotifierTitleDebug", { link = "NormalFloat" })
vim.api.nvim_set_hl(0, "SnacksNotifierTitleTrace", { link = "NormalFloat" })

vim.api.nvim_set_hl(0, "SnacksNotifierMinimal", { link = "DiagnosticWarn" })

---@param idx number|"last"
local function openNotif(idx)
        local max_width  = 0.85
        local max_height = 0.85

        if idx == "last" then idx = 1 end
        local history = Snacks.notifier.get_history{
                filter  = function(notif) return notif.level ~= "trace" end,
                reverse = true,
        }
        if #history == 0 then
                local msg = "No notifications yet."
                vim.notify(msg, vim.log.levels.TRACE, { title = "Last notification", icon = "󰎟" })
                return
        end
        local notif = assert(history[idx], "Notification not found.")
        Snacks.notifier.hide(notif.id)

        local lines = vim.split(notif.msg, "\n")
        local title = vim.trim((notif.icon or "") .. " " .. (notif.title or ""))

        local min_height   = 5
        local height       = math.min(#lines + 2, math.ceil(vim.o.lines * max_height))
        height             = math.max(height, min_height)
        local longest_line = vim.iter(lines):fold(0, function(acc, line)
                local len = #(line:gsub("\t", "    "))
                return math.max(acc, len)
        end)
        longest_line       = math.max(longest_line, #title)
        local width        = math.min(longest_line + 3, math.ceil(vim.o.columns * max_width))

        local overflow   = #lines + 2 - height
        local more_lines = overflow > 0 and ("↓ %d lines"):format(overflow) or ""
        local index_str  = ("(%d/%d)"):format(idx, #history)
        local footer     = vim.trim(index_str .. "   " .. more_lines)

        local level_capitalized = notif.level:gsub("^%l", string.upper)
        local highlights        = {
                "FloatBorder:SnacksNotifierBorder" .. level_capitalized,
                "FloatTitle:SnacksNotifierTitle" .. level_capitalized,
                "FloatFooter:SnacksNotifierFooter" .. level_capitalized,
                "NormalFloat:NormalFloat" .. level_capitalized,
        }
        local winhighlights     = table.concat(highlights, ",")

        local win = Snacks.win{
                text       = lines,
                height     = height,
                width      = width,
                title      = vim.trim(title) ~= "" and " " .. title .. " " or nil,
                footer     = footer and " " .. footer .. " " or nil,
                footer_pos = footer and "right" or nil,
                border     = Border.borderStyle,
                bo         = { ft = notif.ft or "markdown" },
                wo         = {
                        wrap         = notif.ft ~= "lua",
                        statuscolumn = " ",
                        cursorline   = true,
                        winfixbuf    = true,
                        fillchars    = "fold: ,eob: ",
                        foldmethod   = "expr",
                        foldexpr     = "v:lua.vim.treesitter.foldexpr()",
                        winhighlight = winhighlights,
                },
                keys       = {
                        ["<Tab>"]   = function()
                                if idx == #history then return end
                                vim.cmd.close()
                                openNotif(idx + 1)
                        end,
                        ["<S-Tab>"] = function()
                                if idx == 1 then return end
                                vim.cmd.close()
                                openNotif(idx - 1)
                        end,
                },
        }
        vim.api.nvim_win_call(win.win, function()
                vim.fn.matchadd("DiagnosticInfo", [[[^/]\+\.lua:\d\+\ze:]])
        end)
end

return {
        "folke/snacks.nvim",
        keys   = {
                -- { "<C-n>", function() Snacks.notifier.show_history() end, desc = "Notification History" },
                { "<C-n>", function() openNotif("last") end, desc = "󰎟 Last notification" },
                { "<leader><leader>n", function() Snacks.picker.notifications() end, desc = "󰎟 Notification history" },
                {
                        "<Esc>",
                        function()
                                Snacks.notifier.hide()
                                vim.snippet.stop()
                        end,
                        mode = { "n" },
                        desc = "Dismiss notice & exit snippet",
                },
        },
        opts   = {
                picker   = {
                        sources = {
                                notifications = {
                                        formatters = { severity = { level = false } },
                                        confirm    = function(picker)
                                                openNotif(picker:current().idx)
                                                picker:close()
                                        end,
                                },
                        },
                },
                notifier = {
                        icons   = Icons.Notifier,
                        sort    = { "added" },
                        enabled = true,
                        timeout = 2000,
                },
                styles   = {
                        notification_history = {
                                border   = Border.borderRight,
                                height   = 0.9,
                                width    = 0.9,
                                title    = "",
                                titlepos = "left",
                                fg       = "markdown",
                                bo       = { filetype = "Snacks.notif_history", modifiable = false },
                                wo       = { winhighlight = "Normal:SnacksNotifierHistory,FloatBorder:SnacksNotifierHistoryBorder" },
                        },
                        notification         = {
                                border  = Border.borderStyleNone,
                                wo      = { winblend = Config.blend },
                                icons   = Icons.Notifier,
                                enabled = true,
                                timeout = 2000,
                                style   = "minimal",
                        },
                },
        },
        config = function(_, opts)
                Snacks.setup(opts)
                vim.notify = function(msg, lvl, noti_opts) ---@diagnostic disable-line: duplicate-set-field
                        if type(msg) ~= "string" then msg = tostring(msg) end

                        local ignore = (msg == "No code actions available" and vim.bo.ft == "typescript")
                                   or msg:find("^Error executing vim.schedule.*/_folding_range.lua:%d+")
                        if ignore then return end

                        if vim.startswith(msg, "[nvim-treesitter/") then noti_opts = { id = "treesitter-update" } end
                        Snacks.notifier(msg, lvl, noti_opts)
                end
        end,
}
