local g    = vim.g
local o    = vim.o
local bo   = vim.bo
local fn   = vim.fn
local api  = vim.api
local cmd  = vim.cmd
local iter = vim.iter
g.mode     = "c"

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
        local list = where(function(_)
                return match(info.quickfix) {
                        [1] = fn.getqflist(_.what),
                        _   = fn.getloclist(info.winid, _.what),
                }
        end) { what = { id = info.id, items = 1, qfbufnr = 1 } }

        local prep = function(tt)
                return where(function(_)
                        return {
                                { _.prefix, _.hl },
                                _.fname,
                                { _.lnum,   "QfLineNr" },
                                { _.col,    "QfLineNr" },
                                { " ",      "Default" },
                                { _.text,   "QfText" },
                        }
                end) {
                        hl     = type_hilights[tt.type],
                        text   = tt.text:gsub("^%s+", ""),
                        col    = tt.lnum > 0 and tt.col .. "" or "",
                        lnum   = tt.lnum > 0 and tt.lnum .. ":" or "",
                        prefix = tt.type ~= "" and tt.type .. ":" or "",
                        fname  = tt.lnum > 0 and match(tt.bufnr) {
                                [2] = { "[" .. shortPath(fn.bufname(tt.bufnr)) .. "]:", "Special" },
                                _   = { shortPath(fn.bufname(tt.bufnr)) .. ":", type_hilights[tt.type] or "QfFilename" },
                        } or nil,
                }
        end

        return where(function(_)
                vim.schedule(function() applyHighlights(list.qfbufnr, _.ttt) end)
                return getLines(_.ttt)
        end) {
                ttt = iter(list.items)
                    :map(function(item) return prep(item) end)
                    :totable(),
        }
end

---- KEYMAPS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local prev   = function() pcmd(g.mode .. "prev")(g.mode .. "last") end
local next   = function() pcmd(g.mode .. "next")(g.mode .. "first") end
local fprev  = function() pcmd(g.mode .. "Nfile")(g.mode .. "last") end
local fnext  = function() pcmd(g.mode .. "nfile")(g.mode .. "first") end
local older  = function() pcmd("silent! " .. "colder")("silent! " .. "lolder") end
local newer  = function() pcmd("silent! " .. "cnewer")("silent! " .. "lnewer") end
local remove = function() cmd(g.mode .. "expr []") end
local first  = function()
        pcmd "lfirst" "cfirst"
        cmd "wincmd p"
end
local last   = function()
        pcmd "llast" "clast"
        cmd "wincmd p"
end
local toggle = function(key, h, w)
        return function()
                where(function(_)
                        cmd(_.list_win and _.mode .. "close" or _.mode .. "open")
                        match(bo.buftype) {
                                quickfix = function()
                                        cmd(_.split[1])
                                        cmd(_.split[2])
                                        cmd "wincmd p"
                                end,
                        }
                end) {
                            mode     = g.mode,
                            list_win = match(g.mode) {
                                    c = fn.getqflist { winid = true }.winid ~= 0,
                                    l = fn.getloclist(0, { winid = true }).winid ~= 0,
                            },
                            split    = match(key) {
                                    [_lower()] = { "", "resize " .. math.floor(o.lines * (h or 50) * 0.01) },
                                    [_upper()] = { "wincmd L", "vertical resize " .. math.floor(o.columns * (w or 50) * 0.01) },
                            },
                    }
        end
end

bufq { "qq", first, desc = "List 1st", ft = "qf" }
bufq { "Q", last, desc = "List last", ft = "qf" }
kq
""
    { "[", fprev, desc = "List file prev", nowait = true }
    { "]", fnext, desc = "List file next", nowait = true }
    { "(", prev, desc = "List item prev" }
    { ")", next, desc = "List item next" }
    { "<S-Tab>", older, desc = "List older" }
    { "<Tab>", newer, desc = "List newer" }
    { "qd", remove, desc = "List clear" }
    { "<LocalLeader>q", Toggle.qfMode, desc = "Toggle List mode" }
iter { "q", "Q" }
    :each(function(_) keymapq { "<leader>" .. _, toggle(_, 30, 25), desc = "Toggle List" } end)

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

cmd "packadd cfilter"
