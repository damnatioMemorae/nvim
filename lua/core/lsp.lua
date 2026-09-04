local g  = vim.g
local v  = vim.v
local o  = vim.o
local bo = vim.bo
local fn = vim.fn
local fs = vim.fs
local uv = vim.uv
local wo = vim.wo

local api  = vim.api
local cmd  = vim.cmd
local lsp  = vim.lsp
local log  = vim.log
local diag = vim.diagnostic
local ts   = vim.treesitter

local augroup = api.nvim_create_augroup
local levels  = log.levels

local nano = require "functions.nano-plugins"

---- DIAGNOSTICS ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local hl       = "DiagnosticVirtualText"
local severity = diag.severity
local signs    = {
        text  = { [severity.ERROR] = "", [severity.WARN] = "", [severity.INFO] = "", [severity.HINT] = "" },
        numhl = {
                [severity.ERROR] = hl .. "Error",
                [severity.WARN]  = hl .. "Warn",
                [severity.INFO]  = hl .. "Info",
                [severity.HINT]  = hl .. "Hint",
        },
}

diag.config {
        signs            = signs,
        virtual_text     = { source = false, current_line = nil },
        update_in_insert = false,
        severity_sort    = true,
}

---- HANDLERS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local OriginalRenameHandler         = lsp.handlers["textDocument/rename"]
lsp.handlers["textDocument/rename"] = function(err, result, ctx, config)
        OriginalRenameHandler(err, result, ctx, config)
        if err or not result then return end

        local changed_files, change_count = {}, 0
        if result.changes then
                changed_files = vim
                    .iter(vim.tbl_keys(result.changes))
                    :map(function(uri)
                            return "- " .. fs.basename(vim.uri_to_fname(uri))
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
                            return "* " .. fs.basename(vim.uri_to_fname(uri)) .. extra
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
        vim.notify(msg, levels.WARN, { title = "Renamed with LSP", icon = "󰑕" })

        if #changed_files > 1 then
                cmd "silent! wall"
        end
end

---- POPUP ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local hover          = lsp.buf.hover
local signature_help = lsp.buf.signature_help
local open_float     = diag.open_float
where(function(_)
        lsp.buf.hover          = function() return hover(_.hover) end ---@diagnostic disable-line: duplicate-set-field
        lsp.buf.signature_help = function() return signature_help(_.hover) end ---@diagnostic disable-line: duplicate-set-field
        diag.open_float        = function() return open_float(_.float) end ---@diagnostic disable-line: duplicate-set-field
end) {
            hover = {
                    anchor_bias = "above",
                    border      = Border.Default.Normal,
                    title       = "",
                    title_pos   = "left",
                    relative    = "cursor",
                    wrap        = true,
                    max_height  = math.floor(o.lines * 0.7),
                    max_width   = math.floor(o.columns * 0.6),
            },
            float = {
                    anchor_bias   = "below",
                    border        = Border.Default.Normal,
                    title         = "",
                    title_pos     = "left",
                    scope         = "cursor",
                    severity_sort = true,
                    source        = true,
            },
    }

---- AUTOCMDS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local timer = uv.new_timer()

local _lsp_augroup            = augroup("LSP", { clear = true })
local _hint_augroup           = augroup("lsp-inlay-hint", { clear = false })
local _doc_augroup            = augroup("LSP document highlight", { clear = true })
local _col_augroup            = augroup("LSP document color", { clear = true })
local _comp_augroup           = augroup("LSP completion", { clear = true })
local _compdoc_augroup        = augroup("LSP completion doc", { clear = true })
local _detatch_augroup        = augroup("LSP detatch", { clear = true })
local _on_type_format_augroup = augroup("LSP detatch", { clear = true })

local lsp_abbr_hl = {
        Enum       = "@enum",
        EnumMember = "@enum",
        Field      = "Identifier",
        Function   = "Function",
        Keyword    = "Keyword",
        Property   = "Identifier",
        Snippet    = "Keyword",
        Text       = "String",
        Variable   = "Label",
}
local lsp_kind_hl = {
        Enum       = "@enum",
        EnumMember = "String",
        Field      = "Identifier",
        Function   = "Function",
        Keyword    = "QfText",
        Property   = "Identifier",
        Snippet    = "QfText",
        Text       = "QfText",
        Variable   = "Label",
}

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function compDoc(client, _group, bufnr, debounce)
        if not timer then vim.notify("Cannot create timer", levels.ERROR) end
        auq "CompleteChanged" {
                desc     = "LSP completion documentation",
                buffer   = bufnr,
                group    = _comp_augroup,
                callback = function()
                        ---@cast timer uv.uv_timer_t
                        timer:stop()

                        local client_id = vim.tbl_get(v.completed_item, "user_data", "nvim", "lsp", "client_id")
                        if client_id ~= client.id then return end

                        local item = vim.tbl_get(v.completed_item, "user_data", "nvim", "lsp", "completion_item")
                        if not item then return end

                        local complete_info = fn.complete_info { "selected" }
                        if vim.tbl_isempty(complete_info) then return end

                        timer:start(debounce, 0, vim.schedule_wrap(function()
                                client:request(lsp.protocol.Methods.completionItem_resolve, item, function(err, result)
                                                       if err ~= nil then return end

                                                       local docs = vim.tbl_get(result, "documentation", "value")
                                                       if not docs then return end

                                                       local wininfo = api.nvim__complete_set(complete_info.selected,
                                                                                              { info = docs })

                                                       if vim.tbl_isempty(wininfo) or not api.nvim_win_is_valid(wininfo.winid) then
                                                               return
                                                       end

                                                       local doc_win = wininfo.winid
                                                       local doc_buf = wininfo.bufnr

                                                       api.nvim_win_set_config(doc_win, {
                                                               border = "single",
                                                               height = 15,
                                                               width  = 60,
                                                       })
                                                       wo[doc_win].wrap          = true
                                                       wo[doc_win].conceallevel  = 2
                                                       wo[doc_win].concealcursor = "niv"
                                                       wo[doc_win].winhighlight  = "Normal:PmenuDoc"
                                                       bo[doc_win].syntax        = "markdown"
                                                       ts.start(doc_buf, "markdown")
                                               end, bufnr)
                        end))
                end,
        }
end

local function completion(client, buf)
        if client:supports_method "textDocument/completion" and not pcall(require, "blink.cmp") then
                o.autocomplete  = true
                o.completeopt   = "fuzzy,menuone,noinsert,noselect,popup"
                o.pummaxwidth   = 80
                o.complete      = "o,.,w,b,u,f,t,i,d"
                o.previewheight = 3

                lsp.completion.enable(true, client.id, buf, {
                        autotrigger = false,
                        convert     = function(item)
                                return {
                                        abbr         = Icon.Kinds[lsp.protocol.CompletionItemKind[item.kind or "Text"]],
                                        abbr_hlgroup = lsp_abbr_hl[lsp.protocol.CompletionItemKind[item.kind or "Text"]],
                                        kind         = item.label:gsub("%b()", "") or "",
                                        kind_hlgroup = lsp_kind_hl[lsp.protocol.CompletionItemKind[item.kind or "Text"]],
                                        menu         = "",
                                }
                        end,
                })
                -- compDoc(client, _compdoc_augroup, buf, 0)
        end
end

local function inlayHints(client, buf)
        if fn.has "nvim-0.10" == 1 and g.inlayHints and client:supports_method "textDocument/inlayHint" then
                auq { "CursorHold", "CursorMoved" } {
                        desc     = "LSP inlay hints",
                        group    = _hint_augroup,
                        buffer   = buf,
                        callback = function() lsp.inlay_hint.enable(false) end,
                }
        end
end

local function documentColor(client, buf)
        if fn.has "nvim-0.12" == 1 and client:supports_method "textDocument/documentColor" then
                auq { "CursorHold", "CursorMoved" } {
                        desc     = "LSP document color",
                        group    = _col_augroup,
                        buffer   = buf,
                        -- callback = function() lsp.document_color.enable(true, nil, { style = "background" }) end,
                        callback = function() lsp.document_color.enable(false) end,
                }
        end
end

local function documentHighlight(client, buf)
        if fn.mode() ~= "i" and fn.has "nvim-0.11" == 1 and client:supports_method("textDocument/documentHighlight", 0) then
                auq "CursorMoved" {
                        desc     = "LSP Highlight symbol under cursor",
                        group    = _doc_augroup,
                        buffer   = buf,
                        callback = function()
                                ---@cast timer uv.uv_timer_t
                                timer:start(400, 0, vim.schedule_wrap(function()
                                        local pos  = api.nvim_win_get_cursor(0)
                                        -- local pos  = vim.pos.cursor(0)
                                        local node = ts.get_node { pos = { pos[1], pos[2] } }

                                        local in_string = false
                                        while node do
                                                if node:type() == "string" or node:type() == "string_content" then
                                                        in_string = true
                                                        break
                                                end
                                                node = node:parent()
                                        end

                                        lsp.buf.clear_references()

                                        if not in_string then
                                                lsp.buf.document_highlight()
                                        end
                                end))
                        end,
                }
        end
end

local function onTypeFormat(client, buf)
        if fn.has "nvim-0.11" == 1 and client:supports_method("textDocument/documentHighlight", 0) then
                auq "CursorMoved" {
                        desc     = "LSP format while typing",
                        group    = _on_type_format_augroup,
                        buffer   = buf,
                        callback = function()
                                lsp.on_type_formatting.enable(true, { lient_id = client })
                        end,
                }
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param client vim.lsp.Client
---@param buf (`number`) [<abuf>]
function M.completion(client, buf)
        completion(client, buf)
end

---@param client vim.lsp.Client
---@param buf (`number`) [<abuf>]
function M.inlayHints(client, buf)
        inlayHints(client, buf)
end

---@param client vim.lsp.Client
---@param buf (`number`) [<abuf>]
function M.documentColor(client, buf)
        documentColor(client, buf)
end

---@param client vim.lsp.Client
---@param buf (`number`) [<abuf>]
function M.documentHighlight(client, buf)
        documentHighlight(client, buf)
end

---@param client vim.lsp.Client
---@param buf (`number`) [<abuf>]
function M.onTypeFormat(client, buf)
        onTypeFormat(client, buf)
end

local opts = { completion = true, inlayHints = false, documentColor = true, documentHighlight = true }

auq "LspAttach" {
        desc     = "LSP stuff",
        group    = _lsp_augroup,
        callback = function(args)
                local buf    = args.buf
                local client = assert(lsp.get_client_by_id(args.data.client_id))

                vim
                    .iter(opts)
                    :each(function(func, enabled) if enabled then M[func](client, buf) end end)
        end,
}

auq "LspDetach" {
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
}

---- KEYMAPS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function jump(count)
        diag.jump { count = count, float = false }
end

local function lines()
        diag.config { virtual_lines = { current_line = true }, virtual_text = false }
        auq "CursorMoved" {
                group    = augroup("line-diagnostics", { clear = true }),
                callback = function()
                        diag.config { virtual_lines = false, virtual_text = false }
                        return true
                end,
        }
end

kq
""
    { "<leader>k", lines, desc = "Diagnostic Lines" }
    { "J", lsp.buf.signature_help, desc = "Signature Help" }
    { "K", lsp.buf.hover, desc = "Hover Documentation", unique = false }
    { "<M-D>", function() jump(-1) end, desc = "Diagnostic Prev", mode = { "n", "x" } }
    { "<M-d>", function() jump(1) end, desc = "Diagnostic Next", mode = { "n", "x" } }
    { "<M-j>", function() nano.scrollLspOrOtherWin(5) end, desc = "Scroll other win" }
    { "<M-k>", function() nano.scrollLspOrOtherWin(-5) end, desc = "Scroll other win" }
    { "<leader>d", diag.setloclist, desc = "Diagnostic loclist" }
    { "<leader>D", diag.setqflist, desc = "Diagnostic quickfix" }
    { "<LocalLeader>f", "gF", desc = ("LSP Goto ") .. "File" }
    { "<LocalLeader>D", lsp.buf.declaration, desc = "LSP Goto Declaration", unique = false }
    { "<LocalLeader>d", lsp.buf.definition, desc = "LSP Goto Definition", unique = false }
    { "<LocalLeader>r", lsp.buf.references, desc = "LSP Goto Reference", unique = false }
    { "<LocalLeader>i", lsp.buf.implementation, desc = "LSP Goto Implementation", unique = false }
    { "<LocalLeader>t", lsp.buf.type_definition, desc = "LSP Goto TypeDefinition", unique = false }
    { "<LocalLeader>a", lsp.buf.code_action, desc = "LSP Code Action", mode = { "n", "x" } }
    { "<LocalLeader>o", lsp.buf.document_symbol, desc = "LSP Symbols" }
    { "<LocalLeader>O", lsp.buf.workspace_symbol, desc = "LSP Symbols" }
