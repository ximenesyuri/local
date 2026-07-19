if exists('g:css_lsp_registered') | finish | endif
let g:css_lsp_registered = 1

function! s:__css__(timer_id)
    let l:css = {}

    function! l:css.__lsp() dict
        if !exists('*LspAddServer') | return | endif

        let l:server = [#{
            \ name: 'go-css',
            \ filetype: 'css',
            \ path: '$BIN/go-css-lsp'
        \ }]
        
        call LspAddServer(l:server)

        if &filetype ==# 'css'
            silent! doautocmd <nomodeline> FileType css
        endif
    endfunction

    function! l:css.lsp() dict
        if executable('go-css-lsp')
            call self.__lsp()
        endif
    endfunction

    call l:css.lsp()
endfunction

call timer_start(20, { t -> s:__css__(t) })
