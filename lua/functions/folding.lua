local o   = vim.o
local v   = vim.v
local fn  = vim.fn
local wo  = vim.wo
local api = vim.api
local cmd = vim.cmd

local _levels = {}

-- vim.api.nvim_create_autocmd("BufLeave", {
--         callback = function(args)
--                 _levels[args.buf] = vim.wo.foldlevel
--         end,
-- })

-- vim.api.nvim_create_autocmd("BufEnter", {
--         callback = function(args)
--                 vim.wo.foldlevel = _levels[args.buf] or 0
--         end,
-- })

---- TEXT ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function _G.foldText()
        local start  = fn.getline(v.foldstart)
        local indent = start:match "^%s*" or ""
        local first  = start
            :gsub("^%s*", "")
            :gsub("\t", string.rep(" ", o.tabstop))

        local content = { first .. " ... ", "FoldText" }
        return { { indent }, content }
        -- return match(indent) {
        --         [""] = { { indent }, content },
        --         _    = { { indent }, content },
        -- }
end

o.foldtext = [[v:lua.foldText()]]

---- OPERATIONS ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local range = { 0, 9 }

local function getMaxFoldLvl()
        return vim
            .iter(ipairs(fn.range(1, api.nvim_buf_line_count(0))))
            :map(function(lnum) return fn.foldlevel(lnum) end)
            :fold(0, math.max)
end

local function setFoldLvl(lvl)
        if lvl >= range[1] then
                wo.foldlevel = lvl
        elseif lvl <= range[1] then
                wo.foldlevel = lvl
        end
end

local function reduceFoldLvl()
        local lvl = tonumber(wo.foldlevel) or 0
        if lvl > 0 then
                wo.foldlevel = lvl - 1
        end
end

local function increaseFoldLvl()
        local lvl = tonumber(wo.foldlevel) or 0
        if lvl < getMaxFoldLvl() then
                wo.foldlevel = lvl + 1
        end
end

local function closeTopLvl()
        cmd.normal { "zR", bang = true }
        cmd "%foldclose"
end

local function openTopLvl()
        cmd.normal { "zM", bang = true }
        cmd "%foldopen"
end

---- MOVEMENT ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---@param winid number
---@param f fun(): any
---@return any
local function winCall(winid, f)
        if winid == api.nvim_get_current_win() then
                return f()
        elseif winid == 0 then
                return f()
        else
                api.nvim_win_call(winid, f)
        end
end

---@param winid number
---@return table
local function saveView(winid)
        return winCall(winid, fn.winsaveview)
end

---@param winid number
---@param lnum number
---@return number
local function foldClosed(winid, lnum)
        return winCall(winid, function()
                return fn.foldclosed(lnum)
        end)
end

---@param winid number
---@param view table
local function restView(winid, view)
        winCall(winid, function()
                fn.winrestview(view)
        end)
end

---@return number
local function getCurLnum()
        return api.nvim_win_get_cursor(0)[1]
end

local function gotoPrevFold()
        local cnt      = v.count1
        local view     = saveView(0)
        local cur_lnum = getCurLnum()
        cmd "norm! m`"
        local prev_lnum
        local prev_lnum_list = {}
        while cnt > 0 do
                cmd [[keepj norm! zk]]
                local t_lnum = getCurLnum()
                cmd [[keepj norm! [z]]
                if t_lnum == getCurLnum() then
                        local fold_start_lnum = foldClosed(0, t_lnum)
                        if fold_start_lnum > 0 then
                                cmd(("keepj norm! %dgg"):format(fold_start_lnum))
                        end
                end
                local next_lnum = getCurLnum()
                while cur_lnum > next_lnum do
                        t_lnum = next_lnum
                        table.insert(prev_lnum_list, next_lnum)
                        cmd [[keepj norm! zj]]
                        next_lnum = getCurLnum()
                        if next_lnum == t_lnum then
                                break
                        end
                end
                if #prev_lnum_list == 0 then
                        break
                end
                if #prev_lnum_list < cnt then
                        cnt       = cnt - #prev_lnum_list
                        cur_lnum  = prev_lnum_list[1]
                        prev_lnum = cur_lnum
                        cmd(("keepj norm! %dgg"):format(cur_lnum))
                        prev_lnum_list = {}
                else
                        while cnt > 0 do
                                prev_lnum = table.remove(prev_lnum_list)
                                cnt       = cnt - 1
                        end
                end
        end

        restView(0, view)
        if prev_lnum then
                cmd(("norm! %dgg_"):format(prev_lnum))
        end
end

---- KEYMAP --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local mode = { "n", "x", "o" }
vim.keymap.set(mode, "<S-Left>",  "zM",         { desc = "Folds close all" })
vim.keymap.set(mode, "<S-Right>", "zR",         { desc = "Folds open all" })
vim.keymap.set(mode, "<Left>",    "zc^",        { desc = "Fold close" })
vim.keymap.set(mode, "<Right>",   "zo^",        { desc = "Fold open" })
vim.keymap.set(mode, "<Down>",    "zj^",        { desc = "Fold next" })
vim.keymap.set(mode, "<Up>",      gotoPrevFold, { desc = "Fold prev" })
vim.keymap.set(mode, "<M-z>",     closeTopLvl,  { desc = "Close toplevel folds" })
vim.keymap.set(mode, "<M-Z>",     openTopLvl,   { desc = "Open toplevel folds" })
vim.keymap.set(mode, "zv",        "zv",         { desc = "Open tocursor" })

vim.keymap.set(mode, "<M-,>", reduceFoldLvl,   { desc = "Reduce Fold" })
vim.keymap.set(mode, "<M-.>", increaseFoldLvl, { desc = "Increase Fold" })

vim.keymap.set(mode, "<Esc>", "<Esc>zv", { unique = false })

vim
    .iter { "1", "2", "3", "4", "5", "6", "7", "8", "9" }
    :each(function(key)
            vim.keymap.set(mode, "<M-" .. key .. ">", function() setFoldLvl() end)
    end)
