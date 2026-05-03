vim.cmd("highlight clear")

if vim.fn.exists("syntax_on") then
        vim.cmd("syntax reset")
end

vim.o.termguicolors = true
vim.g.colors_name   = "darkppuccin"

local colors = {
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
        crust1    = "#11111b",
        crust     = "#0e0e16",

        -- green_transparent  = "#1d2324",
        -- yellow_transparent = "#262325",
        -- red_transparent    = "#251b25",

        -- green_transparent  = "#3c4e40",
        -- yellow_transparent = "#554e44",
        -- red_transparent    = "#533342",

        teal_transparent   = "#29383c",
        green_transparent  = "#2c3932",
        yellow_transparent = "#3d3835",
        red_transparent    = "#3c2733",
}

vim.g.terminal_color_0          = colors.crust
vim.g.terminal_color_1          = colors.red
vim.g.terminal_color_2          = colors.green
vim.g.terminal_color_3          = colors.yellow
vim.g.terminal_color_4          = colors.lavender
vim.g.terminal_color_5          = colors.pink
vim.g.terminal_color_6          = colors.sky
vim.g.terminal_color_7          = colors.text
vim.g.terminal_color_8          = colors.base
vim.g.terminal_color_9          = colors.maroon
vim.g.terminal_color_10         = colors.green
vim.g.terminal_color_11         = colors.peach
vim.g.terminal_color_12         = colors.sapphire
vim.g.terminal_color_13         = colors.mauve
vim.g.terminal_color_14         = colors.teal
vim.g.terminal_color_15         = colors.subtext0
vim.g.terminal_color_background = colors.crust
vim.g.terminal_color_foreground = colors.text

---@type table<string, vim.api.keyset.highlight>
local groups = {

        ---- BLEND -----------------------------------------------------------------------------------------------------
        WinBlend = { bg = "#000000" },
        Backdrop = { bg = "#000000" },

        ---- TITLES ----------------------------------------------------------------------------------------------------
        Title      = { fg = colors.teal },
        FloatTitle = { fg = colors.teal, bg = colors.mantle },

        ---- SEARCH ----------------------------------------------------------------------------------------------------
        Search    = { fg = colors.crust, bg = colors.spark },
        CurSearch = { fg = colors.teal, bg = colors.base },
        IncSearch = { fg = colors.teal, bg = colors.base },

        ---- UI --------------------------------------------------------------------------------------------------------
        CursorLine   = { fg = "none", bg = "none" },
        Visual       = { bg = "none", bold = true },
        VisualNOS    = { bg = "none", bold = true },
        WinBar       = { link = "Normal" },
        WinBarNC     = { link = "Winbar" },
        StatusLine   = { link = "Normal" },
        StatusLineNC = { link = "Normal", underline = true },
        Label        = { fg = colors.sky },

        ---- COLUMN ----------------------------------------------------------------------------------------------------
        LineNr           = { link = "NonText" },
        CursorLineNr     = { fg = colors.ivory },
        ActiveLineNumber = { link = "CursorLineNr" },
        Folded           = { fg = colors.surface2, bg = colors.crust1 },
        FoldMark         = { link = "Comment" },
        FoldColumn       = { link = "NonText" },
        SignColumn       = { link = "NonText" },

        ---- MENU ------------------------------------------------------------------------------------------------------
        Pmenu       = { bg = colors.crust1 },
        PmenuSel    = { link = "Visual" },
        PmenuSbar   = { bg = colors.base },
        PmenuThumb  = { bg = colors.surface0 },
        PmenuBorder = { link = "borderStyle" },

        ---- EIDITOR ---------------------------------------------------------------------------------------------------
        Normal         = { bg = colors.crust },
        NormalFloat    = { bg = colors.crust1 },
        NormalNC       = { link = "Normal" },
        WinSeparator   = { link = "NonText" },
        VertSplit      = { link = "WinSeparator" },
        Error          = { link = "DiagnosticError" },
        Question       = { fg = colors.teal },
        SpecialKey     = { link = "NonText" },
        Special        = { fg = colors.pink },
        SpecialComment = { link = "Special" },
        NonText        = { fg = colors.surface0 },

        ---- SPELL -----------------------------------------------------------------------------------------------------
        SpellBad   = { sp = colors.red, underline = true },
        SpellCap   = { sp = colors.yellow, underline = true },
        SpellLocal = { sp = colors.blue, underline = true },
        SpellRare  = { sp = colors.green, underline = true },

        TSDefinitionUsage  = { link = "LspReferenceText" },
        WildMenu           = { bg = colors.mantle },
        markdownBlockquote = { bg = "none" },
        QuickFixLine       = { link = "Visual" },

        ---- DIFF ------------------------------------------------------------------------------------------------------
        DiffAdded   = { fg = colors.green },
        DiffChanged = { fg = colors.yellow },
        DiffRemoved = { fg = colors.red },
        DiffAdd     = { fg = colors.green, bg = colors.green_transparent },
        DiffChange  = { fg = colors.yellow, bg = colors.yellow_transparent },
        DiffDelete  = { fg = colors.red, bg = colors.red_transparent },
        DiffText    = { fg = colors.teal, bg = colors.teal_transparent },

        ---- MSG -------------------------------------------------------------------------------------------------------
        OkMsg      = { link = "DiagnosticOk" },
        WarningMsg = { link = "DiagnosticWarn" },
        ErrorMsg   = { link = "DiagnosticError" },
        StderrMsg  = { link = "ErrorMsg" },
        StdoutMsg  = { link = "Normal" },
        MoreMsg    = { link = "Comment" },
        MsgArea    = { link = "NormalFloat" },

        ---- LSP -------------------------------------------------------------------------------------------------------
        LspInlayHint                = { fg = colors.overlay0, bg = colors.base },
        LspCodeLens                 = { link = "LspInlayHint" },
        LspReferenceText            = { link = "Visual" },
        LspReferenceRead            = { link = "Visual" },
        LspReferenceWrite           = { bg = colors.surface0 },
        LspReferenceTarget          = { link = "LspReferenceWrite" },
        SnippetTabstop              = { fg = colors.surface1, bg = colors.base },
        SnippetTabstopActive        = { bg = colors.surface0 },
        LspSignatureActiveParameter = { link = "LspReferenceWrite" },
        LspCodeAction               = { fg = colors.spark },

        ---- DIAGNOSTIC ------------------------------------------------------------------------------------------------
        DiagnosticVirtualTextError = { fg = colors.red, bg = colors.base },
        DiagnosticVirtualTextWarn  = { fg = colors.yellow, bg = colors.base },
        DiagnosticVirtualTextInfo  = { fg = colors.sky, bg = colors.base },
        DiagnosticVirtualTextHint  = { fg = colors.teal, bg = colors.base },
        DiagnosticError            = { fg = colors.red },
        DiagnosticWarn             = { fg = colors.yellow },
        DiagnosticInfo             = { fg = colors.sky },
        DiagnosticHint             = { fg = colors.teal },

        ---- BORDERS ---------------------------------------------------------------------------------------------------
        borderStyle       = { fg = colors.crust, bg = colors.crust },
        borderTop         = { fg = colors.crust, bg = colors.crust },
        borderBottom      = { fg = colors.crust, bg = colors.crust },
        borderLeft        = { fg = colors.crust, bg = colors.crust },
        borderRight       = { fg = colors.crust, bg = colors.crust },
        borderTopEmpty    = { fg = colors.crust, bg = colors.crust },
        borderBottomEmpty = { fg = colors.crust, bg = colors.crust },
        borderLeftEmpty   = { fg = colors.crust, bg = colors.crust },
        borderRightEmpty  = { fg = colors.crust, bg = colors.crust },
        borderStyleNone   = { fg = colors.crust, bg = colors.crust },
        FloatBorder       = { fg = colors.crust1, bg = colors.crust1 },

        ---- SYNTAX ----------------------------------------------------------------------------------------------------
        MatchParen   = { fg = colors.ivory, bg = colors.crust, bold = true, reverse = true },
        Conceal      = { link = "Folded" },
        Comment      = { fg = colors.surface2 },
        Directory    = { fg = colors.ivory },
        Delimiter    = { link = "Comment" },
        Conditional  = { fg = colors.sapphire, italic = true },
        Repeat       = { link = "Conditional" },
        Operator     = { fg = colors.sapphire },
        PreProc      = { fg = colors.pink },
        Define       = { link = "PreProc" },
        Include      = { link = "PreProc" },
        PreCondit    = { link = "PreProc" },
        Function     = { fg = colors.ivory },
        String       = { fg = colors.green },
        Character    = { link = "String" },
        Identifier   = { fg = colors.lavender },
        Keyword      = { fg = colors.yellow, italic = true },
        Exception    = { fg = colors.yellow },
        Constant     = { fg = colors.peach },
        Boolean      = { link = "Constant" },
        Number       = { link = "Constant" },
        Macro        = { link = "Constant" },
        Statement    = { fg = colors.red },
        Structure    = { fg = colors.teal },
        StorageClass = { link = "Structure" },
        Type         = { fg = colors.mauve },
        TypeDef      = { link = "Type" },

        --[[ SEMANTIC TOKENS -------------------------------------------------------------------------------------------
        ["@lsp.type.keyword"]    = { link = "Keyword" },
        ["@lsp.type.class"]      = { link = "Structure" },
        ["@lsp.type.decorator"]  = { link = "Constant" },
        ["@lsp.type.enum"]       = { link = "Constant" },
        ["@lsp.type.enumMember"] = { link = "Constant" },
        ["@lsp.type.macro"]      = { link = "Macro" },
        ["@lsp.type.interface"]  = { link = "Structure" },
        ["@lsp.type.function"]   = { link = "Function" },
        ["@lsp.type.method"]     = { link = "Function" },
        ["@lsp.type.namespace"]  = { link = "Include" },
        ["@lsp.type.parameter"]  = { link = "@typeParameter" },
        ["@lsp.type.property"]   = { link = "Identifier" },
        ["@lsp.type.struct"]     = { link = "Structure" },
        ["@lsp.type.comment"]    = { link = "Comment" },
        ["@lsp.type.type"]       = { link = "Comment" },
        ["@lsp.type.variable"]   = { link = "@variable" },
        --]]

        ---- TREESITTER ------------------------------------------------------------------------------------------------
        ["@comment.todo"]    = { fg = colors.crust, bg = colors.rosewater, italic = false, bold = true }, -- TODO
        ["@comment.note"]    = { fg = colors.crust, bg = colors.blue, italic = false, bold = true },      -- NOTE
        ["@comment.hint"]    = { fg = colors.crust, bg = colors.sky, italic = false, bold = true },       -- HINT
        ["@comment.warning"] = { fg = colors.crust, bg = colors.yellow, italic = false, bold = true },    -- WARNING
        ["@comment.error"]   = { fg = colors.crust, bg = colors.red, italic = false, bold = true },       -- ERROR
        ["@comment.code"]    = { fg = colors.teal, bg = colors.base, italic = false, bold = false },      -- `code`
        ["@comment.bold"]    = { fg = colors.surface2, bold = true },                                     -- BOLD

        ["@punctuation.bracket"]   = { link = "Comment" },
        ["@punctuation.delimiter"] = { link = "Comment" },

        ["@module"]     = { link = "Include" },
        ["@class"]      = { link = "Structure" },
        ["@decorator"]  = { link = "Constant" },
        ["@enum"]       = { link = "Constant" },
        ["@enumMember"] = { link = "Constant" },
        ["@event"]      = { link = "keyword" },
        ["@modifier"]   = { link = "Type" },
        -- ["@typeParameter"] = { fg = colors.maroon },
        ["@namespace"]  = { link = "Function" },
        ["@method"]     = { link = "Function" },
        ["@attribute"]  = { fg = colors.teal },
        ["@label"]      = { link = "Label" },
        ["@error"]      = { link = "Error" },

        ["@type"]           = { link = "Type" },
        ["@type.builtin"]   = { link = "Type" },
        ["@type.qualifier"] = { link = "Type" },

        ["@tag"]           = { fg = colors.red },
        ["@tag.delimiter"] = { fg = colors.sky },
        ["@tag.attribute"] = { fg = colors.teal },

        ["@constant"]         = { link = "Constant" },
        ["@constant.builtin"] = { link = "Constant" },
        ["@constant.macro"]   = { link = "Constant" },

        ["@boolean"]      = { link = "Boolean" },
        ["@number"]       = { link = "Number" },
        ["@number.float"] = { link = "Number" },

        ["aboba"]     = { fg = colors.flamingo },
        ["@keyword"]  = { link = "Keyword" },
        ["@operator"] = { link = "Operator" },

        ["@variable"]           = { fg = colors.red },
        ["@variable.builtin"]   = { link = "Constant" },
        ["@variable.parameter"] = { fg = colors.red },
        ["@variable.member"]    = { fg = colors.ivory },

        ["@function"]             = { link = "Function" },
        ["@function.macro"]       = { link = "Function" },
        ["@function.method"]      = { link = "Function" },
        ["@function.builtin"]     = { link = "Constant" },
        ["@function.method.call"] = { link = "Function" },

        ["@markup"]           = { link = "Special" },
        ["@markup.link.url"]  = { link = "Special" },
        ["@markup.list"]      = { link = "Special" },
        ["@markup.raw"]       = { link = "Special" },
        ["@markup.strong"]    = { link = "Special" },
        ["@markup.underline"] = { link = "Special" },

        ["@keyword.return"]      = { link = "Statement" },
        ["@keyword.repeat"]      = { link = "Conditional" },
        ["@keyword.include"]     = { link = "Include" },
        ["@keyword.function"]    = { link = "Function" },
        ["@keyword.operator"]    = { link = "Operator" },
        ["@keyword.exception"]   = { link = "Exception" },
        ["@keyword.conditional"] = { link = "Conditional" },

        ["@field"]       = { link = "Identifier" },
        ["@property"]    = { link = "Identifier" },
        ["@annotation"]  = { link = "Keyword" },
        ["@conditional"] = { link = "Conditional" },
        ["@constructor"] = { link = "Operator" },
        ["@struct"]      = { link = "Structure" },
        ["@structure"]   = { link = "Structure" },
        ["@interface"]   = { link = "Structure" },

        ["@regexp"]                     = { fg = colors.peach },
        ["@string"]                     = { link = "String" },
        ["@character"]                  = { link = "Character" },
        ["@string.regexp"]              = { link = "@refexp" },
        ["@string.escape"]              = { fg = colors.pink },
        ["@string.special"]             = { link = "@string.escape" },
        ["@string.special.symbol"]      = { link = "@string.escape" },
        ["@string.special.url"]         = { link = "@string.escape" },
        ["@string.special.url.html"]    = { link = "@string.escape" },
        ["@string.special.url.comment"] = { link = "@string.escape" },

}

for group, opts in pairs(groups) do
        vim.api.nvim_set_hl(0, group, opts)
end
vim.hl.priorities.syntax = 200
