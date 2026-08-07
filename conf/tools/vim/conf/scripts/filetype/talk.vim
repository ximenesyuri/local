" Define flat folding rules based strictly on root lines
function! TxtPresentationFold(lnum)
    let l:line = getline(a:lnum)
    
    " Rule 1: Match '>' or ordered markers like '1>', '2>', '10>' at the root.
    " \d* matches zero or more digits. This starts the single flat fold.
    if l:line =~ '^\d*>'
        return '>1'
    endif
    
    " Rule 2: Lines with ANY indentation (starts with whitespace).
    " These are all bundled into the single root fold jointly.
    if l:line =~ '^\s\+\S'
        return '1'
    endif
    
    " Rule 3: Blank lines inherit the fold level so the block remains unbroken.
    if l:line =~ '^\s*$'
        return '='
    endif
    
    " Rule 4: Unindented plain text (like 'course:', 'tasks:', or '---') 
    " gracefully resets the fold to 0, separating the blocks.
    return '0'
endfunction

" Apply the folding rules
setlocal foldmethod=expr
setlocal foldexpr=TxtPresentationFold(v:lnum)
setlocal foldlevelstart=0

" RESTORE DEFAULT: foldminlines=1
" Prevents single-line items with no indented children from folding in on themselves.
setlocal foldminlines=1

" Map <CR> in normal mode to simply toggle the single fold
" Because there is only one fold level now, 'za' will open/close everything jointly.
nnoremap <buffer> <silent> <CR> za

" Prevent horizontal movements (like <right>) from opening folds automatically
augroup TalkFold
    autocmd! * <buffer>
    autocmd BufEnter <buffer> set foldopen=
    autocmd BufLeave <buffer> set foldopen&
augroup END
