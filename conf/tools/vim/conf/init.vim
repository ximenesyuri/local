let s:__HERE = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:__SCRIPTS = s:__HERE . '/scripts'
let s:__OTHER   = s:__HERE . '/other'

let s:GLOBALS   = ['base', 'keys', 'ai', 'lsp', 'helper/remember']
let s:FILETYPES = ['python', 'markdown']

function! s:EnableIndentLines()
    setlocal list
    
    let l:indent_size = &shiftwidth > 0 ? &shiftwidth : &tabstop
    
    let l:space_pattern = '│' . repeat('\ ', l:indent_size - 1)
    
    execute 'setlocal listchars=tab:│\ ,leadmultispace:' . l:space_pattern
    
    highlight! link Whitespace Comment
    highlight! link SpecialKey Comment
    highlight! link NonText Comment
endfunction

function! s:__source(path)
    execute 'source ' . s:__SCRIPTS . '/' . a:path . '.vim'
endfunction

function! s:__globals()
    for script in s:GLOBALS
        call s:__source(script)
    endfor
endfunction

function! s:__filetypes()
    for ft in s:FILETYPES
        execute 'autocmd FileType ' . ft . ' call s:__source("filetype/' . ft . '")'
    endfor
endfunction

function! s:__init__()
    call s:__globals()
    call s:__filetypes()
    call s:EnableIndentLines()
    autocmd BufEnter * startinsert
endfunction

call s:__init__()
