function! TalkFold(lnum)
    let l:line = getline(a:lnum)
    
    if l:line =~ '^\s*>'
        let l:level = (indent(a:lnum) / 4) + 1
        return '>' . l:level
    endif
    
    if l:line =~ '^\s*$'
        let l:next_lnum = nextnonblank(a:lnum)
        if l:next_lnum == 0
            return '0'
        endif
        
        let l:next_line = getline(l:next_lnum)
        if l:next_line =~ '^\s*>'
            let l:next_level = (indent(l:next_lnum) / 4) + 1
            let l:target_level = l:next_level - 1
            return l:target_level < 0 ? '0' : string(l:target_level)
        endif
        
        return '0'
    endif
    
    if l:line =~ '^-\+$' || (l:line =~ '^\S' && l:line !~ '^>')
        return '0'
    endif
    
    return '='
endfunction

setlocal foldmethod=expr
setlocal foldexpr=TalkFold(v:lnum)
setlocal foldlevelstart=0

setlocal foldminlines=0

function! s:ToggleTalkFold()
    if foldclosed('.') != -1
        silent! normal! zo
    else
        silent! normal! zC
    endif
endfunction

nnoremap <buffer> <silent> <CR> :call <SID>ToggleTalkFold()<CR>

augroup TalkFoldGroup
    autocmd! * <buffer>
    autocmd BufEnter <buffer> set foldopen=
    autocmd BufLeave <buffer> set foldopen&
augroup END
