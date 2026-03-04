(pair
  key: (bare_key) @_key
  value: (multiline_basic_string) @bash
  (#match? @_key "^(run|script|cmd|command)$")
  (#set! injection.language "bash"))
