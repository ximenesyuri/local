let s:LSP = 'pylsp'
let s:LSP_BIN = $BIN . '/pylsp'

if executable(s:LSP_BIN)
    call LspAddServer([#{
        \ name: s:LSP,
        \ filetype: 'python',
        \ path: s:LSP_BIN,
        \ args: []
    \ }])
else
    echohl ErrorMsg
    echom 'LSP Error: ' . s:LSP . ' binary not found or not executable at: ' . l:LSP_BIN
    echohl None
endif
