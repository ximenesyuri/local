let s:__ROOT = fnamemodify(resolve(expand('<sfile>:p')), ':h:h:h')
let g:UltiSnipsSnippetDirectories=[s:__ROOT . '/other/snips']

let g:UltiSnipsExpandTrigger = "<nop>"
let g:UltiSnipsJumpForwardTrigger = "<nop>"
let g:UltiSnipsJumpBackwardTrigger = "<nop>"

function! s:SnippetComplete(findstart, base)
    if a:findstart
        let l:line = getline('.')
        let l:start = col('.') - 1
        while l:start > 0 && l:line[l:start - 1] =~ '\S'
            let l:start -= 1
        endwhile
        return l:start
    else
        let l:res = []
        let l:snips = UltiSnips#SnippetsInCurrentScope(1)
        
        for [l:trigger, l:desc] in items(l:snips)
            if l:trigger =~ '^' . a:base
                call add(l:res, {'word': l:trigger, 'menu': '[snip] ' . l:desc})
            endif
        endfor
        return l:res
    endif
endfunction

set completefunc=s:SnippetComplete
