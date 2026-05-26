let s:__HERE = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:__SCRIPTS = s:__HERE . '/scripts'
let s:__OTHER   = s:__HERE . '/other'

let s:GLOBALS   = ['base', 'keys', 'lsp', 'helper/remember']
let s:FILETYPES = ['python', 'markdown', 'ai', 'sh']

function! s:EnableIndentLines()
    setlocal list
    
    let l:indent_size = &softtabstop > 0 ? &softtabstop : shiftwidth()
    
    if l:indent_size == 0
        let l:indent_size = &tabstop
    endif
    
    if &expandtab
        let l:space_pattern = '│' . repeat('\ ', l:indent_size - 1)
        execute 'setlocal listchars=tab:│\ ,leadmultispace:' . l:space_pattern
    else
        setlocal listchars=tab:│\ 
    endif
    
    highlight! link Whitespace Comment
    highlight! link SpecialKey Comment
    highlight! link NonText Comment
endfunction

augroup IndentLines
    autocmd!
    autocmd FileType,BufWinEnter * call s:EnableIndentLines()
    autocmd OptionSet shiftwidth,tabstop,softtabstop,expandtab call s:EnableIndentLines()
augroup END

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
        execute 'autocmd BufEnter *.' . ft . ' set filetype='. ft 
    endfor
endfunction

function! s:__init__()
    call s:__globals()
    call s:__filetypes()
    autocmd BufEnter * startinsert
endfunction

call s:__init__()
