local bkeymap = require("core.utils").bufKeymap
local abbr    = require("core.utils").bufAbbrev

------------------------------------------------------------------------------------------------------------------------

abbr("//",    "--")
abbr("const", "local")
abbr("let",   "local")
abbr("===",   "==")
abbr("!=",    "~=")
abbr("!==",   "~=")
abbr("=~",    "~=")
abbr("fi",    "end")
abbr("fu",    "function")

---@param sign "+"|"-"
local function plusPlusMinusMinus(sign)
        local row, col           = unpack(vim.api.nvim_win_get_cursor(0))
        local text_before_cursor = vim.api.nvim_get_current_line():sub(col - 1, col)
        if not text_before_cursor:find("%a%" .. sign) then
                vim.api.nvim_feedkeys(sign, "n", true)
        else
                local line    = vim.api.nvim_get_current_line()
                local updated = line:gsub("(%w+)%" .. sign, "%1 = %1 " .. sign .. " 1")
                vim.api.nvim_set_current_line(updated)
                local diff = #updated - #line
                vim.api.nvim_win_set_cursor(0, { row, col + diff })
        end
end
bkeymap("i", "+", function() plusPlusMinusMinus("+") end, { desc = "i++  i = i + 1" })
bkeymap("i", "-", function() plusPlusMinusMinus("-") end, { desc = "i--  i = i - 1" })

---- AUTO-COMMA FOR TABLES ---------------------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("TextChangedI", {
        desc     = "User (buffer-specific): auto-comma for tables",
        buffer   = 0,
        group    = vim.api.nvim_create_augroup("lua-autocomma", { clear = true }),
        callback = function()
                local node = vim.treesitter.get_node()
                if node and node:type() == "table_constructor" then
                        local line = vim.api.nvim_get_current_line()
                        if line:find("^%s*[^,%s%-]$") then vim.api.nvim_set_current_line(line .. ",") end
                end
        end,
})

---- YANK MODULE NAME --------------------------------------------------------------------------------------------------

bkeymap("n", "<leader>ym", function()
                local abs_path = vim.api.nvim_buf_get_name(0)
                local rel_path = abs_path:sub(#(vim.uv.cwd()) + 2)
                local module   = rel_path:gsub("%.lua$", ""):gsub("^lua/", ""):gsub("/", "."):gsub("%.init$", "")
                local req      = ("require(%q)"):format(module)
                vim.fn.setreg("+", req)
                vim.notify(req, nil, { icon = "󰅍", title = "Copied", ft = "lua" })
        end, { desc = "󰢱 Module (require)" })

--[[ SEMANTIC TOKENS ---------------------------------------------------------------------------------------------------

vim.api.nvim_create_autocmd("LspTokenUpdate", {
        callback = function(args)
                local token = args.data.token
                if
                           token.type == "variable"
                           and token.modifiers.globalScope
                           and not token.modifiers.readonly
                           and not token.modifiers.defaultLibrary
                then
                        vim.lsp.semantic_tokens.highlight_token(
                                token, args.buf, args.data.client_id, "varGlobScope")
                end
        end,
})
--]]

local groups = {
        { "@constructor.lua",     "Delimiter" },
        { "@type.luadoc",         "Comment" },
        { "@type.builtin.luadoc", "@type.luadoc" },
}

require("core.utils").linkHl(groups)
