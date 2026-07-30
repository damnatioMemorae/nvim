_G.req
"functions"
           "toggle"
           { "statusline", "BufReadPost" }
           { "statuscol", "BufReadPost" }
           { "folding", "BufReadPost" }
           { "backdrop-underline-fix", "BufReadPost" }
           { "ui2", "UiEnter" }

require("functions.quickfix").setup()
-- require("functions.quickfix2")
