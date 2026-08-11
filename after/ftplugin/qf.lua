local o     = vim.o
local g     = vim.g
local fn    = vim.fn
local api   = vim.api
local cmd   = vim.cmd
local opt_l = vim.opt_local

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

opt_l.statuscolumn   = ""
opt_l.signcolumn     = "no"
opt_l.number         = false
opt_l.relativenumber = false

local function width(percentage)
        return o.columns * (tonumber(percentage) * 0.01)
end

local function height(percentage)
        return o.lines * (percentage * 0.01)
end

cmd("resize " .. height(20))
-- cmd "wincmd L"
-- cmd("vertical resize " .. width(25))

---- KEYMAPS -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local function filePrev() pcmd(g.qf_mode .. "Nfile")(g.qf_mode .. "last") end
local function fileNext() pcmd(g.qf_mode .. "nfile")(g.qf_mode .. "first") end
local function itemPrev() pcmd(g.qf_mode .. "prev")(g.qf_mode .. "last") end
local function itemNext() pcmd(g.qf_mode .. "next")(g.qf_mode .. "first") end
local function itemRmv() cmd(g.qf_mode .. "expr []") end
local function itemFirst()
        pcmd "lfirst" "cfirst"
        cmd "wincmd p"
end
local function itemLast()
        pcmd "llast" "clast"
        cmd "wincmd p"
end
local function toggleList()
        local mode = g.qf_mode
        match(mode) {
                l = function()
                        local list_win_open = fn.getloclist(0, { winid = true }).winid ~= 0
                        pcmd(list_win_open and "lclose" or "lopen")()
                        cmd "wincmd p"
                end,
                c = function()
                        local list_win_open = fn.getqflist { winid = true }.winid ~= 0
                        pcmd(list_win_open and "cclose" or "copen")()
                        cmd "wincmd p"
                end,
        }
end

local function findListWindow()
        for _, win in ipairs(api.nvim_list_wins()) do
                local info = fn.getwininfo(win)[1]
                if info.loclist == 1 then
                        g.qf_mode = "l"
                        return win, "ll"
                elseif info.quickfix == 1 then
                        g.qf_mode = "c"
                        return win, "qf"
                end
        end
        return nil
end
findListWindow()

bufq { "qq", itemFirst, desc = "List 1st" }
bufq { "Q", itemLast, desc = "List last" }

keyq { "[", filePrev, desc = "List file prev", unique = false }
keyq { "]", fileNext, desc = "List file next", unique = false }
keyq { "(", itemPrev, desc = "List item prev", unique = false }
keyq { ")", itemNext, desc = "List item next", unique = false }
keyq { "qr", itemRmv, desc = "List remove", unique = false }
keyq { "qm", Toggle.qfMode, desc = "Toggle List mode", unique = false }
keyq { "<leader>q", toggleList, desc = "List remove", unique = false }
