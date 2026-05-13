let s:ALLOW_AUTOCOMPLETE = v:true
let s:ALLOW_SNIPPETS = v:true

function! s:__lsp__(auto, snips)
    let l:lsp = {}

    function! l:lsp.keys() dict
        inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<tab>"
        inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
        inoremap <expr> <CR> pumvisible() ? "\<C-y>\<C-e>\<backspace>" : "\<CR>"
        inoremap <expr> <Space> pumvisible() ? "\<C-y>\<Space>" : "\<Space>"
        inoremap <expr> <Down> pumvisible() ? "\<C-e>\<Down>" : "\<Down>"
        inoremap <expr> <Up> pumvisible() ? "\<C-e>\<Up>" : "\<Up>"
        inoremap <expr> <Left> pumvisible() ? "\<C-e>\<Left>" : "\<Left>"
        inoremap <expr> <Right> pumvisible() ? "\<C-e>\<Right>" : "\<Right>"

        inoremap <silent> <C-d> <Esc>:LspHover<CR>:startinsert<CR>
        nnoremap <leader>d :rightbelow vsplit <Bar> vert resize 80 <Bar> LspGotoDefinition<CR>
        inoremap <leader>d <Esc>:rightbelow vsplit <Bar> vert resize 80 <Bar> LspGotoDefinition<CR>

        nnoremap <silent> <C-e> :LspDiagCurrent<CR>
        inoremap <silent> <C-e> <C-o>:LspDiagCurrent<CR>
    endfunction

    function! l:lsp.colors() dict
        highlight! LspDiagInlineError cterm=underline ctermfg=red
        highlight! LspDiagSignErrorText cterm=none ctermfg=red
        highlight! LspPopupBorder cterm=underline ctermfg=red
        highlight! LspInlayHintsParam cterm=underline ctermfg=red
    endfunction

    function! l:lsp.options(auto, snips) dict
        if exists('*LspOptionsSet') && !exists('g:lsp_options_set')
            let g:lsp_options_set = 1
            call LspOptionsSet(#{
                \ autoComplete: a:auto,
                \ snippetSupport: a:snips,
                \ showDiagWithVirtualText: v:false,
                \ showDiagInPopup: v:true,
                \ showDiagOnStatusLine: v:true,
                \ showSignature: v:true,
                \ showSignatureDocs: v:true,
                \ diagSignErrorText: '>>',
                \ ultisnipsSupport: v:true,
                \ popupBorder: v:true
                \ })
        endif
    endfunction  

    call l:lsp.keys()
    call l:lsp.colors()
    call l:lsp.options(a:auto, a:snips)
endfunction

call s:__lsp__(s:ALLOW_AUTOCOMPLETE, s:ALLOW_SNIPPETS)
