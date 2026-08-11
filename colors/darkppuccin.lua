local g   = vim.g
local o   = vim.o
local fn  = vim.fn
local cmd = vim.cmd
local api = vim.api

local _linq = _linq

local function h(name)
        return function(opts)
                api.nvim_set_hl(0, name, opts)
        end
end

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
local M = {}
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

cmd "highlight clear"

if fn.exists "syntax_on" then
        cmd "syntax reset"
end

o.termguicolors = true
g.colors_name   = "darkppuccin"

M.colors = {
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
        mantle0   = "#191927",
        mantle1   = "#14141f",
        crust1    = "#11111b",
        crust0    = "#0e0e16",
        -- crust0    = "#0e0d0d",

        -- green_transparent  = "#1d2324",
        -- yellow_transparent = "#262325",
        -- red_transparent    = "#251b25",

        -- green_transparent  = "#3c4e40",
        -- yellow_transparent = "#554e44",
        -- red_transparent    = "#533342",

        teal_transparent   = "#273741",
        sky_transparent    = "#29383c",
        green_transparent  = "#2c3932",
        yellow_transparent = "#3d3835",
        red_transparent    = "#3c2733",
}

local colors = M.colors

g.terminal_color_0          = colors.crust0
g.terminal_color_1          = colors.red
g.terminal_color_2          = colors.green
g.terminal_color_3          = colors.yellow
g.terminal_color_4          = colors.lavender
g.terminal_color_5          = colors.pink
g.terminal_color_6          = colors.sky
g.terminal_color_7          = colors.text
g.terminal_color_8          = colors.base
g.terminal_color_9          = colors.maroon
g.terminal_color_10         = colors.green
g.terminal_color_11         = colors.peach
g.terminal_color_12         = colors.sapphire
g.terminal_color_13         = colors.mauve
g.terminal_color_14         = colors.teal
g.terminal_color_15         = colors.subtext0
g.terminal_color_background = colors.crust0
g.terminal_color_foreground = colors.text

---- COMMENTS ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
h "@comment.todo" { fg = colors.crust0, bg = colors.rosewater, italic = true, bold = true } -- TODO:
h "@comment.note" { fg = colors.crust0, bg = colors.blue, italic = true, bold = true }      -- NOTE: XXX:
h "@comment.hint" { fg = colors.crust0, bg = colors.sky, italic = true, bold = true }       -- HINT: WIP:
h "@comment.warning" { fg = colors.crust0, bg = colors.yellow, italic = true, bold = true } -- WARNING:
h "@comment.error" { fg = colors.crust0, bg = colors.red, italic = true, bold = true }      -- FIXME:
h "@comment.code" { fg = colors.teal, bg = colors.base, italic = false, bold = false }      -- `code`
h "@comment.url" { link = "@markup.link.url" }                                              -- https://google.com
h "@comment.bold" { fg = colors.surface2, bold = true }                                     -- BOLD
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

---- DIANGOSTICS ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------
h "DiagnosticError" { fg = colors.red }
h "DiagnosticWarn" { fg = colors.yellow }
h "DiagnosticInfo" { fg = colors.sky }
h "DiagnosticHint" { fg = colors.teal }
h "DiagnosticOk" { fg = colors.green }

h "DiagnosticUnderlineError" { bg = colors.base }
h "DiagnosticUnderlineWarn" { bg = colors.base }
h "DiagnosticUnderlineInfo" { bg = colors.base }
h "DiagnosticUnderlineHint" { bg = colors.base }
h "DiagnosticUnderlineOk" { bg = colors.base }

h "DiagnosticVirtualTextError" { fg = colors.red, bg = colors.red_transparent }
h "DiagnosticVirtualTextWarn" { fg = colors.yellow, bg = colors.yellow_transparent }
h "DiagnosticVirtualTextInfo" { fg = colors.sky, bg = colors.sky_transparent }
h "DiagnosticVirtualTextHint" { fg = colors.teal, bg = colors.teal_transparent }
h "DiagnosticVirtualTextOk" { fg = colors.green, bg = colors.green_transparent }

h "SymbolDef" { fg = colors.spark, bg = colors.crust0 }
h "SymbolRef" { fg = colors.red, bg = colors.crust0 }
h "SymbolImp" { fg = colors.teal, bg = colors.crust0 }

h "DiagnosticUnnecessary" { link = "Comment" }
h "DiagnosticDeprecated" { strikethrough = true }
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

_linq
"DiagnosticError"
           "DiagnosticVirtualLinesError"
           "DiagnosticFloatingError"
           "DiagnosticSignError"
           "DiffDelete"
           "DiffRemoved"
           "SpellBad"

_linq
"DiagnosticWarn"
           "DiagnosticVirtualLinesWarn"
           "DiagnosticFloatingWarn"
           "DiagnosticSignWarn"
           "DiffChange"
           "DiffChanged"
           "SpellCap"
           "WarningMsg"

_linq
"DiagnosticInfo"
           "DiagnosticVirtualLinesInfo"
           "DiagnosticFloatingInfo"
           "DiagnosticSignInfo"
           "SpellRare"

_linq
"DiagnosticHint"
           "DiagnosticVirtualLinesHint"
           "DiagnosticFloatingHint"
           "DiagnosticSignHint"
           "DiffText"

_linq
"DiagnosticOk"
           "DiagnosticVirtualLinesOk"
           "DiagnosticFloatingOk"
           "DiagnosticSignOk"
           "DiffAdd"
           "DiffAdded"
           "OkMsg"
           "ModeMsg"
           "SpellLocal"

_linq
"DiagnosticDeprecated"
           "LspAbbrDeprecated"

---- SEARCH --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
h "Search" { bg = colors.yellow_transparent }
h "CurSearch" { fg = colors.yellow, reverse = true }
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

_linq --> colors.yellow,
"CurSearch"
           "IncSearch"
           "Substitute"

---- GENERAL -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
h "Normal" { bg = colors.crust0 }
h "NormalFloat" { bg = colors.mantle1 }
h "NonText" { fg = colors.surface0 }
h "Underlined" { underline = true }
h "Dimmed" { dim = true }
h "Todo" { bg = colors.rosewater, bold = true }
h "Directory" { fg = colors.ivory }
h "Visual" { bg = colors.surface0 }
h "CursorLine" { fg = "NONE", bg = "NONE" }
h "CursorLineNr" { fg = colors.ivory }
h "Border" { fg = colors.crust0, bg = colors.crust0 }
-- h "FloatBorder" { fg = colors.crust1, bg = colors.crust1 }
h "Backdrop" { bg = "#000000" }
h "FoldTextInner" { fg = colors.surface2 }
h "StatusLine" { bg = colors.mantle0 }
h "QfText" { fg = colors.subtext0 }
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

_linq --> Special
"Title"
           "FloatTitle"
           "FloatFooter"

_linq --> Special
"NormalFloat"
           "FloatBorder"

_linq --> NONE
"CursorLine"
           "Folded"

_linq --> colors.surface2 colors.mantle0
"LspCodeLens"
           "FoldText"

_linq --> colors.crust0
"Normal"
           "NormalNC"
           "Ignore"
           "StdoutMsg"
           "WinBar"

_linq --> colors.surface1
"NonText"
           "LineNr"
           "SignColumn"
           "ComplHint"
           "Whitespace"
           "WinSeparator"
           "EndOfBuffer"

_linq --> colors.surface0
"Visual"
           "ColorColumn"
           "CursorColumn"
           "LspReferenceText"
           "QuickFixLine"
           "SnippetTabstop"
           "SnippetTabstopActive"
           "VisualNOS"
           "PmenuSel"
           "PmenuThumb"
           "MatchParen"

_linq --> Normal
"StatusLine"
           "StatusLineTerm"
           "MsgSeparator"
           "StatusLineNC"

_linq --> StatusLine
"WinSeparator"
           "VertSplit"

_linq --> StatusLine
"StatusLineNC"
           "TabLine"
           "StatusLineTermNC"

_linq --> Normal
"WinBar"
           "WinBarNC"

_linq --> NonText
"SignColumn"
           "CursorLineSign"

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
h "LspCodeLens" { fg = colors.surface2, bg = colors.base }
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

_linq --> colors.surface2 colors.mantle0
"LspCodeLens"
           "LspInlayHint"

_linq --> Visual
"LspReferenceText"
           "LspReferenceRead"
           "LspReferenceTarget"
           "LspReferenceWrite"
           "LspSignatureActiveParameter"

---- PMENU ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
h "Pmenu" { bg = colors.mantle1 }
h "PmenuDoc" { bg = colors.base }
h "PmenuMatch" { bold = true }
h "FloatShadow" { bg = colors.surface1, blend = 80 }
h "FloatShadowThrough" { bg = colors.surface1, blend = 100 }
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

_linq --> colors.crust1
"Pmenu"
           "PmenuBorder"
           "PmenuExtra"
           "PmenuKind"
           "PmenuSbar"

_linq --> Visual
"PmenuSel"
           "PmenuKindSel"
           "PmenuExtraSel"

_linq --> bold
"PmenuMatch"
           "PmenuMatchSel"

_linq --> Pmenu
"PmenuSbar"
           "PmenuThumb"

_linq --> Pmenu
"FloatShadow"
           "PmenuShadow"

_linq --> Pmenu
"FloatShadowThrough"
           "PmenuShadowThrough"

---- SYNTAX --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
h "Conditional" { fg = colors.sapphire, italic = true }
h "Identifier" { fg = colors.lavender }
h "Delimiter" { fg = colors.surface2 }
h "Operator" { fg = colors.sapphire }
h "Comment" { fg = colors.surface2 }
h "Function" { fg = colors.ivory }
h "Constant" { fg = colors.peach }
h "Keyword" { fg = colors.yellow, italic = true }
h "Special" { fg = colors.pink }
h "PreProc" { fg = colors.pink }
h "String" { fg = colors.green }
h "Type" { fg = colors.mauve }
h "Conceal" { fg = "NONE", bg = "NONE" }
h "Statement" { fg = colors.red }
h "Error" { fg = colors.red }
h "Label" { fg = colors.red }
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

_linq --> colors.sapphire
"Conditional"
           "Repeat"
           "@conditional"
           "@keyword.conditional"
           "@keyword.repeat"

_linq --> colors.lavender
"Identifier"
           "NvimIdentifier"
           "@property"

_linq --> colors.sapphire
"Operator"
           "NvimAssignment"
           "NvimOperator"
           "@operator"
           "@keyword.operator"
           "@lsp.type.operator"

_linq --> colors.surface2
"Delimiter"
           "NvimParenthesis"
           "NvimColon"
           "NvimComma"
           "NvimArrow"
           "@punctuation"

_linq --> colors.surface2
"Comment"
           "MoreMsg"
           "@comment"
           "@lsp.type.comment"

_linq --> colors.yellow
"Keyword"
           "@keyword"
           "@lsp.type.keyword"

_linq --> colors.mauve
"Type"
           "Typedef"
           "Structure"
           "StorageClass"
           "NvimNumberPrefix"
           "NvimOptionSigil"
           "@type"

_linq --> colors.ivory
"Function"
           "@function"
           "@keyword.function"
           "@variable.member"
           "@namespace"
           "@lsp.type.namespace"

_linq --> colors.peach
"Constant"
           "Number"
           "Boolean"
           "@constant"
           "@boolean"
           "@number"

_linq --> colors.green
"String"
           "NvimString"
           "@string"

_linq --> colors.pink
"Special"
           "Title"
           "Character"
           "SpecialKey"
           "Tag"
           "SpecialComment"
           "SpecialChar"
           "Debug"
           "@tag"
           "@attribute"
           "@constructor"
           "@punctuation.special"
           "@variable.builtin"
           "@module.builtin"

_linq --> colors.pink
"PreProc"
           "Include"
           "Define"
           "Macro"
           "PreCondit"
           "@keyword.include"
           "@lsp.type.macro"

_linq --> colors.red
"Error"
           "NvimInvalid"
           "NvimInternalError"
           "ErrorMsg"
           "@error"

_linq --> colors.red
"Label"
           "@variable"
           "@variable.parameter"
           "@variable.parameter.builtin"
           "@lsp.type.variable"
           "@lsp.type.parameter"

_linq --> colors.red
"Statement"
           "Exception"
           "@keyword.return"
           "@keyword.exception"

_linq --> Type
"Structure"
           "@struct"
           "@structure"
           "@module"
           "@lsp.type.struct"

_linq --> Special
"SpecialChar"
           "NvimRegister"
           "NvimRegister"
           "luaSpecial"
           "QfLineNr"
           "@string.special"

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

_linq --> Conceal
"@conceal"
           "@conceal.heading.1"
           "@conceal.heading.2"
           "@conceal.heading.3"
           "@conceal.heading.4"
           "@conceal.heading.5"
           "@conceal.heading.6"
           "@conceal.unchecked"
           "@conceal.checked"
           "@conceal.list"

_linq --> Constant
"@constant"
           "@function.builtin"
           "@constant.builtin"
           "@constant.macro"
           "@enum"
           "@enumMember"
           "@lsp.type.enum"
           "@lsp.type.enumMember"

_linq --> Type
"@tag"
           "@tag.builtin"
           "@tag.delimiter"
           "@tag.attribute"
           "@attribute.builtin"

_linq --> Number
"@number"
           "@number.float"
           "@lsp.type.number"

_linq --> Type
"@type"
           "@type.builtin"
           "@type.qualifier"
           "@type.builtin.luadoc"
           "@lsp.type.type"

_linq --> Function
"@function"
           "@method"
           "@function.macro"
           "@function.method"
           "@function.method.call"
           "@lsp.type.function"
           "@lsp.type.method"

_linq --> Special
"@attribute"
           "@attribute.builtin"

_linq --> Character
"@character"
           "@character.special"

_linq --> Identifier
"@property"
           "@field"
           "@lsp.type.property"

_linq --> SpecialChar
"@string.special"
           "@string.regex"
           "@string.escape"
           "@string.special.url"
           "@lsp.type.string"

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
h "Added" { fg = colors.green }
h "Changed" { fg = colors.yellow }
h "Removed" { fg = colors.red }
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

_linq --> colors.green
"Added"
           "@diff.plus"
           "PreInsert"

_linq --> colors.yellow
"Changed"
           "@diff.minus"

_linq --> colors.red
"Removed"
           "@diff.delta"

-- "@markup"
-- "@markup.heading"                    = { link      = "Title"          },
-- "@markup.heading.1.delimiter.vimdoc"
-- "@markup.heading.1.markdown"         = { fg        = colors.ivory,    bg        = colors.base, bold = false },
-- "@markup.heading.2.delimiter.vimdoc"
-- "@markup.heading.2.markdown"         = { fg        = colors.subtext1, bg        = colors.base, bold = false },
-- "@markup.heading.3.markdown"         = { fg        = colors.overlay2, bg        = colors.base, bold = false },
-- "@markup.heading.4.markdown"         = { fg        = colors.overlay1, bg        = colors.base, bold = false },
-- "@markup.heading.5.markdown"         = { fg        = colors.overlay0, bg        = colors.base, bold = false },
-- "@markup.heading.6.markdown"         = { fg        = colors.surface2, bg        = colors.base, bold = false },
-- "@markup.italic"
-- "@markup.italic.markdown_inline"     = { underline = true             },
-- "@markup.link"                       = { link      = "Underlined"     },
-- "@markup.link.label.markdown_inline" = { fg        = colors.spark,    underline = true         },
-- "@markup.link.url"
-- "@markup.list"
-- "@markup.raw"                        = { fg        = colors.teal      },
-- "@markup.strikethrough"
-- "@markup.strong"
-- "@markup.underline"

-- "@lsp"
-- "@lsp.mod.deprecated"
-- "@lsp.type.class"
-- "@lsp.type.decorator"
-- "@lsp.type.event"
-- "@lsp.type.interface"
-- "@lsp.type.modifier"
-- "@lsp.type.regexp"
-- "@lsp.type.typeParameter"

--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
return M
