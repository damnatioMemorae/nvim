local function isFloatingWin()
        local win = vim.api.nvim_get_current_win()
        return vim.api.nvim_win_get_config(win).relative ~= ""
end

---@param delEvents? vim.api.keyset.events|vim.api.keyset.events[]
---@param delPattern? (`string|array?`)
function _G.addBackdrop(delEvents, delPattern, backdropLevel)
        delEvents     = delEvents or "WinClosed"
        delPattern    = delPattern or nil
        backdropLevel = backdropLevel or Config.backdrop

        local backdrop_name  = "Backdrop"
        local zindex         = vim.api.nvim_win_get_config(vim.api.nvim_get_current_win()).zindex
        local backdrop_bufnr = vim.api.nvim_create_buf(false, true)
        local win            = vim.api.nvim_open_win(backdrop_bufnr, false, {
                relative  = "editor",
                row       = 0,
                col       = 0,
                width     = vim.o.columns,
                height    = vim.o.lines,
                focusable = false,
                style     = "minimal",
                zindex    = zindex - 10,
        })

        vim.api.nvim_set_hl(0, backdrop_name, { bg = "#000000" })
        vim.wo[win].winhighlight        = "Normal:" .. backdrop_name
        vim.wo[win].winblend            = backdropLevel
        vim.bo[backdrop_bufnr].buftype  = "nofile"
        vim.bo[backdrop_bufnr].filetype = "backdrop"

        vim.api.nvim_create_autocmd(delEvents, {
                pattern  = delPattern,
                callback = function()
                        if isFloatingWin() then
                                if vim.api.nvim_win_is_valid(win) then
                                        vim.api.nvim_win_close(win, true)
                                end
                        else
                                if vim.api.nvim_buf_is_valid(backdrop_bufnr) then
                                        vim.api.nvim_buf_delete(backdrop_bufnr, { force = true })
                                end
                        end
                end,
        })
end
