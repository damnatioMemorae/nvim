augroup diffcolors
    autocmd!
    autocmd Colorscheme * call s:SetDiffHighlights()
augroup END

function! s:SetDiffHighlights()
    if &background == "dark"
        highlight DiffAdd gui=bold guifg=none guibg=#2e4b2e
        highlight DiffDelete gui=bold guifg=none guibg=#4c1e15
        highlight DiffChange gui=bold guifg=none guibg=#45565c
        highlight DiffText gui=bold guifg=none guibg=#996d74
    else
        highlight DiffAdd gui=bold guifg=none guibg=palegreen
        highlight DiffDelete gui=bold guifg=none guibg=tomato
        highlight DiffChange gui=bold guifg=none guibg=lightblue
        highlight DiffText gui=bold guifg=none guibg=lightpink
    endif
endfunction
