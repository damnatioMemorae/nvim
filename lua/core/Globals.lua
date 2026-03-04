local squareFilled = "■"
local squareEmpty  = "󰝣"

_G.Config = {}

------------------------------------------------------------------------------------------------------------------------
-- ICONS

Config.Icons = {
        ---@enum DIAGNOSTICS
        diagnostics = {
                ERROR = squareFilled,
                WARN  = squareFilled,
                INFO  = squareFilled,
                HINT  = squareFilled,

                Error = squareFilled,
                Warn  = squareFilled,
                Info  = squareFilled,
                Hint  = squareFilled,

                errorMd = "󰅙 ",
                warnMd  = " ",
                infoMd  = "󰀨 ",
                hintMd  = "󰁨 ",

                lightbulb = "󱠀",
        },

        ---@enum NOTIFIER
        notifier = {
                error = squareFilled,
                warn  = squareFilled,
                info  = squareFilled,
                debug = squareFilled,
                trace = squareFilled,
        },

        ---@enum FOLDING
        arrows = {
                close      = "+",
                open       = "-",
                right      = "",
                left       = "",
                up         = "",
                down       = "",
                leftArrow  = "<",
                rightArrow = ">",
        },

        ---@enum LSP KINDS
        symbolKinds = {
                Array             = "󰅪",
                Boolean           = "",
                BreakStatement    = "󰙧",
                Call              = "󰃷",
                CaseStatement     = "󱃙",
                Class             = "",
                Color             = "",
                Component         = "󰅴",
                Constant          = "",
                Constructor       = "",
                ContinueStatement = "→",
                Copilot           = "",
                Declaration       = "󰙠",
                Delete            = "󰢤",
                DoStatement       = "󰑖",
                Enum              = "",
                EnumMember        = "",
                Event             = "",
                Field             = "",
                File              = "",
                Folder            = "",
                ForStatement      = "󰑖",
                Fragment          = "󰅴",
                Function          = "",
                H1Marker          = "󰉫",
                H2Marker          = "󰉬",
                H3Marker          = "󰉭",
                H4Marker          = "󰉮",
                H5Marker          = "󰉯",
                H6Marker          = "󰉰",
                Identifier        = "",
                IfStatement       = "",
                Interface         = "",
                Key               = "",
                Keyword           = "",
                List              = "󰅪",
                Log               = "",
                Lsp               = "",
                Macro             = "",
                MarkdownH1        = "󰉫",
                MarkdownH2        = "󰉬",
                MarkdownH3        = "󰉭",
                MarkdownH4        = "󰉮",
                MarkdownH5        = "󰉯",
                MarkdownH6        = "󰉰",
                Method            = "",
                Module            = "",
                Namespace         = "",
                Null              = "󰢤",
                Number            = "󰎠",
                Object            = "",
                Operator          = "",
                Package           = "",
                Pair              = "󰅪",
                Parameter         = "󰏪",
                Property          = "",
                Reference         = "",
                Regex             = "",
                Repeat            = "󰑖",
                Scope             = "",
                Snippet           = "",
                Specifier         = "󰦪",
                Statement         = "",
                StaticMethod      = "",
                String            = "󰉾",
                Struct            = "",
                SwitchStatement   = "󰺟",
                Terminal          = "",
                Text              = "",
                Type              = "",
                TypeAlias         = "",
                TypeParameter     = "",
                Unit              = "",
                Value             = "",
                Variable          = "",
                WhileStatement    = "󰑖",
        },

        ---@enum LSP2 KINDS
        symbolKindsAlt = {
                Text          = "󰉿",
                Method        = "󰊕",
                Function      = "󰊕",
                Constructor   = "󰒓",
                Field         = "󰜢",
                Variable      = "󰆦",
                Property      = "󰖷",
                Class         = "󱡠",
                Interface     = "󱡠",
                Struct        = "󱡠",
                Module        = "󰅩",
                Unit          = "󰪚",
                Value         = "󰦨",
                Enum          = "󰦨",
                EnumMember    = "󰦨",
                Keyword       = "󰻾",
                Constant      = "󰏿",
                Snippet       = "󱄽",
                Color         = "󰏘",
                File          = "󰈔",
                Reference     = "󰬲",
                Folder        = "󰉋",
                Event         = "󱐋",
                Operator      = "󰪚",
                Type          = "󰜁",
                TypeParameter = "󰬛",

        },

        ---@enum DEVICONS
        devicons = {
                Array             = "󰅪 ",
                Boolean           = " ",
                BreakStatement    = "󰙧 ",
                Call              = "󰃷 ",
                CaseStatement     = "󱃙 ",
                Class             = " ",
                Color             = " ",
                Constant          = " ",
                Constructor       = " ",
                ContinueStatement = "→ ",
                Copilot           = " ",
                Declaration       = "󰙠 ",
                Delete            = "󰢤 ",
                DoStatement       = "󰑖 ",
                Enum              = " ",
                EnumMember        = " ",
                Event             = " ",
                Field             = " ",
                File              = " ",
                Folder            = " ",
                ForStatement      = "󰑖 ",
                Function          = " ",
                H1Marker          = "󰉫 ",
                H2Marker          = "󰉬 ",
                H3Marker          = "󰉭 ",
                H4Marker          = "󰉮 ",
                H5Marker          = "󰉯 ",
                H6Marker          = "󰉰 ",
                Identifier        = " ",
                IfStatement       = " ",
                Interface         = " ",
                Keyword           = " ",
                List              = "󰅪 ",
                Log               = " ",
                Lsp               = " ",
                Macro             = " ",
                MarkdownH1        = "󰉫 ",
                MarkdownH2        = "󰉬 ",
                MarkdownH3        = "󰉭 ",
                MarkdownH4        = "󰉮 ",
                MarkdownH5        = "󰉯 ",
                MarkdownH6        = "󰉰 ",
                Method            = " ",
                Module            = " ",
                Namespace         = " ",
                Null              = "󰢤 ",
                Number            = "󰎠 ",
                Object            = " ",
                Operator          = "󰆕 ",
                Package           = " ",
                Pair              = "󰅪 ",
                Property          = " ",
                Reference         = "󰈇 ",
                Regex             = " ",
                Repeat            = "󰑖 ",
                Scope             = " ",
                Snippet           = " ",
                Specifier         = "󰦪 ",
                Statement         = " ",
                String            = "󰉾 ",
                Struct            = " ",
                SwitchStatement   = "󰺟 ",
                Terminal          = " ",
                Text              = " ",
                Type              = " ",
                TypeParameter     = " ",
                Unit              = " ",
                Value             = "󰎠 ",
                Variable          = " ",
                WhileStatement    = "󰑖 ",
        },

        ---@enum MISC
        misc = {
                Bug            = "",
                ellipsis       = "…",
                Search         = "",
                verticalBar    = "▏",
                Prompt         = ">",
                folderOpen     = "",
                folderEmpty    = "",
                reference      = "󰘷",
                implementation = "󰃐",
                offSpec        = "",
                dashedBar      = squareFilled,
                definiton      = squareFilled,
                squareFilled   = squareFilled,
                squareEmpty    = squareEmpty,
        },

        ---@enum SPINNER
        spinner = {
                dots     = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
                vertical = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
        },

        ---@enum GIT
        git = {
                Git      = "",
                Added    = squareFilled,
                Modified = squareEmpty,
                Deleted  = squareEmpty,
        },
}

------------------------------------------------------------------------------------------------------------------------
-- VARIABLES

Config.prefix       = ","
Config.projects_dir = vim.env.HOME .. "/deeznuts/"
Config.backdrop     = 80
Config.blend        = 0
Config.winblend     = 0
Config.localRepos   = vim.fs.normalize("$HOME/deeznuts/")

------------------------------------------------------------------------------------------------------------------------
-- BORDERS

Config.borderStyle       = { " ", " ", " ", " ", " ", " ", " ", " " }
Config.borderTop         = { "▔", "▔", "▔", " ", " ", " ", " ", " " }
Config.borderBottom      = { " ", " ", " ", " ", "▂", "▂", "▂", " " }
Config.borderLeft        = { "▌", " ", " ", " ", " ", " ", "▌", "▌" }
Config.borderRight       = { " ", " ", "🮉", "🮉", "🮉", " ", " ", " " }
Config.borderTopEmpty    = { "", "", "", "", "", "", "", "" }
Config.borderBottomEmpty = { "", "", "", "", "▂", "▂", "▂", "" }
Config.borderLeftEmpty   = { "▌", "", "", "", "", "", "▌", "▌" }
Config.borderRightEmpty  = { "", "", "🮉", "🮉", "🮉", "", "", "" }
Config.borderStyleNone   = "none"

------------------------------------------------------------------------------------------------------------------------
-- TREESITTER

local default_treesitter_branch = (vim.fn.executable("make") == 1 and
        vim.fn.executable("tree-sitter") == 1) and "main" or "master"
vim.g.treesitter_branch         = vim.env.NVIM_TREESITTER_BRANCH or default_treesitter_branch

------------------------------------------------------------------------------------------------------------------------
--[[ FUZZY SEARCH

vim.o.wildmode = "noselect"
vim.api.nvim_create_autocmd("CmdlineChanged", {
        pattern  = ":",
        callback = function()
                vim.fn.wildtrigger()
        end,
})

function _G.fuzzySearch(text, _)
        local files = vim.fn.glob("**/*", true, true)

        return vim.fn.matchfuzzy(files, text)
end

vim.o.findfunc = "v:lua.fuzzySearch"
--]]
