local textObj = require("core.utils").extraTextobjMaps

local modes   = { "n", "v", "x", "o" }

return { -- treesitter-based textobjs
        "nvim-treesitter/nvim-treesitter-textobjects",
        branch       = "master",
        dependencies = "nvim-treesitter",
        event        = "VeryLazy",
        cmd          = { -- commands need to be defined, since used in various utility functions
                "TSTextobjectSelect",
                "TSTextobjectSwapNext",
                "TSTextobjectSwapPrevious",
                "TSTextobjectGotoNextStart",
                "TSTextobjectGotoPreviousStart",
                "TSTextobjectPeekDefinitionCode",
                "TSTextobjectRepeatLastMove",
                "TSTextobjectRepeatLastMoveNext",
                "TSTextobjectRepeatLastMoveOpposite",
                "TSTextobjectRepeatLastMovePrevious",
        },
        keys         = {
                ---[[ COMMENT OPERATIONS
                { -- COMMENT SINGLE
                        "q",
                        "<cmd>TSTextobjectSelect @comment.inner<CR>",
                        mode = "o", -- only operator-pending to not conflict with selection-commenting
                        desc = "󰆈 Single Comment",
                },
                { -- COMMENT STICKY DELETE
                        "qd",
                        function()
                                local prevCursor = vim.api.nvim_win_get_cursor(0)
                                vim.cmd.TSTextobjectSelect("@comment.outer")
                                vim.cmd.normal{ "d", bang = true }
                                vim.cmd.normal("zz^")
                                vim.api.nvim_win_set_cursor(0, prevCursor)
                        end,
                        desc = "󰆈 Sticky Delete Comment",
                },
                { -- COMMENT CHANGE
                        "qc",
                        function()
                                vim.cmd.TSTextobjectSelect("@comment.outer")
                                vim.cmd.normal{ "d", bang = true }
                                local comStr = vim.trim( vim.bo.commentstring:format("") )
                                local line   = vim.api.nvim_get_current_line():gsub("%s+$", "")
                                vim.api.nvim_set_current_line(line .. " " .. comStr .. " ")
                                vim.cmd.startinsert{ bang = true }
                        end,
                        desc = "󰆈 Change Comment",
                },
                --]]

                ---[[ MOVE & SWAP
                { -- `Q` - COMMENT PREV
                        "<A-Q>",
                        "<cmd>TSTextobjectGotoPreviousStart @comment.outer<CR>",
                        mode = modes,
                        desc = " Goto prev comment",
                },
                { -- `q` - COMMENT NEXT
                        "<A-q>",
                        "<cmd>TSTextobjectGotoNextStart @comment.outer<CR>",
                        mode = modes,
                        desc = " Goto next comment",
                },
                { -- `F` - FUNCTION PREV
                        "<A-F>",
                        "<cmd>TSTextobjectGotoPreviousStart @function.name<CR>",
                        mode = modes,
                        desc = Icons.symbolKinds.Function .. "Goto prev function",
                },
                { -- `f` - FUNCTION NEXT
                        "<A-f>",
                        "<cmd>TSTextobjectGotoNextStart @function.name<CR>",
                        mode = modes,
                        desc = Icons.symbolKinds.Function .. "Goto next function",
                },
                { -- `O` - CONDITION PREV
                        "<A-O>",
                        "<cmd>TSTextobjectGotoPreviousStart @conditional.inner<CR>",
                        mode = modes,
                        desc = Icons.symbolKinds.IfStatement .. "Goto prev condition",
                },
                { -- `o` - CONDITION NEXT
                        "<A-o>",
                        "<cmd>TSTextobjectGotoNextStart @conditional.inner<CR>",
                        mode = modes,
                        desc = Icons.symbolKinds.IfStatement .. "Goto next condition",
                },
                { -- `C` - CALL PREV
                        "<A-C>",
                        "<cmd>TSTextobjectGotoPreviousStart @call.outer<CR>",
                        mode = modes,
                        desc = Icons.symbolKinds.Call .. "Goto prev call",
                },
                { -- `c` - CALL NEXT
                        "<A-c>",
                        "<cmd>TSTextobjectGotoNextStart @call.outer<CR>",
                        mode = modes,
                        desc = Icons.symbolKinds.Call .. "Goto next call",
                },
                { -- `U` - LOOP PREV
                        "<A-U>",
                        "<cmd>TSTextobjectGotoPreviousStart @loop.outer<CR>",
                        mode = modes,
                        desc = Icons.symbolKinds.Repeat .. "Goto prev loop",
                },
                { -- `u` - LOOP NEXT
                        "<A-u>",
                        "<cmd>TSTextobjectGotoNextStart @loop.outer<CR>",
                        mode = modes,
                        desc = Icons.symbolKinds.Repeat .. "Goto next loop",
                },
                { -- `S` - ASSIGNMENT PREV
                        "<A-S>",
                        "<cmd>TSTextobjectGotoPreviousStart @assignment.lhs<CR>",
                        mode = modes,
                        desc = Icons.symbolKinds.Variable .. "Goto prev assignment",
                },
                { -- `s` - ASSIGNMENT NEXT
                        "<A-s>",
                        "<cmd>TSTextobjectGotoNextStart @assignment.lhs<CR>",
                        mode = modes,
                        desc = Icons.symbolKinds.Variable .. "Goto next assignment",
                },
                { -- `V` - VALUE PREV
                        "<A-V>",
                        "<cmd>TSTextobjectGotoPreviousStart @assignment.rhs<CR>",
                        mode = modes,
                        desc = Icons.symbolKinds.Value .. "Goto prev value",
                },
                { -- `v` - VALUE NEXT
                        "<A-v>",
                        "<cmd>TSTextobjectGotoNextStart @assignment.rhs<CR>",
                        mode = modes,
                        desc = Icons.symbolKinds.Value .. "Goto next value",
                },
                { -- `T` - TYPE PREV
                        "<A-T>",
                        "<cmd>TSTextobjectGotoPreviousStart @assignment.outer<CR>",
                        mode = modes,
                        desc = Icons.symbolKinds.Type .. "Goto prev type",
                },
                { -- `t` - TYPE NEXT
                        "<A-t>",
                        "<cmd>TSTextobjectGotoNextStart @assignment.outer<CR>",
                        mode = modes,
                        desc = Icons.symbolKinds.Type .. "Goto next type",
                },
                { -- `A` - PARAMETER PREV
                        "<A-A>",
                        "<cmd>TSTextobjectGotoPreviousStart @parameter.inner<CR>",
                        mode = modes,
                        desc = Icons.symbolKinds.Parameter .. "Goto prev parameter",
                },
                { -- `a` - PARAMETER NEXT
                        "<A-a>",
                        "<cmd>TSTextobjectGotoNextStart @parameter.inner<CR>",
                        mode = modes,
                        desc = Icons.symbolKinds.Parameter .. "Goto next parameter",
                },
                { -- `{` - PARAMETER PREV SWAP
                        "<A-{>",
                        "<cmd>TSTextobjectSwapPrevious @parameter.inner<CR>",
                        mode = { "n", "x", "o" },
                        desc = Icons.symbolKinds.Parameter .. "Swap prev parameter",
                },
                { -- `}` - PARAMETER NEXT SWAP
                        "<A-}>",
                        "<cmd>TSTextobjectSwapNext @parameter.inner<CR>",
                        mode = { "n", "x", "o" },
                        desc = Icons.symbolKinds.Parameter .. "Swap next parameter",
                },
                --]]

                ---[[ TEXT OBJECT SELECT
                { -- `/` REGEX OUTER
                        "a/",
                        "<cmd>TSTextobjectSelect @regex.outer<CR>",
                        mode = { "x", "o" },
                        desc = Icons.symbolKinds.Regex .. "outer regex",
                },
                { -- `/` REGEX INNER
                        "i/",
                        "<cmd>TSTextobjectSelect @regex.inner<CR>",
                        mode = { "x", "o" },
                        desc = Icons.symbolKinds.Regex .. "inner regex",
                },
                { -- `f` FUNCTION OUTER
                        "a" .. textObj.func,
                        "<cmd>TSTextobjectSelect @function.outer<CR>",
                        mode = { "x", "o" },
                        desc = Icons.symbolKinds.Function .. "outer function",
                },
                { -- `f` FUNCTION INNER
                        "i" .. textObj.func,
                        "<cmd>TSTextobjectSelect @function.inner<CR>",
                        mode = { "x", "o" },
                        desc = Icons.symbolKinds.Function .. "inner function",
                },
                { -- `o` CONDITION OUTER
                        "a" .. textObj.condition,
                        "<cmd>TSTextobjectSelect @condition.outer<CR>",
                        mode = { "x", "o" },
                        desc = Icons.symbolKinds.IfStatement .. "outer condition",
                },
                { -- `o` CONDITION INNER
                        "i" .. textObj.condition,
                        "<cmd>TSTextobjectSelect @condition.outer<CR>",
                        mode = { "x", "o" },
                        desc = Icons.symbolKinds.IfStatement .. "inner condition",
                },
                { -- `l` CALL OUTER
                        "a" .. textObj.call,
                        "<cmd>TSTextobjectSelect @call.outer<CR>",
                        mode = { "x", "o" },
                        desc = Icons.symbolKinds.Call .. "outer call",
                },
                { -- `l` CALL INNER
                        "i" .. textObj.call,
                        "<cmd>TSTextobjectSelect @call.inner<CR>",
                        mode = { "x", "o" },
                        desc = Icons.symbolKinds.Call .. "inner call",
                },
                --]]

                ---[[ REPEATABLE ACTIONS
                {
                        '"',
                        "<cmd>TSTextobjectRepeatLastMovePrevious<CR>",
                        mode = { "n", "v", "x" },
                        desc = Icons.symbolKinds.Call .. "󰑖 Repeat to Prev",
                },
                {
                        "'",
                        "<cmd>TSTextobjectRepeatLastMoveNext<CR>",
                        mode = { "n", "v", "x" },
                        desc = Icons.symbolKinds.Repeat .. "󰑖 Repeat to Next",
                },
                --]]

                ---[[ PEEK DEFINITION
                {
                        ",,",
                        "<cmd>TSTextobjectPeekDefinitionCode @class.outer<CR>",
                        mode = modes,
                        desc = "󰏪 Peek Definition",
                },
                --]]
        },
}
