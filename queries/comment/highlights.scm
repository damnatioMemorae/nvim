("text" @comment.hint @nospell
        (#any-of? @comment.hint "HINT" "WIP")
        (#set! "priority" 135 ))

("text" @comment.todo @nospell
        (#any-of? @comment.todo "TODO" "WIP")
        (#set! "priority" 135 ))

("text" @comment.note @nospell
        (#any-of? @comment.note "NOTE" "XXX" "INFO" "DOCS" "PERF" "TEST")
        (#set! "priority" 135 ))

("text" @comment.warning @nospell
        (#any-of? @comment.warning "HACK" "WARNING" "WARN" "FIX")
        (#set! "priority" 135 ))

("text" @comment.error @nospell
        (#any-of? @comment.error "FIXME" "BUG" "ERROR")
        (#set! "priority" 135 ))

("text" @number
        (#lua-match? @number "^#[0-9]+$"))

(uri) @string.special.url @nospell

("text" @comment.bold
        (#lua-match? @comment.bold "^%u[%u%d_]+$"))

("text" @comment.code @nospell
        (#lua-match? @comment.code "`([^`]+)`"))
