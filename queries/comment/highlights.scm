((tag
        (name) @comment.code @nospell
        ("(" @punctuation.bracket
                (user) @constant
                ")" @punctuation.bracket)?
        ":" @punctuation.delimiter)
        ; (#any-of? @comment.code "HINT" "WIP"))
        (#match? @comment.code "'[^']*'"))

("text" @comment.code @nospell
        ; (#any-of? @comment.code "HINT" "WIP"))
        (#match? @comment.code "'[^']*'"))

; ("text" @comment.code
        ; (#eq? @comment.code "!")
        ; (#match? @issue "^[0-9]+$"))
        ; (#match? @issue "'[^']*'"))

((tag
        (name) @comment.hint @nospell
        ("(" @punctuation.bracket
                (user) @constant
                ")" @punctuation.bracket)?
        ":" @punctuation.delimiter)
        (#any-of? @comment.hint "HINT" "WIP"))

("text" @comment.hint @nospell
        (#any-of? @comment.hint "HINT" "WIP"))

((tag
        (name) @comment.todo @nospell
        ("(" @punctuation.bracket
                (user) @constant
                ")" @punctuation.bracket)?
        ":" @punctuation.delimiter)
        (#any-of? @comment.todo "TODO" "WIP"))

("text" @comment.todo @nospell
        (#any-of? @comment.todo "TODO" "WIP"))

((tag
        (name) @comment.note @nospell
        ("(" @punctuation.bracket
                (user) @constant
                ")" @punctuation.bracket)?
        ":" @punctuation.delimiter)
        (#any-of? @comment.note "NOTE" "XXX" "INFO" "DOCS" "PERF" "TEST"))

("text" @comment.note @nospell
        (#any-of? @comment.note "NOTE" "XXX" "INFO" "DOCS" "PERF" "TEST"))

((tag
        (name) @comment.warning @nospell
        ("(" @punctuation.bracket
                (user) @constant
                ")" @punctuation.bracket)?
        ":" @punctuation.delimiter)
        (#any-of? @comment.warning "HACK" "WARNING" "WARN" "FIX"))

("text" @comment.warning @nospell
        (#any-of? @comment.warning "HACK" "WARNING" "WARN" "FIX"))

((tag
        (name) @comment.error @nospell
        ("(" @punctuation.bracket
                (user) @constant
                ")" @punctuation.bracket)?
        ":" @punctuation.delimiter)
        (#any-of? @comment.error "FIXME" "BUG" "ERROR"))

("text" @comment.error @nospell
        (#any-of? @comment.error "FIXME" "BUG" "ERROR"))

; Issue number (#123)
("text" @number
        (#lua-match? @number "^#[0-9]+$"))

(uri) @string.special.url @nospell
