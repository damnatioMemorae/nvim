
" Vim syntax file
" Language: Odin
" Last changed: 2026-05-31

if exists("b:current_syntax")
  finish
endif

" This works assuming idiomatic odin syntax
" Parapoly in particular is a bit confused if the use of the parameter is then
" a constant or a type, I'm undecided too and it would be very hard to make it
" consistent

syntax case match

syn keyword odinStatement do foreign import package defer return continue break
syn keyword odinStatement fallthrough using
syn keyword odinKeyword distinct proc context dynamic
syn keyword odinOperator in not_in cast transmute auto_cast
syn keyword odinOperator or_else or_return or_continue or_break
syn keyword odinRepeat for
syn keyword odinConditional if else switch when where case
syn keyword odinBoolean true false
syn keyword odinStructure matrix struct union enum bit_set bit_field map
" maybe create different groups here? odinBool, odinSignedInt, odinUnisgnedInt ...
syn keyword odinType bool b8 b16 b32 b64
syn keyword odinType int i8 i16 i32 i64 i128
syn keyword odinType uint byte u8 u16 u32 u64 u128 uintptr
syn keyword odinType i16le i32le i64le i128le u16le u32le u64le u128le
syn keyword odinType i16be i32be i64be i128be u16be u32be u64be u128be
syn keyword odinType f16 f32 f64
syn keyword odinType f16le f32le f64le
syn keyword odinType f16be f32be f64be
syn keyword odinType complex32 complex64 complex128
syn keyword odinType quaternion64 quaternion128 quaternion256
syn keyword odinType rune string cstring
syn keyword odinType typeid rawptr any
syn keyword odinNull nil

syn match odinBuiltinProc "\%(abs\|align_of\|cap\|clamp\|complex\|compress_values\|conj\|expand_values\|imag\|jmag\|kmag\|len\|max\|min\|offset_of\|offset_of_by_string\|offset_of_member\|offset_of_selector\|quaternion\|raw_data\|real\|size_of\|soa_unzip\|soa_zip\|swizzle\|type_info_of\|type_of\|typeid_of\)" contained

" TODO: these groups mess with other groups that don't use a \@<=
"syn match odinPtrPtr "\%(\W\)\@3<=^\{-}" display
"syn match odinPtrDeferencing "\^\+\%(\W\)\@=" display

syn match odinTodo "FIXME" display
syn match odinTodo "TODO" display
syn match odinTodo "XXX" display
syn match odinProbablyAType "\<_*[A-Z]\w*\>" display
" in [dynamic; asdf]int 'asdf' should be a Constant
syn match odinConstant "\%(\[dynamic;.\{-}\)\@200<=\h\w*\%(.\{-}]\)\@=" display
syn match odinConstant "_*[A-Z]\w*\ze\s*::" display
syn match odinConstant "\%(\W\)\@3<=_*[A-Z_]\+\ze\%(\W\|$\)" display
" TODO: maybe Tok.kind kind should also be a enum?
syn match odinExplicitEnum "\%(\<_*[A-Z]\w\{-}\.\)\@50<=_*[A-Z]\w*\>" display
syn match odinLabel /\h\w*\ze:\s\{-}for/ display
syn match odinLabel /\h\w*\ze:\s\{-}if/ display
syn match odinLabel /\h\w*\ze:\s\{-}{/ display
syn match odinLabel "\%(\%(break\|continue\|or_continue\|or_break\)\s\+\)\@50<=\zs\h\w*" display

syn match odinAssignOp "=" display
" TODO: DeclareOp also gets the ':' in 'a[1:2]'
syn match odinDeclareOp ":" display
syn match odinArithmeticOp "+\|\*\|/\|%\|-\|!" display
syn match odinVariadicOp "\.\." display
syn match odinBinaryOp "!\|\~\||\|&" display
syn match odinAddressOp "\%([A-Za-z0-9_\]})"']\s*\)\@30<!\s*&" display
syn match odinComparisonOpError +=<\|=>\|=!+ display
syn match odinComparisonOp "==\|!=\|<=\|>=\|&&\|||\|[<>]" display
syn match odinRangeOpError +\%([_'"0-9A-Za-z]\s\{-}\)\@<=\.\.\ze[_'"0-9A-Za-z]+ display
syn match odinRangeOpError +\.\.>\|\.<\|\.>+ display
syn match odinRangeOp "\.\.=\|\.\.<" display
syn match odinBinaryOpError "<>\|><"
syn match odinBinaryOp "<<\|>>" display

" I use \%([A-Za-z0-9_]\)\@! instead of simply \> because if your iskeyword
" includes '-' for example then in '1-2' the '1' would not be caught
syn match odinInteger "\%(^\|\W\)\@3<=\d[0-9_]*\%(i\|j\|k\)\?\%([A-Za-z0-9_]\)\@!" display
syn match odinFloat "\%(^\|\W\)\@3<=\d[0-9_]*\%(\.\d[0-9_]*\%([eE][+-]\?\d[0-9_]*\)\?\|[eE][+-]\?\d[0-9_]*\)\%(i\|j\|k\)\?\%([A-Za-z0-9_]\)\@!" display
" never knew hex floats were a thing (and it sometimes gives compiler errors as of dev-2026-05)
" but it's documented in the official EBNF file in the odin repo
syn match odinHexFloat "\%(^\|\W\)\@3<=0h\x[0-9A-Fa-f_]*\%([A-Za-z0-9_]\)\@!" display
" Hex, Oct, and Bin can't be floats or imaginary
syn match odinBin "\%(^\|\W\)\@3<=0b[01][01_]*\%([A-Za-z0-9_]\)\@!" display
syn match odinOct "\%(^\|\W\)\@3<=0o\o[0-7_]*\%([A-Za-z0-9_]\)\@!" display
syn match odinHex "\%(^\|\W\)\@3<=0x\x[0-9A-Fa-f_]*\%([A-Za-z0-9_]\)\@!" display

syn match odinImplicitEnum "\%([^\])0-9A-Za-z_]\+\)\@<=\.\h\w*" display
syn match odinEnumDef "\<\h\w*" contained
syn match odinEnumDefConstant "\%(=\s*\)\@<=\h\w*" contained
" have to duplicate here because you can't set an enum to an imaginary or quaternion
syn match odinIntNotImg "\%(^\|\W\)\@3<=\zs\d[0-9_]*\>" display contained
syn region odinEnumDefinition start="\(:\s*enum.\{-}\)\@200<=\zs{"ms=e+1 end="}"me=s-1 contains=odinEnumDef,odinIntNotImg,odinRangeOp,odinRangeOpError,odinComment,odinCommentBlock,odinEnumDefConstant

syn match odinProcCall "\<[a-z_]\w*\ze\_s*(" display contains=odinBuiltinProc

syn match odinAllConst "[A-Z_]\w*" contained display
syn match odinCustomType "[A-Z_]\w*\ze(" contained display
syn match odinPtrType "\^\%(\h\w*\.\)*\zs[A-Z_]\w*" display
syn region odinCustomTypeRegion matchgroup=odinType start="\%([^:]:\s*\%(\h\w\.\)*\)\@50<=\h\w*\ze(\|\<_*[A-Z]\w*\ze("ms=e+1 matchgroup=NONE end=+)+me=s-1 contains=odinAllConst,odinParapoly,odinInteger,odinArithmeticOp,odinCustomType,odinType

syn match odinTypeDeclaration "[^:]:\s*\%(\[.*\]\)*\s*\%(\h\w*\.\)*\zs[A-Z_]\w*" display
syn match odinTypeDeclaration "\%(=\s*\)\@30<=\h\w*\ze{.\{-}\%(}\|$\)" display
syn match odinTypeDefinition "\h\w*\ze\s*::\s*\%(distinct\|struct\|union\|enum\|bit_field\|bit_set\)"

" TODO: 'case utf8.RUNE_EOF:' RUNE_EOF should be a constant
" maybe make this a region?
"syn match odinSwitchUnion "\%(case.\{-}\)\@30<=[A-Z_]\w*\ze\s*:" display
"syn region odinParapolyConst start=+(+ end=+)+ contained contains=odinAllConst,odinParapolyConst,odinInteger,odinArithmeticOp,odinCustomType
syn region odinParapolyConst start=+\%(_*[A-Z]\w*\)\@30<=(+ end=+)+ contains=odinAllConst,odinParapolyConst,odinInteger,odinArithmeticOp,odinCustomType,odinParapoly
syn match odinParapoly "\$\h\w*" display
syn match odinImplicitAssertion +\%(\w\.\)\@4<=?+ display
syn region odinUnionAssertType start="\%(\h\w\{-}\.\)\@50<=("ms=e+1 end=")"me=s-1 contains=odinInteger,odinConstant,@odinTypes,odinCustomType,odinParapolyConst
syn match odinReturnType "\%(->\s*\)\@100<=(\?\zs[A-Z_]\w*\ze)\?" display

syn region odinRelaxedCustomTypeRegion matchgroup=odinType start="\<\h\w*\ze(" matchgroup=NONE end=+)+me=s-1 contains=odinAllConst,odinParapoly,odinInteger,odinArithmeticOp,odinCustomType,odinType contained
syn region odinUnionDefinition start="\%(:\s*union.\{-}\)\@200<=\zs{"ms=e+1 end="}"me=s-1 contains=odinComment,odinCommentBlock,@odinTypes,odinRelaxedCustomTypeRegion,odinProbablyAType
syn match odinParapolySpecType "\%(\$.\{-}/\)\@50<=[A-Z_]\w*" display

syn match odinProcName "\h\w*\ze\s*::\s*proc" display
syn match odinDirective "#\s*\h\w\{-}\>" display
syn region odinTernaryRegion matchgroup=odinTernary start="?" end=":" oneline contains=ALL display
syn match odinTernary "[?:]" contained transparent display

syn match odinAttribute "@\h\w*"
syn match odinAttribute "@(\h\w\{-}" contained display
syn match odinAttribute ")" contained transparent display
syn region odinAttributeRegion matchgroup=odinAttribute start="@(\h\w*\>" skip=+".\{-}).\{-}"+ end=")" contains=odinString,odinBoolean,@odinTypes,odinConstant,odinComparisonOp,odinComaparisonOpError,odinBinaryOp oneline display

syn match odinBuildTag "^\s*#+\%(build\|vet\|test\|ignore\|private\|feature\|no-instrumentation\)" display
syn region odinBuildTagRegion matchgroup=odinBuildTag start="^\s*#+\%(build\|vet\|test\|ingnore\|private\|feature\|no-instrumentation\)" matchgroup=NONE end="$" oneline display

syn region odinComment start="//" end="$" oneline contains=odinTodo
syn region odinComment start="#!" end="$" oneline contains=odinTodo
syn region odinCommentBlock start=/\/\*/ end=/\*\// contains=odinCommentBlock,odinTodo

syn match odinEscapeChar /\\[abefnrtv"']\|\\\o\{3}\|\\x\x\{2}\|\\u\x\{4}\|\\U\x\{8}\|\\\\/ contained display
" TODO: figure out how to do the error
"syn match odinEscapeError /\\[^abefnrtv"']\|\\\%(\o\{,2}\|\o\{4,}\)\|\\x\%(\x\{3}\|\x\+\)\|\\u\x\{5,7}\|\\U\x\{9,}/ contained display
"syn match odinEscapeError /\\[^abefnrtv"']/ contained
syn region odinString start=/"/ skip=/\\"/ end=/"/ contains=odinEscapeChar oneline
syn region odinRawString start=+`+ end=+`+
syn region odinCharacter start=+'+ end=+'+ contains=odinEscapeChar oneline

" I think the minimum path is ".."
syn match odinImportPath +\%(\%(^\|\*/\)\s*\%(foreign\)\?\s*import.\{-}\)\@90<=".\{2,}"+ display
syn match odinPackageDeclaration "\(^package\)\@<=\s\+\h\w*" display

syn match odinCallingConventionError +\%(:\s*proc\s*\)\@90<=".*"+ display
syn match odinCallingConvention +\%(:\s*proc\s*\)\@200<="\%(std\%(call\)\?\|odin\|c\%(decl\)\?\|none\|contextless\|fast\%(call\)\?\)"+ display
syn match odinUndefined "---\ze\s*$" display
syn match odinVoidAssign "\<_\>" display
syn match odinProcRet "->" display

syn cluster odinOperators contains=odinOperator,odinArithmeticOp,odinRangeOp,odinComparisonOp
syn cluster odinTypes contains=odinType,odinTypeDefinition,odinTypeDeclaration,odinPtrType,odinReturnType
syn cluster odinNumbers contains=odinInteger,odinBin,odinOct,odinHex

hi def link odinPtrType odinType
hi def link odinTypeDeclaration odinType
hi def link odinTypeDefinition odinType
hi def link odinNull odinType
hi def link odinReturnType odinType
hi def link odinCustomType odinType
hi def link odinParapolySpecType odinType
hi def link odinSwitchUnion odinType
hi def link odinProbablyAType odinType

hi def link odinType Type

"hi def link odinPtrType Type
"hi def link odinTypeDeclaration Type
"hi def link odinTypeDefinition Type
"hi def link odinNull Type
"hi def link odinReturnType Type
"hi def link odinCustomType Type
"hi def link odinParapolySpecType Type
"hi def link odinSwitchUnion Type
"hi def link odinProbablyAType Type

hi def link odinOperator Operator
hi def link odinComparisonOp Operator
hi def link odinComparisonOpError Error
hi def link odinArithmeticOp Operator
hi def link odinBinaryOp Operator
hi def link odinAddressOp Operator
hi def link odinBinaryOpError Error
hi def link odinRangeOp Operator
hi def link odinRangeOpError Error
hi def link odinVariadicOp Operator

hi def link odinExplicitEnum Number
hi def link odinImplicitEnum Number
hi def link odinEnumDef Number
hi def link odinInteger Number
hi def link odinIntNotImg Number
hi def link odinBin Number
hi def link odinOct Number
hi def link odinHex Number
hi def link odinFloat Float
hi def link odinHexFloat Float

hi def link odinString String
hi def link odinRawString String
hi def link odinEscapeChar Special
hi def link odinCharacter Character
"hi def link odinEscapeError Error

hi def link odinBoolean Boolean
hi def link odinStatement Statement
hi def link odinKeyword Keyword
hi def link odinRepeat Repeat
hi def link odinConditional Conditional
hi def link odinTernary Conditional
hi def link odinStructure Structure
hi def link odinConstant Constant
hi def link odinEnumDefConstant Constant
hi def link odinAllConst Constant
hi def link odinParapoly Constant
hi def link odinProcCall Function
hi def link odinBuiltinProc Function
hi def link odinComment Comment
hi def link odinCommentBlock Comment
hi def link odinTodo Todo

hi def link odinLabel Special
hi def link odinAttribute Macro
hi def link odinBuildTag Macro
hi def link odinDirective Define
hi def link odinCallingConvention Define
hi def link odinCallingConventionError Error

syn sync ccomment odinCommentBlock

let b:current_syntax = "odin"
