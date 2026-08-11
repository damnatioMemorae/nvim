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
        numhl  = "",
        linehl = "",
})

_linq(hl) "CodeActionSign"

local function updateCodeActionSign(bufnr, lnum)
        fn.sign_unplace("CodeAction", { buffer = bufnr })

        local line   = api.nvim_buf_get_lines(bufnr, lnum - 1, lnum, false)[1] or ""
        local params = {
                textDocument = lsp.util.make_text_document_params(),
                range        = {
                        start   = { line = lnum - 1, character = 0 },
                        ["end"] = { line = lnum - 1, character = #line },
                },
                context      = {
                        diagnostics = diag.get(bufnr, { lnum = lnum - 1 }),
                        only        = nil,
                        triggerKind = 1,
                },
        }

        lsp.buf_request_all(bufnr, "textDocument/codeAction", params, function(responses)
                if not api.nvim_buf_is_valid(bufnr) then return end

                local has_action = false
                for _, response in pairs(responses) do
                        if response.result and #response.result > 0 then
                                has_action = true
                                break
                        end
                end

                if has_action then
                        fn.sign_place(0, "CodeAction", "CodeAction", bufnr, { lnum = lnum, priority = 4000 })
                end
        end
        )
end

local timer = uv.new_timer()

local function updateCodeActionSignDebounced(bufnr, lnum)
        ---@cast timer uv.uv_timer_t
        timer:stop()
        timer:start(50, 0, function()
                vim.schedule(function() updateCodeActionSign(bufnr, lnum) end)
        end)
end

auq { "CursorMoved", "DiagnosticChanged" } {
        callback = function(args)
                updateCodeActionSignDebounced(
                        args.buf,
                        api.nvim_win_get_cursor(0)[1]
                )
        end,
}
