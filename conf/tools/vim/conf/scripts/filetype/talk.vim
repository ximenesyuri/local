function! TalkFold(lnum)
    let l:line = getline(a:lnum)
    
    if l:line =~ '^>'
        return '>1'
    endif
    
    if l:line =~ '^\s\+\S'
        return '1'
    endif
    
    if l:line =~ '^\s*$'
        return '='
    endif
    
    return '0'
endfunction

setlocal foldmethod=expr
setlocal foldexpr=TalkFold(v:lnum)
setlocal foldlevelstart=0

setlocal foldminlines=1

nnoremap <buffer> <silent> <CR> za

augroup TalkFoldGroup
    autocmd! * <buffer>
    autocmd BufEnter <buffer> set foldopen=
    autocmd BufLeave <buffer> set foldopen&
augroup END
