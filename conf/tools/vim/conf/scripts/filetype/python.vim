if exists('g:pyright_registered') | finish | endif
let g:pyright_registered = 1

let s:ADDITIONAL_DIRS = ['/typed/typed']

function! s:__python__(dirs, timer_id)
    let l:python = {}

    function! l:python.venv() dict
        let l:venv = finddir('.venv', '.;')
        return empty(l:venv) ? '' : fnamemodify(l:venv, ':p')
    endfunction

    function! l:python.bin(venv_path) dict
        if !empty(a:venv_path)
            let l:py = a:venv_path . 'bin/python'
            if executable(l:py) | return l:py | endif
        endif
        return 'python3'
    endfunction

    function! l:python.__lsp(dirs) dict
        let l:venv = self.venv()
        let l:bin = self.bin(l:venv)

        if !exists('*LspAddServer') | return | endif

        let l:typeshed = []
        let l:extra = []

        if !empty(l:venv)
            let l:libs = glob(l:venv . 'lib/python*/site-packages', 0, 1)
            if !empty(l:libs)
                let l:site_packages = l:libs[0]
                for l:dir in a:dirs
                    call add(l:typeshed, l:site_packages . l:dir)
                endfor
                let l:extra = [l:site_packages]
            endif
        endif

        let l:server = [#{
            \ name: 'pyright',
            \ filetype: 'python',
            \ path: 'pyright-langserver',
            \ args: ['--stdio'],
            \ rootSearch: ['.venv', 'pyproject.toml', 'setup.py', '.git'],
            \ workspaceConfig: #{
            \   python: #{
            \     pythonPath: l:bin,
            \     analysis: #{
            \       logLevel: 'Error',
            \       diagnosticMode: 'openFilesOnly',
            \       typeCheckingMode: 'off',
            \       autoImportCompletions: v:true,
            \       typeshedPaths: l:typeshed,
            \       extraPaths: l:extra,
            \       diagnosticSeverityOverrides: #{
            \         reportMissingImports: 'error',
            \         reportMissingModuleSource: 'error',
            \         reportImportCycles: 'error',
            \         reportUnusedImport: 'error',
            \         reportDuplicateImport: 'error',
            \         reportUndefinedVariable: 'error'
            \       }
            \     },
            \     linting: #{ enabled: v:true }
            \   },
            \   pyright: #{
            \     disableDiagnostics: v:false,
            \     disableTaggedHints: v:true,
            \     completion: #{ importSupport: v:true },
            \     inlayHints: #{
            \       variableTypes: v:false,
            \       functionReturnTypes: v:false,
            \       parameterTypes: v:false
            \     }
            \   }
            \ }
        \ }]
        
        call LspAddServer(l:server)

        if &filetype ==# 'python'
            silent! doautocmd <nomodeline> FileType python
        endif
    endfunction

    function! l:python.lsp(dirs) dict
        if executable('pyright-langserver')
            call self.__lsp(a:dirs)
        else
            let l:cmd = 'pip install pyright[nodejs] --break-system-packages && mv $HOME/.local/bin/pyright* $BIN'
            call job_start(['bash', '-c', l:cmd], #{
                \ exit_cb: {job, status -> status == 0 ? l:python.__lsp(a:dirs) : v:null}
                \ })
        endif
    endfunction

    call l:python.lsp(a:dirs)
endfunction

call timer_start(20, { t -> s:__python__(s:ADDITIONAL_DIRS, t) })
