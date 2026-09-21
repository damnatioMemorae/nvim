local g    = vim.g
local o    = vim.o
local bo   = vim.bo
local fn   = vim.fn
local api  = vim.api
local cmd  = vim.cmd
local iter = vim.iter
g.mode     = "c"

local p = require "utils.functional".predicates
local T = require "utils.functional".matching.thunk

---- HIGHLIGHTS ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

linq
"Qf"
    { "LineNr", "String" }
    { "Match", "CurSearch" }
    { "Filename", "Directory" }

---- TEXT ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ns = api.nvim_create_namespace "QfList"

api.nvim_set_hl(0, "QfMatch", { link = "Removed", default = true })

local type_hilights = {
        E     = "DiagnosticSignError",
        W     = "DiagnosticSignWarn",
        I     = "DiagnosticSignInfo",
        N     = "DiagnosticSignHint",
        H     = "DiagnosticSignHint",
        error = "DiagnosticSignError",
}
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
local function shortPath(path)
        local sep    = string.sub(package.config, 1, 1);
        local as_raw = { "nvim$" };
        local fmod   = curry(fn.fnamemodify, 2)(path)
        local name   = match(fmod ":.") {
                [p.self] = T(fmod, ":~"),
                _        = T(),
        }
        local function isRaw(str)
                for _, pattern in ipairs(as_raw) do
                        if string.match(str, pattern) then
                                return true;
                        end
                end
                return false;
        end
        local parts     = vim.split(name, sep, { trimempty = true });
        local shortened = iter(parts)
            :enumerate()
            :map(function(_p, part)
                    return guard {
                            isRaw(part) or _p == 1 or _p == #parts, function() return part end,
                            string.match(part, "^%."), function() return fn.strcharpart(part, 0, 2) end,
                            function() return fn.strcharpart(part, 0, 1) end }
            end)
            :totable()
        return table.concat(shortened, sep);
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
o.quickfixtextfunc = function(info)
        local what = { id = info.id, items = 1, qfbufnr = 1 }
        local list = match(info.quickfix) {
                [1] = T(fn.getqflist, what),
                _   = T(fn.getloclist, info.winid, what),
        }
        local prep = function(_)
                local hl      = type_hilights[_.type]
                local col     = _.lnum > 0 and _.col .. "" or ""
                local text    = _.text:gsub("^%s+", "")
                local lnum    = _.lnum > 0 and _.lnum .. ":" or ""
                local prefix  = _.type ~= "" and _.type .. ":" or ""
                local bufname = fn.bufname(_.bufnr)
                local function curBuf(_)
                        return function() api.nvim_get_current_buf() end
                end
                local fname = _.lnum > 0 and match(_.bufnr) {
                        [curBuf()] = { "[" .. shortPath(bufname) .. "]:", "Special" },
                        _          = { shortPath(bufname) .. ":", type_hilights[_.type] or "QfFilename" },
                } or nil
                return {
                        { prefix, hl },
                        fname,
                        { lnum,   "QfLineNr" },
                        { col,    "QfLineNr" },
                        { " ",    "Default" },
                        { text,   "QfText" },
                }
        end

        local ttt = iter(list.items)
            :map(function(item) return prep(item) end)
            :totable()
        vim.schedule(function() applyHighlights(list.qfbufnr, ttt) end)
        return getLines(ttt)
end

---- KEYMAPS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local prefix = "silent " .. g.mode
local remove = function() cmd(g.mode .. "expr []") end
local older  = function() pcmd(prefix .. "older")() end
local newer  = function() pcmd(prefix .. "newer")() end
local first  = function()
        pcmd "lfirst" "cfirst"
        cmd "normal! zv"
        cmd "wincmd p"
end
local last   = function()
        pcmd "llast" "clast"
        cmd "normal! zv"
        cmd "wincmd p"
end
local qprev  = function(what)
        return function()
                pcmd(prefix .. what)(prefix .. "last")
                cmd "normal! zv"
        end
end
local qnext  = function(what)
        return function()
                pcmd(prefix .. what)(prefix .. "first")
                cmd "normal! zv"
        end
end
local toggle = function(key, h, w)
        local function perc(_) return function(__) return math.floor(o[_] * __ * 0.01) end end
        return function()
                local split    = match(key) {
                        [p.lower] = { "", "resize " .. perc "lines" (h or 50) },
                        [p.upper] = { "wincmd L", "vertical resize " .. perc "columns" (w or 50) },
                }
                local list_win = match(g.mode) {
                        c = function() return fn.getqflist { winid = true }.winid ~= 0 end,
                        l = function() return fn.getloclist(0, { winid = true }).winid ~= 0 end,
                }
                cmd(list_win and g.mode .. "close" or g.mode .. "open")
                match(bo.buftype) {
                        quickfix = function()
                                cmd(split[1])
                                cmd(split[2])
                                cmd "wincmd p"
                        end,
                }
        end
end

bufq { "qq", first, desc = "List 1st", ft = "qf" }
bufq { "Q", last, desc = "List last", ft = "qf" }
iter { "q", "Q" }:each(function(_) keymapq { "<leader>" .. _, toggle(_, 30, 25), desc = "Toggle List" } end)
kq
""
    { "qd", remove, desc = "List clear" }
    { "<M-Y>", older, desc = "List older" }
    { "<M-y>", newer, desc = "List newer" }
    { "<M-U>", qprev "prev", desc = "List item prev" }
    { "<M-u>", qnext "next", desc = "List item next" }
    { "<M-I>", qprev "Nfile", desc = "List file prev" }
    { "<M-i>", qnext "nfile", desc = "List file next" }
    { "<LocalLeader>q", Toggle.qfMode, desc = "Toggle List mode" }

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
cmd "packadd cfilter"
