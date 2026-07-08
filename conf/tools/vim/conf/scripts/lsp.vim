function! g:SmartTab()
    " If completion menu is open, queue a Ctrl+n (Next)
    if pumvisible()
        call feedkeys("\<C-n>", "n")
        return ""
    endif
    
    " Try to expand or jump in an UltiSnips snippet
    call UltiSnips#ExpandSnippetOrJump()
    if get(g:, 'ulti_expand_or_jump_res', 0) == 0
        " If no snippet, queue a literal, native Tab
        call feedkeys("\<Tab>", "n")
    endif
    return ""
endfunction

function! g:SmartShiftTab()
    " If completion menu is open, queue a Ctrl+p (Previous)
    if pumvisible()
        call feedkeys("\<C-p>", "n")
        return ""
    endif
    
    " Try to jump backwards in a snippet
    call UltiSnips#JumpBackwards()
    if get(g:, 'ulti_jump_backwards_res', 0) == 0
        " If no snippet, queue a literal, native Shift-Tab
        call feedkeys("\<S-Tab>", "n")
    endif
    return ""
endfunction

let s:ALLOW_AUTOCOMPLETE = v:true
let s:ALLOW_SNIPPETS = v:true

function! s:__lsp__(auto, snips)
    let l:lsp = {}

    function! l:lsp.keys() dict
       
        inoremap <silent> <Tab> <C-R>=g:SmartTab()<CR>
        inoremap <silent> <S-Tab> <C-R>=g:SmartShiftTab()<CR>
        
        inoremap <expr> <CR> pumvisible() ? (complete_info()['selected'] != -1 ? "\<C-y>" : "\<C-n>\<C-y>") : "\<CR>"
        inoremap <expr> <Space> pumvisible() ? "\<C-y>\<space>" : "\<Space>"
        inoremap <expr> <Down> pumvisible() ? "\<C-e>\<Down>" : "\<C-\>\<C-O>gj"
        inoremap <expr> <Up> pumvisible() ? "\<C-e>\<Up>" : "\<C-\>\<C-O>gk"
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
