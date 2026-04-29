local bkeymap = require("core.utils").bufKeymap
local abbr    = require("core.utils").bufAbbrev

------------------------------------------------------------------------------------------------------------------------
-- FIXES HABITS FROM WRITING TOO MUCH IN OTHER LANGUAGES

abbr("//",    "--")
abbr("const", "local")
abbr("let",   "local")
abbr("===",   "==")
abbr("!=",    "~=")
abbr("!==",   "~=")
abbr("=~",    "~=") -- shell uses `=~`
abbr("fi",    "end")
abbr("fu",    "function")

---@param sign "+"|"-"
local function plusPlusMinusMinus(sign)
        local row, col           = unpack(vim.api.nvim_win_get_cursor(0))
        local text_before_cursor = vim.api.nvim_get_current_line():sub(col - 1, col)
        if not text_before_cursor:find("%a%" .. sign) then
                vim.api.nvim_feedkeys(sign, "n", true) -- pass through the trigger char
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

----AUTO-COMMA FOR TABLES-----------------------------------------------------------------------------------------------

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

----REQUIRE MODULE FROM CWD---------------------------------------------------------------------------------------------

-- lightweight version of `telescope-import.nvim` import (just for lua)
-- REQUIRED `ripgrep` (optionally `telescope` for selector & syntax highlighting)
bkeymap("n", "<leader>ci", function()
                local is_at_blank = vim.api.nvim_get_current_line():match("^%s*$")

                local regex     = [[local (\w+) = require\(["'](.*?)["']\)(\.[\w.]*)?]]
                local rg_args   = { "rg", "--no-config", "--only-matching", "--no-filename", regex }
                local rg_result = vim.system(rg_args):wait()
                assert(rg_result.code == 0, rg_result.stderr)
                local matches = vim.split(rg_result.stdout, "\n", { trimempty = true })

                -- unique matches only
                table.sort(matches)
                local uniq_matches = vim.fn.uniq(matches) ---@cast uniq_matches string[]

                -- sort by length of varname
                -- (enuring uniqueness needs separate sorting, since this one does not ensure
                -- ensure same items are next to each other)
                table.sort(uniq_matches, function(a, b)
                        local varname_a = a:match("local (%S+) ?=")
                        local varname_b = b:match("local (%S+) ?=")
                        return #varname_a < #varname_b
                end)

                vim.api.nvim_create_autocmd("FileType", {
                        desc     = "User (buffer-specific): Set filetype to `lua` for `TelescopeResults`",
                        pattern  = "TelescopeResults",
                        once     = true,
                        callback = function(ctx)
                                vim.bo[ctx.buf].filetype = "lua"
                                -- make discernible as the results are now colored
                                local ns = vim.api.nvim_create_namespace("telescope-import")
                                vim.api.nvim_win_set_hl_ns(0, ns)
                                vim.api.nvim_set_hl(ns, "TelescopeMatching", { reverse = true })
                        end,
                })

                vim.ui.select(uniq_matches, { prompt = " require", kind = "telescope" }, function(selection)
                        if not selection then return end
                        local lnum = vim.api.nvim_win_get_cursor(0)[1]
                        if is_at_blank then
                                vim.api.nvim_set_current_line(selection)
                                vim.cmd.normal{ "==", bang = true }
                        else
                                vim.api.nvim_buf_set_lines(0, lnum, lnum, false, { selection })
                                vim.cmd.normal{ "j==", bang = true }
                        end
                end)
        end, { desc = "󰢱 Import module" })

----YANK MODULE NAME----------------------------------------------------------------------------------------------------

bkeymap("n", "<leader>ym", function()
                local abs_path = vim.api.nvim_buf_get_name(0)
                local rel_path = abs_path:sub(#(vim.uv.cwd()) + 2)
                local module   = rel_path:gsub("%.lua$", ""):gsub("^lua/", ""):gsub("/", "."):gsub("%.init$", "")
                local req      = ("require(%q)"):format(module)
                vim.fn.setreg("+", req)
                vim.notify(req, nil, { icon = "󰅍", title = "Copied", ft = "lua" })
        end, { desc = "󰢱 Module (require)" })

--[[SEMANTIC TOKENS-----------------------------------------------------------------------------------------------------

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
