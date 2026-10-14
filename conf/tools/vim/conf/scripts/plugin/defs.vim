let s:defs_dict = {}
let s:defs_loaded = 0

function! s:LoadDefs()
    let s:defs_loaded = 1
    
    let l:json_path = expand('/home/yx/etc/dev/lemma/lemma.com/dist/defs.json')
    
    if !filereadable(l:json_path)
        let l:json_path = findfile('defs.json', expand('%:p:h') . ';')
    endif
    
    if empty(l:json_path) || !filereadable(l:json_path)
        return
    endif
    
    try
        let l:raw = json_decode(join(readfile(l:json_path), "\n"))
        let s:defs_dict = {}
        
        for l:key in keys(l:raw)
            let l:parts = split(l:key, '\.')
            if len(l:parts) == 2
                let l:ctx = l:parts[0]
                let l:term = l:parts[1]
                if !has_key(s:defs_dict, l:ctx)
                    let s:defs_dict[l:ctx] = []
                endif
                call add(s:defs_dict[l:ctx], l:term)
            endif
        endfor
    catch
        echom "Defs Complete: Error parsing defs.json: " . v:exception
    endtry
endfunction

function! g:TriggerDefsComplete()
    try
        let l:col = col('.') - 1
        let l:text = strpart(getline('.'), 0, l:col)
        
        let l:start = match(l:text, '\<def\.[^[:space:]]*$')
        if l:start < 0
            return 0
        endif
        
        if !s:defs_loaded
            call s:LoadDefs()
        endif
        
        if empty(s:defs_dict)
            return 0
        endif
        
        let l:base = strpart(l:text, l:start)
        let l:res = []
        
        let l:parts = split(l:base, '\.', 1)
        
        if len(l:parts) == 2
            let l:prefix = l:parts[1]
            let l:compl_start = l:start + 4
            
            for l:ctx in keys(s:defs_dict)
                if l:ctx =~ '^' . l:prefix
                    call add(l:res, {'word': l:ctx, 'menu': '[Context]'})
                endif
            endfor
            
            if !empty(l:res)
                call complete(l:compl_start + 1, l:res)
                return 1
            endif
            
        elseif len(l:parts) == 3
            let l:ctx = l:parts[1]
            let l:prefix = l:parts[2]
            
            if has_key(s:defs_dict, l:ctx) && index(s:defs_dict[l:ctx], l:prefix) >= 0
                return 0
            endif
            
            let l:compl_start = l:start + 5 + len(l:ctx)
            if has_key(s:defs_dict, l:ctx)
                for l:term in s:defs_dict[l:ctx]
                    if l:term =~ '^' . l:prefix
                        call add(l:res, {'word': l:term, 'menu': '[Term]'})
                    endif
                endfor
            endif
            
            if !empty(l:res)
                call complete(l:compl_start + 1, l:res)
                return 1
            endif
        endif
    catch
        echom "Defs Complete Runtime Error: " . v:exception
    endtry
    
    return 0
endfunction
