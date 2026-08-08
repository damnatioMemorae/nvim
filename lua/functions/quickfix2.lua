local o   = vim.o
local fn  = vim.fn
local api = vim.api
local cmd = vim.cmd

linq
"Qf"
           { "LineNr", "Special" }
           { "Match", "IncSearch" }
           { "Filename", "Directory" }

---- TEXT ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ns = api.nvim_create_namespace "qflist"

api.nvim_set_hl(0, "QfMatch", { link = "Removed", default = true })

local function getLines(ttt)
        local lines = {}
        for _, tt in ipairs(ttt) do
                local line = ""
                for _, t in ipairs(tt) do
                        line = line .. t[1]
                end
                table.insert(lines, line)
        end
        return lines
end

local function applyHighlights(bufnr, ttt)
        api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
        for i, tt in ipairs(ttt) do
                local col = 0
                for _, t in ipairs(tt) do
                        vim.hl.range(bufnr, ns, t[2], { i - 1, col }, { i - 1, col + #t[1] })
                        col = col + #t[1]
                end
        end
end

local type_hilights = {
        E = "DiagnosticSignError",
        W = "DiagnosticSignWarn",
        I = "DiagnosticSignInfo",
        N = "DiagnosticSignHint",
        H = "DiagnosticSignHint",
}

local function fileshorten(fname)
        if fn.isabsolutepath(fname) == 0 then
                return fname
        end
        local name = fn.fnamemodify(fname, ":.")
        if name == fname then
                name = fn.fnamemodify(name, ":~")
        end
        return name
end

function _G.qfText(info)
        local list
        local what = { id = info.id, items = 1, qfbufnr = 1 }
        if info.quickfix == 1 then
                list = fn.getqflist(what)
        else
                list = fn.getloclist(info.winid, what)
        end

        local ttt = {}
        for _, item in ipairs(list.items) do
                local tt = {}
                if item.bufnr == 0 then
                        table.insert(tt, { item.text, "QfText" })
                else
                        local fname = fn.bufname(item.bufnr)
                        fname = fileshorten(fname)
                        table.insert(tt, { fname, "QfFilename" })
                        if item.lnum > 0 then
                                table.insert(tt, { ":" .. item.lnum, "QfLineNr" })
                                table.insert(tt, { " ", "Default" })
                                local hl = type_hilights[item.type]
                                if hl then
                                        table.insert(tt, { item.text, hl })
                                elseif item.end_col ~= 0 and item.end_lnum == item.lnum then
                                        local matches = nil
                                        if item.user_data and type(item.user_data) == "table" then
                                                matches = item.user_data.matches
                                        end
                                        if not matches then
                                                if item.lnum and item.col and item.end_col then
                                                        if item.lnum > 0 and item.col > 0 and item.end_col > 0 then
                                                                matches = { { item.col, item.end_col } }
                                                        end
                                                end
                                        end
                                        local from = 1
                                        for _, m in ipairs(matches or {}) do
                                                table.insert(tt, { item.text:sub(from, m[1] - 1), "QfText" })
                                                table.insert(tt, { item.text:sub(m[1], m[2]), "QfMatch" })
                                                from = m[2] + 1
                                        end
                                        if from <= #item.text then
                                                table.insert(tt, { item.text:sub(from), "QfText" })
                                        end
                                else
                                        table.insert(tt, { item.text, type_hilights[item.type] or "QfText" })
                                end
                        end
                end
                table.insert(ttt, tt)
        end
        vim.schedule(function()
                applyHighlights(list.qfbufnr, ttt)
        end)
        return getLines(ttt)
end

o.quickfixtextfunc = "v:lua.qfText"

---- KEYMAPS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function pFile(kind)
        return pcmd(kind .. "Nfile")(kind .. "last")
end

local function nFile(kind)
        return pcmd(kind .. "nfile")(kind .. "first")
end

local function lprev(kind)
        return pcmd(kind .. "prev")(kind .. "last")
end

local function lnext(kind)
        return pcmd(kind .. "next")(kind .. "first")
end

local function filePrev() pcmd(pFile "l")(pFile "c") end
local function fileNext() pcmd(nFile "l")(nFile "c") end
local function itemPrev() pcmd(lprev "l")(lprev "c") end
local function itemNext() pcmd(lnext "l")(lnext "c") end
local function itemRm() pcmd(cmd.lexpr "[]")(cmd.cexpr "[]") end

local toggle = (function()
        local last = "qf"
        auq "CmdlineLeave" {
                callback = function()
                        match(fn.getreg ":") {
                                copen = function() last = "qf" end,
                                lopen = function() last = "ll" end,
                        }
                end,
        }
        return function()
                if fn.getqflist { winid = 1 }.winid ~= 0 then
                        return cmd.cclose()
                end
                if fn.getloclist(0, { winid = 1 }).winid ~= 0 then
                        return cmd.lclose()
                end

                if last == "ll" and #fn.getloclist(0) > 0 then
                        cmd.lopen()
                elseif #fn.getqflist() > 0 then
                        cmd.copen()
                elseif #fn.getloclist(0) > 0 then
                        cmd.lopen()
                end
        end
end)()

keyq { "[", filePrev, desc = "List file prev", unique = false }
keyq { "]", fileNext, desc = "List file next", unique = false }
keyq { "(", itemPrev, desc = "List item prev", unique = false }
keyq { ")", itemNext, desc = "List item next", unique = false }
keyq { "qr", itemRm, desc = "List remove", unique = true }
keyq { "qq", "<cmd>silent cfirst<CR>zv<cmd>wincmd p<CR>", desc = "List 1st", ft = "qf" }
keyq { "Q", "<cmd>silent clast<CR>zv<cmd>wincmd p<CR>", desc = "List last", ft = "qf" }
keyq { "<leader>q", toggle, desc = "List toggle" }
