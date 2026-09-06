local nx  = { "n", "x" }
local nxo = { "n", "x", "o" }

local function move(motion)
        return "<cmd>lua require('spider').motion('" .. motion .. "')<CR>"
end

return {
        "chrisgrieser/nvim-spider",
        event = "BufReadPost",
        keys  = {
                { "e", move "e",  mode = nxo, desc = "end of subword" },
                { "w", move "w",  mode = nxo, desc = "end of subword" },
                { "b", move "b",  mode = nx,  desc = "beginning of subword" },
                { "W", move "ge", mode = nxo, desc = "beginning of subword" },
        },
        opts  = {
                skipInsignificantPunctuation = false,
                subwordMovement              = true,
                consistentOperatorPending    = true,
                customPattern                = { "%d+" },
        },
}
