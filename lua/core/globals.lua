local square_filled = "■"
local square_empty  = "󰝣"

_G.Config  = {}
_G.Icons   = {}
_G.Colors  = {}
_G.Border  = {}
_G.Spinner = {}

---- VARIABLES ---------------------------------------------------------------------------------------------------------

Config.projectsDir = vim.env.HOME .. "/deeznuts/"
Config.backdrop    = 60
Config.blend       = 0
Config.winblend    = 0
Config.localRepos  = vim.fs.normalize("$HOME/deeznuts/")

Config.codeLens   = true
Config.conceal    = true
Config.inlayHints = true
Config.indentLine = true

---- BORDERS -----------------------------------------------------------------------------------------------------------

Border.borderStyle       = { " ", " ", " ", " ", " ", " ", " ", " " }
Border.borderTop         = { "▔", "▔", "▔", " ", " ", " ", " ", " " }
Border.borderBottom      = { " ", " ", " ", " ", "▂", "▂", "▂", " " }
Border.borderLeft        = { "▌", " ", " ", " ", " ", " ", "▌", "▌" }
Border.borderRight       = { " ", " ", "🮉", "🮉", "🮉", " ", " ", " " }
Border.borderTopEmpty    = { "▔", "▔", "▔", "", "", "", "", "" }
Border.borderBottomEmpty = { "", "", "", "", "▂", "▂", "▂", "" }
Border.borderLeftEmpty   = { "▌", "", "", "", "", "", "▌", "▌" }
Border.borderRightEmpty  = { "", "", "🮉", "🮉", "🮉", "", "", "" }
Border.borderStyleNone   = "none"

---- SPINNERS ----------------------------------------------------------------------------------------------------------

Spinner.dots     = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
Spinner.vertical = { "▁", "▂", "▃", "▄", "▅", "▆", "▇", "█" }

--[[ TREESITTER --------------------------------------------------------------------------------------------------------

local default_treesitter_branch = (vim.fn.executable("make") == 1 and
        vim.fn.executable("tree-sitter") == 1) and "main" or "master"
vim.g.treesitter_branch         = vim.env.NVIM_TREESITTER_BRANCH or default_treesitter_branch
--]]

---- FUZZY SEARCH ------------------------------------------------------------------------------------------------------

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

---- ICONS -------------------------------------------------------------------------------------------------------------

Icons.Diagnostics = {
        ERROR = square_filled,
        WARN  = square_filled,
        INFO  = square_filled,
        HINT  = square_filled,

        Error = square_filled,
        Warn  = square_filled,
        Info  = square_filled,
        Hint  = square_filled,

        errorMd = "󰅙 ",
        warnMd  = " ",
        infoMd  = "󰀨 ",
        hintMd  = "󰁨 ",

}
Icons.Notifier    = {
        error = square_filled,
        warn  = square_filled,
        info  = square_filled,
        debug = square_filled,
        trace = square_filled,
}
Icons.Arrows      = {
        close     = "+",
        open      = "-",
        right     = "",
        left      = "",
        up        = "",
        down      = "",
        leftBig   = "<",
        rightBig  = ">",
        upSmol    = "",
        downSmol  = "",
        rightSmol = "",
        leftSmol  = "",
}
Icons.Kinds       = {
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
Icons.KindsAlt    = {
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
Icons.Devicons    = {
        Array             = "󰅪",
        Boolean           = "",
        BreakStatement    = "󰙧",
        Call              = "󰃷",
        CaseStatement     = "󱃙",
        Class             = "",
        Color             = "",
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
        File              = "",
        Folder            = "",
        ForStatement      = "󰑖",
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
        Operator          = "󰆕",
        Package           = "",
        Pair              = "󰅪",
        Property          = "",
        Reference         = "󰈇",
        Regex             = "",
        Repeat            = "󰑖",
        Scope             = "",
        Snippet           = "",
        Specifier         = "󰦪",
        Statement         = "",
        String            = "󰉾",
        Struct            = "",
        SwitchStatement   = "󰺟",
        Terminal          = "",
        Text              = "",
        Type              = "",
        TypeParameter     = "",
        Unit              = "",
        Value             = "󰎠",
        Variable          = "",
        WhileStatement    = "󰑖",
}
Icons.Misc        = {
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

        package_installed   = "󱧕",
        package_pending     = "󱧘",
        package_uninstalled = "󱧙",

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
        dashedBar      = square_filled,
        definiton      = square_filled,
        squareFilled   = square_filled,
        squareEmpty    = square_empty,
}
Icons.Git         = {
        Git      = "",
        Added    = square_filled,
        Modified = square_empty,
        Deleted  = square_empty,
}

---- COLORS ------------------------------------------------------------------------------------------------------------

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
