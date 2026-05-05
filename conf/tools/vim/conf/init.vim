let s:__HERE = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:__SCRIPTS = s:__HERE . '/scripts'
let s:__OTHER   = s:__HERE . '/other'

let s:GLOBALS   = ['base.vim', 'keys.vim', 'ai.vim']
let s:FILETYPES = ['python', 'markdown']

function! s:__source(path)
    execute 'source ' . s:__SCRIPTS . '/' . a:path
endfunction

function! s:__globals()
    for script in s:GLOBALS
        call s:__source(script)
    endfor
endfunction

function! s:__filetypes()
    for ft in s:FILETYPES
        execute 'autocmd FileType ' . ft . ' call s:__source("' . ft . '.vim")'
    endfor
endfunction

function! s:__init__()
    call s:__globals()
    call s:__filetypes()
endfunction

call s:__init__()
