if exists("current_compiler")
  finish
endif
let current_compiler = "odin"

CompilerSet makeprg=odin\ build\ %:p:h

CompilerSet errorformat=
      \%f(%l:%c)\ %t%*[^:]:\ %m,
      \%f(%l:%c:%*\\d:%*\\d)\ %t%*[^:]:\ %m,
      \%-G%.%#Running%.%#,
      \%-G%.%#
