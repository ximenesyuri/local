function! s:TextFormatters() abort
    inoremap <buffer> <C-l> <C-r>=__\<Left><CR>
    inoremap <buffer> <C-b> <C-r>=____\<Left>\<Left><CR>
    inoremap <buffer> <C-u> <C-r>=++\<Left>\<Left>\<Left>\<Left><CR>
    xnoremap <buffer> <C-i> c_<C-r>"_<Esc>i
    xnoremap <buffer> <C-l> c_<C-r>"_<Esc>i
    xnoremap <buffer> <C-b> c__<C-r>"__<Esc>i
    xnoremap <buffer> <C-u> c+<C-r>"+<Esc>i
endfunction

let s:wiki_words = {}

function! s:RefreshWikiWords() abort
    let s:wiki_words = {}
    for l:line in getline(1, '$')
        for l:w in split(l:line, '\W\+')
            if len(l:w) >= 3
                let s:wiki_words[l:w] = 1
            endif
        endfor
    endfor
endfunction

function! s:CompleteWikiWords() abort
    if pumvisible()
        return
    endif

    let l:col = col('.') - 1
    let l:line = strpart(getline('.'), 0, l:col)

    if l:line =~# '\<def\.[^[:space:]]*$'
        return
    endif

    let l:start = match(l:line, '\k\{2,}$')
    if l:start < 0
        return
    endif

    let l:prefix = strpart(l:line, l:start)
    let l:matches = []

    for l:w in keys(s:wiki_words)
        if l:w =~# '^' . l:prefix && l:w !=# l:prefix
            call add(l:matches, l:w)
        endif
    endfor

    if !empty(l:matches)
        call complete(l:start + 1, sort(l:matches))
    endif
endfunction

setlocal completeopt=menuone,noinsert,noselect

call s:TextFormatters()
call s:RefreshWikiWords()

augroup WikiAutoComplete
    autocmd! * <buffer>
    autocmd BufEnter,InsertLeave,TextChanged <buffer> call s:RefreshWikiWords()
    autocmd InsertCharPre <buffer> call timer_start(0, {-> s:CompleteWikiWords()})
augroup END
