local fn         = vim.fn
local uv         = vim.uv
local api        = vim.api
local treesitter = vim.treesitter

local augroup = api.nvim_create_augroup

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

abbr "//" "--"
abbr "const" "local"
abbr "let" "local"
abbr "===" "=="
abbr "!=" "~="
abbr "!==" "~="
abbr "=~" "~="
abbr "fi" "end"
abbr "ret" "return"
abbr "fu" "function"

---@param sign "+"|"-"
local function plusPlusMinusMinus(sign)
        local row, col           = unpack(api.nvim_win_get_cursor(0))
        local text_before_cursor = api.nvim_get_current_line():sub(col - 1, col)
        if not text_before_cursor:find("%a%" .. sign) then
                api.nvim_feedkeys(sign, "n", true)
        else
                local line    = api.nvim_get_current_line()
                local updated = line:gsub("(%w+)%" .. sign, "%1 = %1 " .. sign .. " 1")
                api.nvim_set_current_line(updated)
                local diff = #updated - #line
                api.nvim_win_set_cursor(0, { row, col + diff })
        end
end

bufq { "+", function() plusPlusMinusMinus "+" end, mode = "i", desc = "i++  i = i + 1" }
bufq { "-", function() plusPlusMinusMinus "-" end, mode = "i", desc = "i--  i = i - 1" }

---- AUTO-COMMA FOR TABLES -----------------------------------------------------------------------------------------------------------------------------------------------------------------

auq "TextChangedI" {
        desc     = "User (buffer-specific): auto-comma for tables",
        buffer   = 0,
        group    = augroup("lua-autocomma", { clear = true }),
        callback = function()
                local node = treesitter.get_node()
                if node and node:type() == "table_constructor" then
                        local line = api.nvim_get_current_line()
                        if line:find "^%s*[^,%s%-]$" then api.nvim_set_current_line(line .. ",") end
                end
        end,
}

---- YANK MODULE NAME ----------------------------------------------------------------------------------------------------------------------------------------------------------------------

bufq { "<leader>ym", function()
        local abs_path = api.nvim_buf_get_name(0)
        local rel_path = abs_path:sub(#(uv.cwd()) + 2)
        local module   = rel_path:gsub("%.lua$", ""):gsub("^lua/", ""):gsub("/", "."):gsub("%.init$", "")
        local req      = ("require(%q)"):format(module)
        fn.setreg("+", req)
        vim.notify(req, nil, { icon = "󰅍", title = "Copied", ft = "lua" })
end, mode = "n", desc = "󰢱 Module (require)" }
