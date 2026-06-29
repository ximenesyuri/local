" ULTISNIPS
let g:UltiSnipsSnippetDirectories=["snips"]

function! g:SmartTab()
    return get(g:, 'ulti_expand_or_jump_res', 0) ? "" : "\<Tab>"
endfunction

function! g:SmartShiftTab()
    return get(g:, 'ulti_expand_or_jump_res', 0) ? "" : "\<S-Tab>"
endfunction
