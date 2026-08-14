local fn   = vim.fn
local uv   = vim.uv
local api  = vim.api
local lsp  = vim.lsp
local diag = vim.diagnostic

local hl   = "DiagnosticHint"
local icon = Icon.Misc.lightbulb

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

fn.sign_define("CodeAction", {
        text   = icon,
        texthl = "CodeActionSign",
})

_linq(hl) "CodeActionSign"

local function clear(bufnr)
        if api.nvim_buf_is_valid(bufnr) then
                fn.sign_unplace("CodeAction", { buffer = bufnr })
        end
end

local function update(bufnr, lnum)
        if not api.nvim_buf_is_valid(bufnr) then return end
        clear(bufnr)

        local line   = api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
        local params = {
                textDocument = lsp.util.make_text_document_params(),
                context      = { diagnostics = diag.get(bufnr, { lnum = lnum - 1 }) },
                range        = {
                        start   = { line = lnum - 1, character = 0 },
                        ["end"] = { line = lnum - 1, character = #line },
                },
        }

        lsp.buf_request_all(bufnr, "textDocument/codeAction", params, function(responses)
                vim.schedule(function()
                        if not api.nvim_buf_is_valid(bufnr) then return end
                        if bufnr ~= api.nvim_get_current_buf() then return end

                        local current_lnum = api.nvim_win_get_cursor(0)[1]
                        if current_lnum ~= lnum then return end

                        for _, response in pairs(responses) do
                                if response.result and #response.result > 0 then
                                        fn.sign_place(0, "CodeAction", "CodeAction", bufnr,
                                                      { lnum = lnum, priority = 4000 })
                                        return
                                end
                        end
                end)
        end)
end

local timer = uv.new_timer()
local function debounce(bufnr, lnum)
        ---@cast timer uv.uv_timer_t
        timer:stop()
        timer:start(50, 0, function()
                vim.schedule(function() update(bufnr, lnum) end)
        end)
end

auq "CursorMoved" { callback = function(args) debounce(args.buf, api.nvim_win_get_cursor(0)[1]) end }
auq "DiagnosticChanged" { callback = function(args)
        if args.buf ~= api.nvim_get_current_buf() then return end
        debounce(args.buf, api.nvim_win_get_cursor(0)[1])
end }
auq "BufLeave" { callback = function(args) clear(args.buf) end }
