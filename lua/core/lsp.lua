---- DIAGNOSTISCS ------------------------------------------------------------------------------------------------------

local hl    = "DiagnosticVirtualText"
local signs = {
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
        signs            = signs,
        virtual_text     = { source = false, current_line = nil },
        update_in_insert = false,
        severity_sort    = true,
})

---- HANDLERS ----------------------------------------------------------------------------------------------------------

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
        local msg    = ("%d instance%s"):format(change_count, plural)
        if #changed_files > 1 then
                msg = ("%s in %d files\n%s"):format(msg, #changed_files, table.concat(changed_files, "\n"))
        end
        vim.notify(msg, vim.log.levels.WARN, { title = "Renamed with LSP", icon = Icons.Kinds.Parameter })

        if #changed_files > 1 then vim.cmd.wall() end
end

---- POPUP -------------------------------------------------------------------------------------------------------------

local title_pos   = "left"
local anchor_bias = "below"
local relative    = "cursor"
local wrap        = true
local max_height  = math.floor(vim.o.lines * 0.7)
local max_width   = math.floor(vim.o.columns * 0.6)
local border      = Border.borderStyle

local hover       = vim.lsp.buf.hover
---@diagnostic disable-next-line: duplicate-set-field
vim.lsp.buf.hover = function()
        return hover{
                border      = border,
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
                border      = border,
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
                title         = "",
                border        = Border.borderStyle,
                scope         = "cursor",
                severity_sort = true,
                source        = true,
        }
end
