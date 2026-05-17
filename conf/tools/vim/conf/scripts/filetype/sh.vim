if exists('g:bash_lsp_registered') | finish | endif
let g:bash_lsp_registered = 1

function! s:__sh__(timer_id)
    let l:sh = {}

    function! l:sh.__lsp() dict
        if !exists('*LspAddServer') | return | endif

        let l:server = [#{
            \ name: 'bash-language-server',
            \ filetype: 'sh',
            \ path: '$BIN/bash-language-server',
            \ args: ['start'],
        \ }]
        
        call LspAddServer(l:server)

        if &filetype ==# 'sh'
            silent! doautocmd <nomodeline> FileType sh
        endif
    endfunction

    function! l:sh.lsp() dict
        if executable('bash-language-server')
            call self.__lsp()
        endif
    endfunction

    call l:sh.lsp()
endfunction

call timer_start(20, { t -> s:__sh__(t) })
