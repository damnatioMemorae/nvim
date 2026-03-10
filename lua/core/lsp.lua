------------------------------------------------------------------------------------------------------------------------
-- LSP SERVERS

local lsp_servers = {
        "asm_lsp",
        "bashls",
        "biome",
        "clangd",
        "cmake",
        "css_variables",
        "emmet",
        "emmet-language-server",
        "glslls",
        "gopls",
        "jsonls",
        "just-lsp",
        "jdtls",
        "kotlin_lsp",
        "lua_ls",
        "rust_analyzer",
        "superhtml",
        "ts_ls",
        "yamlls",
        -- "hover-ls",
}

vim.lsp.config("*", { root_markers = { ".git" } })

vim.lsp.enable(lsp_servers)

------------------------------------------------------------------------------------------------------------------------
-- DIAGNOSTICS

local hl      = "DiagnosticVirtualText"
local numbers = {
        text  = {
                [vim.diagnostic.severity.ERROR] = "",
                [vim.diagnostic.severity.WARN]  = "",
                [vim.diagnostic.severity.INFO]  = "",
                [vim.diagnostic.severity.HINT]  = "",
        },
        numhl = {
                [vim.diagnostic.severity.ERROR] = hl .. "Error",
                [vim.diagnostic.severity.WARN]  = hl .. "Warn",
                [vim.diagnostic.severity.INFO]  = hl .. "Info",
                [vim.diagnostic.severity.HINT]  = hl .. "Hint",
        },
}

vim.diagnostic.config({
        signs            = numbers,
        jump             = { float = false },
        virtual_text     = { source = false, current_line = nil },
        update_in_insert = false,
        severity_sort    = true,
})

------------------------------------------------------------------------------------------------------------------------
-- HANDLERS

local handlers = vim.lsp.handlers
local methods  = vim.lsp.protocol.Methods

local originalInlayHintHandler              = handlers[methods["textDocument_inlayHint"]]
handlers[methods["textDocument_inlayHint"]] = function(err, result, ctx, config)
        local client = vim.lsp.get_client_by_id(ctx.client_id)
        if client then
                local row, col = unpack(vim.api.nvim_win_get_cursor(0)) ---@diagnostic disable-line: unused-local
                result         = vim.iter(result):filter(function(hint)
                        return hint.position.line + 1 == row
                end):totable()
        end
        originalInlayHintHandler(err, result, ctx, config)
end


local originalRenameHandler              = handlers[methods["textDocument_rename"]]
handlers[methods["textDocument_rename"]] = function(err, result, ctx, config)
        originalRenameHandler(err, result, ctx, config)
        if err or not result then return end

        local changes       = result.changes or result.documentChanges or {}
        local changed_files = vim.iter(vim.tbl_keys(changes))
                   :filter(function(file) return #changes[file] > 0 end)
                   :map(function(file) return "- " .. vim.fs.basename(file) end)
                   :totable()
        local change_count  = 0
        for _, change in pairs(changes) do
                change_count = change_count + #(change.edits or change)
        end

        local plural = change_count > 1 and "s" or ""
        local msg    = ("[%d] instance%s"):format(change_count, plural)
        if #changed_files > 1 then
                msg = ("**%s in [%d] files**\n%s"):format(msg, #changed_files, table.concat(changed_files, "\n"))
        end
        vim.notify(msg, nil, { title = "Renamed with LSP", icon = Icons.Kinds.Parameter })

        if #changed_files > 1 then vim.cmd.wall() end
end

------------------------------------------------------------------------------------------------------------------------
-- POPUP

local title_pos   = "left"
local anchor_bias = "below"
local relative    = "cursor"
local wrap        = true
local max_height  = math.floor(vim.o.lines * 0.7)
local max_width   = math.floor(vim.o.columns * 0.6)

local hover       = vim.lsp.buf.hover
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.hover = function()
        return hover{
                border      = Border.borderStyle,
                -- title       = Icons.symbolKinds.Parameter .. " " .. "Hover",
                title       = "",
                title_pos   = title_pos,
                anchor_bias = anchor_bias,
                relative    = relative,
                wrap        = wrap,
                max_height  = max_height,
                max_width   = max_width,
        }
end

local signature_help       = vim.lsp.buf.signature_help
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.signature_help = function()
        return signature_help{
                border      = Border.borderStyle,
                -- title       = Icons.symbolKinds.Function .. " " .. "Signature Help",
                title       = "",
                title_pos   = title_pos,
                anchor_bias = anchor_bias,
                relative    = relative,
                wrap        = wrap,
                max_height  = max_height,
                max_width   = max_width,
        }
end

local float               = vim.diagnostic.open_float
---@diagnostic disable-next-line: duplicate-set-field
vim.diagnostic.open_float = function()
        return float{
                title_pos     = "left",
                -- title         = Icons.diagnostics.ERROR .. " " .. "Diagnostics",
                title         = "",
                border        = Border.borderStyle,
                scope         = "cursor",
                severity_sort = true,
                source        = true,
        }
end

------------------------------------------------------------------------------------------------------------------------
--[[ LSP PROGRESS

local progress = vim.defaulttable()
vim.api.nvim_create_autocmd("LspProgress", {
        callback = function(ev)
                local client = vim.lsp.get_client_by_id(ev.data.client_id)
                local value  = ev.data.params.value
                if not client or type(value) ~= "table" then
                        return
                end
                local p = progress[client.id]

                for i = 1, #p + 1 do
                        if i == #p + 1 or p[i].token == ev.data.params.token then
                                p[i] = {
                                        token = ev.data.params.token,
                                        msg   = ("[%3d%%] %s%s"):format(
                                                value.kind == "end" and 100 or value.percentage or 100,
                                                value.title or "",
                                                value.message and (" **%s**"):format(value.message) or ""
                                        ),
                                        done  = value.kind == "end",
                                }
                                break
                        end
                end

                local msg           = {}
                progress[client.id] = vim.tbl_filter(function(v) return table.insert(msg, v.msg) or not v.done end, p)

                local spinner = Spinner.dots

                vim.notify(table.concat(msg, "\n"), "info", { ---@diagnostic disable-line: param-type-mismatch
                        id    = "lsp_progress",
                        title = client.name,
                        opts  = function(notif)
                                notif.icon = #progress[client.id] == 0 and Icons.notifier.info
                                           or spinner[math.floor(vim.uv.hrtime() / (1e6 * 80)) % #spinner + 1]
                        end,
                })
        end,
})
--]]

--[[
vim.api.nvim_create_autocmd("LspProgress", {
        callback = function(ev)
                local value = ev.data.params.value or {}
                local msg   = value.message or "done"

                if #msg > 40 then
                        msg = msg:sub(1, 37) .. "..."
                end

                vim.api.nvim_echo({ { msg } }, false, {
                        id      = "lsp",
                        kind    = "progress",
                        title   = value.title,
                        status  = value.kind ~= "end" and "running" or "success",
                })
        end,
})
--]]
