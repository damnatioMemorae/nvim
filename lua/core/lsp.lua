local o   = vim.o
local wo  = vim.wo
local bo  = vim.bo
local opt = vim.opt

local fn  = vim.fn
local api = vim.api
local lsp = vim.lsp

---- DIAGNOSTICS ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local hl       = "DiagnosticVirtualText"
local diag     = vim.diagnostic
local severity = diag.severity
local signs    = {
        text  = {
                [severity.ERROR] = "",
                [severity.WARN]  = "",
                [severity.INFO]  = "",
                [severity.HINT]  = "",
        },
        numhl = {
                [severity.ERROR] = hl .. "Error",
                [severity.WARN]  = hl .. "Warn",
                [severity.INFO]  = hl .. "Info",
                [severity.HINT]  = hl .. "Hint",
        },
}

diag.config({
        signs            = signs,
        virtual_text     = { source = false, current_line = nil },
        update_in_insert = false,
        severity_sort    = true,
})

---- HANDLERS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local OriginalRenameHandler         = lsp.handlers["textDocument/rename"]
lsp.handlers["textDocument/rename"] = function(err, result, ctx, config)
        OriginalRenameHandler(err, result, ctx, config)
        if err or not result then
                return
        end

        local changed_files, change_count = {}, 0
        if result.changes then
                changed_files = vim
                           .iter(vim.tbl_keys(result.changes))
                           :map(function(uri)
                                   return "- " .. vim.fs.basename(vim.uri_to_fname(uri))
                           end)
                           :totable()
                change_count  = vim
                           .iter(result.changes)
                           :fold(0, function(sum, _, ch)
                                   return sum + #(ch.edits or ch)
                           end)
        elseif result.documentChanges then
                changed_files = vim
                           .iter(result.documentChanges)
                           :map(function(file)
                                   local uri   = file.textDocument and file.textDocument.uri or file.newUri
                                   local extra = file.kind == "rename" and " (renamed)" or ""
                                   return "* " .. vim.fs.basename(vim.uri_to_fname(uri)) .. extra
                           end)
                           :totable()
                change_count  = vim
                           .iter(result.documentChanges)
                           :fold(0, function(sum, ch)
                                   return sum + (ch.edits and #ch.edits or 1)
                           end)
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

local border      = Border.Default.Normal
local title       = ""
local title_pos   = "left"
local anchor_bias = "above"
local relative    = "cursor"
local wrap        = true
local max_height  = math.floor(o.lines * 0.7)
local max_width   = math.floor(o.columns * 0.6)

local hover   = lsp.buf.hover
lsp.buf.hover = function() ---@diagnostic disable-line: duplicate-set-field
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

local signature_help   = lsp.buf.signature_help
lsp.buf.signature_help = function() ---@diagnostic disable-line: duplicate-set-field
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

local open_float = diag.open_float
diag.open_float  = function() ---@diagnostic disable-line: duplicate-set-field
        return open_float{
                title_pos     = "left",
                title         = "",
                border        = Border.Default.Normal,
                scope         = "cursor",
                severity_sort = true,
                source        = true,
        }
end

---- AUTOCMDS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local debounce = 100
local timer    = vim.uv.new_timer()
local autocmd  = api.nvim_create_autocmd
local augroup  = api.nvim_create_augroup

local _hint_augroup    = augroup("lsp-inlay-hint", { clear = false })
local _lsp_augroup     = augroup("LSP", { clear = true })
local _doc_augroup     = augroup("LSP document highlight", { clear = true })
local _col_augroup     = augroup("LSP document color", { clear = true })
local _comp_augroup    = augroup("LSP completion", { clear = true })
local _compdoc_augroup = augroup("LSP completion doc", { clear = true })
local _detatch_augroup = augroup("LSP detatch", { clear = true })

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local F = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function compDoc(client, _group, bufnr)
        if not timer then
                vim.notify("Cannot create timer", vim.log.levels.ERROR)
        end

        autocmd("CompleteChanged", {
                desc     = "LSP completion documentation",
                buffer   = bufnr,
                group    = _comp_augroup,
                callback = function()
                        timer:stop()

                        local client_id = vim.tbl_get(vim.v.completed_item, "user_data", "nvim", "lsp", "client_id")
                        if client_id ~= client.id then
                                return
                        end

                        local completion_item = vim.tbl_get(vim.v.completed_item, "user_data", "nvim", "lsp",
                                                            "completion_item")
                        if not completion_item then
                                return
                        end

                        local complete_info = fn.complete_info({ "selected" })
                        if vim.tbl_isempty(complete_info) then
                                return
                        end

                        timer:start(debounce, 0, vim.schedule_wrap(function()
                                client:request(
                                        lsp.protocol.Methods.completionItem_resolve,
                                        completion_item,
                                        function(err, result)
                                                if err ~= nil then
                                                        -- vim.notify("client" .. " " .. client.id .. vim.inspect(err),
                                                        --            vim.log.levels.ERROR)
                                                        return
                                                end

                                                local docs = vim.tbl_get(result, "documentation", "value")
                                                if not docs then
                                                        return
                                                end

                                                local wininfo = api.nvim__complete_set(complete_info.selected,
                                                                                       { info = docs })
                                                if vim.tbl_isempty(wininfo) or not api.nvim_win_is_valid(wininfo.winid) then
                                                        return
                                                end

                                                api.nvim_win_set_config(wininfo.winid, { border = "single" })
                                                wo[wininfo.winid].conceallevel  = 2
                                                wo[wininfo.winid].concealcursor = "niv"
                                                wo[wininfo.winid].winhighlight  = "PmenuDoc:Normal"

                                                if not api.nvim_buf_is_valid(wininfo.bufnr) then
                                                        return
                                                end

                                                bo[wininfo.bufnr].syntax = "markdown"
                                                vim.treesitter.start(wininfo.bufnr, "markdown")
                                        end,
                                        bufnr
                                )
                        end)
                        )
                end,
        })
end

function F.completion(client, buf)
        if client:supports_method("textDocument/completion") and not pcall(require, "blink.cmp") then
                lsp.completion.enable(true, client.id, buf, {
                        autotrigger = false,
                        convert     = function(item)
                                return {
                                        abbr         = Icon.Kinds.Array .. " " .. item.label:gsub("%b()", ""),
                                        abbr_hlgroup = "LspKind" ..
                                                   (lsp.protocol.CompletionItemKind[item.kind] or ""),
                                        -- kind         = "",
                                        kind_hlgroup = "LspKind" ..
                                                   (lsp.protocol.CompletionItemKind[item.kind] or ""),
                                        menu         = "",
                                }
                        end,
                })

                compDoc(client, _compdoc_augroup, buf)

                opt.complete:append("o")
                o.autocomplete  = true
                o.completeopt   = "fuzzy,menuone,noinsert,noselect,popup"
                o.pummaxwidth   = 80
                o.complete      = "o,.,w,b,u"
                o.previewheight = 3
        end
end

function F.inlayHints(client, buf)
        if fn.has("nvim-0.10") == 1 and client:supports_method("textDocument/inlayHint") and vim.g.inlayHints then
                autocmd({ "CursorHold", "CursorMoved" }, {
                        desc     = "LSP inlay hints",
                        group    = _hint_augroup,
                        buffer   = buf,
                        callback = function() lsp.inlay_hint.enable(false) end,
                })
        end
end

function F.documentColor(client, buf)
        if fn.has("nvim-0.12") == 1 and client:supports_method("textDocument/documentColor") then
                autocmd({ "CursorHold", "CursorMoved" }, {
                        desc     = "LSP document color",
                        group    = _col_augroup,
                        buffer   = buf,
                        -- callback = function() lsp.document_color.enable(true, nil, { style = "background" }) end,
                        callback = function() lsp.document_color.enable(false) end,
                })
        end
end

function F.documentHighlight(client, buf)
        if fn.mode() ~= "i" and fn.has("nvim-0.11") == 1 and client:supports_method("textDocument/documentHighlight", 0) then
                autocmd({ "CursorMoved" }, {
                        desc     = "LSP Highlight symbol under cursor",
                        group    = _doc_augroup,
                        buffer   = buf,
                        callback = function()
                                lsp.buf.clear_references()
                                lsp.buf.document_highlight()
                        end,
                })
                autocmd({ "CursorMoved" }, {
                        desc     = "LSP Clear symbol highlight",
                        group    = _doc_augroup,
                        buffer   = buf,
                        callback = lsp.buf.clear_references,
                })
        end
end

local opts = {
        completion        = false,
        inlayHints        = false,
        documentColor     = true,
        documentHighlight = true,
}

autocmd("LspAttach", {
        desc     = "LSP stuff",
        group    = _lsp_augroup,
        callback = function(args)
                local buf    = args.buf
                local client = assert(lsp.get_client_by_id(args.data.client_id))

                vim.iter(opts)
                           :each(function(func, enabled)
                                   if enabled then
                                           F[func](client, buf)
                                   end
                           end)
        end,
})

autocmd("LspDetach", {
        desc     = "Stop LSP when no buffer",
        group    = _detatch_augroup,
        callback = function(args)
                local client = assert(lsp.get_client_by_id(args.data.client_id))

                if not client or not client.attached_buffers then
                        return
                end

                for bufnr in pairs(client.attached_buffers) do
                        if bufnr ~= args.buf then
                                return
                        end
                end
                client:stop()
        end,
})
