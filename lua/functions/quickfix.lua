local o   = vim.o
local fn  = vim.fn
local api = vim.api

---- HIGHLIGHTS ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

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

local function shortPath(path)
        local sep    = string.sub(package.config, 1, 1);
        local as_raw = { "nvim$" };

        local name = fn.fnamemodify(path, ":.")
        if name == path then
                name = fn.fnamemodify(name, ":~")
        end
        local function isRaw(str)
                for _, pattern in ipairs(as_raw) do
                        if string.match(str, pattern) then
                                return true;
                        end
                end
                return false;
        end

        local parts     = vim.split(name, sep, { trimempty = true });
        local shortened = {};
        for p, part in ipairs(parts) do
                if isRaw(part) or p == 1 or p == #parts then
                        table.insert(shortened, part);
                elseif string.match(part, "^%.") then
                        table.insert(shortened, fn.strcharpart(part, 0, 2));
                else
                        table.insert(shortened, fn.strcharpart(part, 0, 1));
                end
        end

        return table.concat(shortened, sep);
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
                local tt   = {}
                local text = item.text:gsub("^%s+", "")
                if item.bufnr == 0 then
                        table.insert(tt, { text, "QfText" })
                else
                        local prefix = item.type .. " "
                        local fname  = fn.bufname(item.bufnr)
                        fname        = shortPath(fname)
                        table.insert(tt, { prefix, type_hilights[item.type] })
                        table.insert(tt, { fname, "QfFilename" })
                        if item.lnum > 0 then
                                table.insert(tt, { ":" .. item.lnum, "QfLineNr" })
                                table.insert(tt, { " ", "Default" })
                                local hl = type_hilights[item.type]
                                if hl then
                                        table.insert(tt, { text, hl })
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
                                                table.insert(tt, { text:sub(from, m[1] - 1), "QfText" })
                                                table.insert(tt, { text:sub(m[1], m[2]), "QfMatch" })
                                                from = m[2] + 1
                                        end
                                        if from <= #item.text then
                                                table.insert(tt, { text:sub(from), "QfText" })
                                        end
                                else
                                        table.insert(tt, { text, type_hilights[item.type] or "QfText" })
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
