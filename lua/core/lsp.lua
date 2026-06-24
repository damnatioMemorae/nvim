---- DIAGNOSTICS ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

---- HANDLERS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local OriginalRenameHandler             = vim.lsp.handlers["textDocument/rename"]
vim.lsp.handlers["textDocument/rename"] = function(err, result, ctx, config)
        OriginalRenameHandler(err, result, ctx, config)
        if err or not result then
                return
        end

        local changed_files, change_count = {}, 0
        if result.changes then
                changed_files = vim.iter(vim.tbl_keys(result.changes))
                           :map(function(uri) return "- " .. vim.fs.basename(vim.uri_to_fname(uri)) end)
                           :totable()
                change_count  = vim.iter(result.changes)
                           :fold(0, function(sum, _, ch) return sum + #(ch.edits or ch) end)
        elseif result.documentChanges then
                changed_files = vim.iter(result.documentChanges)
                           :map(function(file)
                                   local uri   = file.textDocument and file.textDocument.uri or file.newUri
                                   local extra = file.kind == "rename" and " (renamed)" or ""
                                   return "* " .. vim.fs.basename(vim.uri_to_fname(uri)) .. extra
                           end)
                           :totable()
                change_count  = vim.iter(result.documentChanges)
                           :fold(0, function(sum, ch) return sum + (ch.edits and #ch.edits or 1) end)
        end
        assert(change_count > 0, "Unknown form of changes reported by LSP.")

        local s   = change_count > 1 and "s" or ""
        local msg = ("[%d] change%s"):format(change_count, s)
        if #changed_files > 1 then
                local file_list = table.concat(changed_files, "\n")
                msg             = ("%s in [%d] files\n%s"):format(msg, #changed_files, file_list)
        end
        vim.notify(msg, vim.log.levels.WARN, { title = "Renamed with LSP", icon = "󰑕" })

        if #changed_files > 1 then
                vim.cmd("silent! wall")
        end
end

---- POPUP ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local border      = Border.borderStyle
local title       = ""
local title_pos   = "left"
local anchor_bias = "below"
local relative    = "cursor"
local wrap        = true
local max_height  = math.floor(vim.o.lines * 0.7)
local max_width   = math.floor(vim.o.columns * 0.6)

local hover       = vim.lsp.buf.hover
vim.lsp.buf.hover = function() ---@diagnostic disable-line: duplicate-set-field
        return hover{
                border      = border,
                title       = title,
                title_pos   = title_pos,
                anchor_bias = anchor_bias,
                relative    = relative,
                wrap        = wrap,
                max_height  = max_height,
                max_width   = max_width,
        }
end

local signature_help       = vim.lsp.buf.signature_help
vim.lsp.buf.signature_help = function() ---@diagnostic disable-line: duplicate-set-field
        return signature_help{
                border      = border,
                title       = title,
                title_pos   = title_pos,
                anchor_bias = anchor_bias,
                relative    = relative,
                wrap        = wrap,
                max_height  = max_height,
                max_width   = max_width,
        }
end

local float               = vim.diagnostic.open_float
vim.diagnostic.open_float = function() ---@diagnostic disable-line: duplicate-set-field
        return float{
                title_pos     = "left",
                title         = "",
                border        = Border.borderStyle,
                scope         = "cursor",
                severity_sort = true,
                source        = true,
        }
end
