; extends

; ([
;         (atx_h1_marker)
;         (atx_h2_marker)
;         (atx_h3_marker)
;         (atx_h4_marker)
;         (atx_h5_marker)
;         (atx_h6_marker)
; ] @conceal
;         (#set! conceal "󰝣"))

(((atx_h1_marker) @conceal.heading.1) (#set! conceal "o"))
(((atx_h2_marker) @conceal.heading.2) (#set! conceal "o"))
(((atx_h3_marker) @conceal.heading.3) (#set! conceal "o"))
(((atx_h4_marker) @conceal.heading.4) (#set! conceal "o"))
(((atx_h5_marker) @conceal.heading.5) (#set! conceal "o"))
(((atx_h6_marker) @conceal.heading.6) (#set! conceal "o"))

(((language) @conceal) (#set! conceal " "))
; (((list_marker_minus) @conceal.list) (#set! conceal "󰨓"))
(((task_list_marker_unchecked) @conceal.unchecked) (#set! conceal ""))
(((task_list_marker_checked) @conceal.checked) (#set! conceal ""))

; ((inline) @)
