local g    = vim.g
local o    = vim.o
local bo   = vim.bo
local fn   = vim.fn
local api  = vim.api
local cmd  = vim.cmd
local iter = vim.iter
g.mode     = "c"

local p = require "utils.functional".predicates

---- HIGHLIGHTS ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

linq
"Qf"
    { "LineNr", "String" }
    { "Match", "CurSearch" }
    { "Filename", "Directory" }

---- TEXT ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local ns = api.nvim_create_namespace "QfList"

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
        E     = "DiagnosticSignError",
        W     = "DiagnosticSignWarn",
        I     = "DiagnosticSignInfo",
        N     = "DiagnosticSignHint",
        H     = "DiagnosticSignHint",
        error = "DiagnosticSignError",
}

local function shortPath(path)
        local sep    = string.sub(package.config, 1, 1);
        local as_raw = { "nvim$" };
        local fmod   = curry(fn.fnamemodify, 2)(path)
        local name   = match(path) {
                [fmod ":."] = function() return fmod ":~" end,
                _           = function() return fmod ":." end,
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
            :map(function(p, part)
                    return guard {
                            isRaw(part) or p == 1 or p == #parts, function()
                            return part
                    end,
                            string.match(part, "^%."), function()
                            return fn.strcharpart(part, 0, 2)
                    end, function()
                            return fn.strcharpart(part, 0, 1)
                    end }
            end)
            :totable()

        return table.concat(shortened, sep);
end

o.quickfixtextfunc = function(info)
        local what = { id = info.id, items = 1, qfbufnr = 1 }
        local list = match(info.quickfix) {
                [1] = fn.getqflist(what),
                _   = fn.getloclist(info.winid, what),
        }
        local prep = function(_)
                local hl      = type_hilights[_.type]
                local col     = _.lnum > 0 and _.col .. "" or ""
                local text    = _.text:gsub("^%s+", "")
                local lnum    = _.lnum > 0 and _.lnum .. ":" or ""
                local prefix  = _.type ~= "" and _.type .. ":" or ""
                local bufname = fn.bufname(_.bufnr)
                local fname   = _.lnum > 0 and match(_.bufnr) {
                        [2] = { "[" .. shortPath(bufname) .. "]:", "Special" },
                        _   = { shortPath(bufname) .. ":", type_hilights[_.type] or "QfFilename" },
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

local older  = function() pcmd("noautocmd silent! " .. "colder")("noautocmd silent! " .. "lolder") end
local newer  = function() pcmd("noautocmd silent! " .. "cnewer")("noautocmd silent! " .. "lnewer") end
local remove = function() cmd(g.mode .. "expr []") end
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
local prev   = function()
        pcmd(g.mode .. "prev")(g.mode .. "last")
        cmd "normal! zv"
end
local next   = function()
        pcmd(g.mode .. "next")(g.mode .. "first")
        cmd "normal! zv"
end
local fprev  = function()
        pcmd(g.mode .. "Nfile")(g.mode .. "last")
        cmd "normal! zv"
end
local fnext  = function()
        pcmd(g.mode .. "nfile")(g.mode .. "first")
        cmd "normal! zv"
end
local toggle = function(key, h, w)
        local function perc(_) return function(__) return math.floor(o[_] * __ * 0.01) end end
        return function()
                local split    = match(key) {
                        [p.lower] = { "", "resize " .. perc "lines" (h or 50) },
                        [p.upper] = { "wincmd L", "vertical resize " .. perc "columns" (w or 50) },
                }
                local list_win = match(g.mode) {
                        c = fn.getqflist { winid = true }.winid ~= 0,
                        l = fn.getloclist(0, { winid = true }).winid ~= 0,
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
    { "<M-u>", older, desc = "List older" }
    { "<M-U>", newer, desc = "List newer" }
    { "[", fprev, desc = "List file prev", nowait = true }
    { "]", fnext, desc = "List file next", nowait = true }
    { "(", prev, desc = "List item prev" }
    { ")", next, desc = "List item next" }
    { "qd", remove, desc = "List clear" }
    { "<LocalLeader>q", Toggle.qfMode, desc = "Toggle List mode" }

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
cmd "packadd cfilter"
