local squareFilled = "■"
local squareEmpty  = "󰝣"

_G.Config = {}

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
--[[ TREESITTER

local default_treesitter_branch = (vim.fn.executable("make") == 1 and
        vim.fn.executable("tree-sitter") == 1) and "main" or "master"
vim.g.treesitter_branch         = vim.env.NVIM_TREESITTER_BRANCH or default_treesitter_branch
--]]

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

------------------------------------------------------------------------------------------------------------------------
-- ICONS

_G.Icons = {}

---@enum DIAGNOSTICS
Icons.diagnostics = {
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

}

---@enum NOTIFIER
Icons.notifier = {
        error = squareFilled,
        warn  = squareFilled,
        info  = squareFilled,
        debug = squareFilled,
        trace = squareFilled,
}

---@enum FOLDING
Icons.arrows = {
        close      = "+",
        open       = "-",
        right      = "",
        left       = "",
        up         = "",
        down       = "",
        leftArrow  = "<",
        rightArrow = ">",
}

---@enum LSP KINDS
Icons.symbolKinds = {
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
}

---@enum LSP2 KINDS
Icons.symbolKindsAlt = {
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

}

---@enum DEVICONS
Icons.devicons = {
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
}

---@enum MISC
Icons.misc = {
        newFile    = "󰻭",
        recentFile = "󰕁",
        findFile   = "󰱽",
        findText   = "󰦪",
        restore    = "󰦛",
        config     = "󱤸",
        package    = "󰏗",
        newPackage = "󱧕",
        quit       = "󰈆",

        lightbulb = "󱠀",
        quickfix  = "󰏪",

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
}

---@enum SPINNER
Icons.spinner = {
        dots     = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" },
        vertical = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" },
}

---@enum GIT
Icons.git = {
        Git      = "",
        Added    = squareFilled,
        Modified = squareEmpty,
        Deleted  = squareEmpty,
}

------------------------------------------------------------------------------------------------------------------------
-- COLORS

_G.Colors = {}

Colors.Darkppuccin = {
        ivory     = "#dce0e8",
        spark     = "#add8e6",
        rosewater = "#f5e0dc",
        flamingo  = "#f2cdcd",
        pink      = "#f5c2e7",
        mauve     = "#cba6f7",
        red       = "#f38ba8",
        maroon    = "#eba0ac",
        peach     = "#fab387",
        yellow    = "#f9e2af",
        green     = "#a6e3a1",
        teal      = "#94e2d5",
        sky       = "#89dceb",
        sapphire  = "#74c7ec",
        blue      = "#89b4fa",
        lavender  = "#b4befe",
        text      = "#cdd6f4",
        subtext1  = "#bac2de",
        subtext0  = "#a6adc8",
        overlay2  = "#9399b2",
        overlay1  = "#7f849c",
        overlay0  = "#6c7086",
        surface2  = "#585b70",
        surface1  = "#45475a",
        surface0  = "#313244",
        base      = "#1e1e2e",
        mantle    = "#14141f",
        crust     = "#0e0e16",

        redBg    = "#251b25",
        YellowBg = "#262325",
        skyBg    = "#1a232b",
        tealBg   = "#1b2329",
}
