local M = {}
--------------------------------------------------------------------------------

local map   = require("core.utils").uniqueKeymap
local ufo   = require("ufo")
local flash = require("flash")

map({ "n" }, ",,", function()
            -- local winid = ufo.peekFoldedLinesUnderCursor()
            -- if not winid then
            --         vim.cmd("TSTextobjectPeekDefinitionCode @class.outer")
            --         vim.lsp.buf.signature_help()
            --         vim.lsp.buf.hover()
            -- end
    end, { desc = "Super Comma Key" })

--------------------------------------------------------------------------------
return M
