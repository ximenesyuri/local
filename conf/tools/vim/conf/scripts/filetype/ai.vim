let s:__HERE = fnamemodify(resolve(expand('<sfile>:p')), ':h')
let s:__HELPER = s:__HERE . '/../helper'

let s:ai_models = {
    \ 'gemini': 'google/gemini-3.5-flash',
    \ 'gemini-pro': 'google/gemini-pro-latest'
    \ }

let s:ai_ctx = {}

function! s:__ai_helper__()
    let s:helper = {}

    function! s:helper.thinks(model) dict
        let l:m = tolower(a:model)
        if l:m =~# 'deepseek' || l:m =~# 'r1' || l:m =~# 'thinking' || l:m =~# 'reason'
            return 1
        endif
        return 0
    endfunction

    function! s:helper.complete(findstart, base) dict
        if a:findstart
            let l:line = getline('.')
            let l:start = col('.') - 1
            while l:start > 0 && l:line[l:start - 1] =~ '\S'
                let l:start -= 1
            endwhile
            return l:start
        else
            let l:res = []
            for l:k in keys(s:ai_models)
                if l:k =~ '^' . a:base
                    call add(l:res, l:k)
                endif
            endfor
            return l:res
        endif
    endfunction
endfunction

call s:__ai_helper__()

function! s:__ai__()
    let l:ai = {}

    function! l:ai.status(msg) dict
        echo 'AI: ' . a:msg
        redraw
    endfunction

    function! l:ai.parse_marker(lnum) dict
        let l:res = {'kind': '', 'model': '', 'context': ''}
        if a:lnum <= 0 | return l:res | endif
        let l:line = getline(a:lnum)
        let l:res.kind = matchstr(l:line, '^>>> \zs\(input\|continue\)\ze')
        let l:res.model = matchstr(l:line, '\<model=\zs\S\+')
        let l:res.context = matchstr(l:line, '\<context=\zs\S\+')
        return l:res
    endfunction

    function! l:ai.run(token, ...) dict
        let l:token = a:token

        if type(l:token) != type('') || empty(l:token) || l:token ==# '$OPENROUTER_API_KEY'
            let l:token = expand('$OPENROUTER_API_KEY')
        endif

        let l:token = substitute(l:token, '[[:space:]\r\n]', '', 'g')

        if empty(l:token)
            echoerr "AI: Token is empty. Please set the $OPENROUTER_API_KEY environment variable."
            return
        endif

        let l:explicit_model = a:0 >= 1 ? a:1 : ''

        let l:last_input    = search('^>>> input\>',  'bnW')
        let l:last_continue = search('^>>> continue\>', 'bnW')
        let l:last_output   = search('^>>> output\>', 'bnW')

        if l:last_output > max([l:last_input, l:last_continue])
            let l:orig_start = max([l:last_input, l:last_continue])
            let l:orig_params = self.parse_marker(l:orig_start)
            
            let l:context_suffix = !empty(l:orig_params.context) ? ' context=' . l:orig_params.context : ''
            let l:model_suffix = !empty(l:orig_params.model) ? ' model=' . l:orig_params.model : ''

            let l:region_end = self.find_region_end(l:last_output)

            call append(l:region_end, '')
            call append(l:region_end + 1, '>>> continue' . l:context_suffix . l:model_suffix)
            call append(l:region_end + 2, '')

            call cursor(l:region_end + 3, 1)
            startinsert!
            return
        endif

        if l:last_input == 0 && l:last_continue == 0
            echoerr "AI: No '>>> input' or '>>> continue' marker found"
            return
        endif

        let l:start = max([l:last_input, l:last_continue])
        let l:marker_params = self.parse_marker(l:start)
        let l:kind = l:marker_params.kind

        if l:kind ==# 'continue'
            let l:thread_start = search('^>>> input\>', 'bnW', 0)
            if l:thread_start == 0
                echoerr "AI: '>>> continue' without preceding '>>> input'"
                return
            endif
        else
            let l:thread_start = l:start
        endif

        let l:model = self.resolve_model(l:start, l:explicit_model, l:marker_params)
        if empty(l:model)
            return
        endif

        let l:main_msgs = self.build_messages(l:thread_start, l:start)

        if type(l:main_msgs) != type([]) || empty(l:main_msgs)
            return
        endif

        let l:context_name = l:marker_params.context
        if empty(l:context_name) && l:kind ==# 'continue'
            let l:input_params = self.parse_marker(l:thread_start)
            let l:context_name = l:input_params.context
        endif

        call self.status('collecting context...')
        let [l:ctx_system, l:ctx_resources] = self.build_context_messages(l:context_name, l:model)

        if len(l:main_msgs) > 1
            let l:history  = l:main_msgs[0 : len(l:main_msgs) - 2]
            let l:cur_user = l:main_msgs[-1]
        else
            let l:history  = []
            let l:cur_user = l:main_msgs[0]
        endif
        let l:msgs = l:ctx_system + l:history + l:ctx_resources + [l:cur_user]

        let l:payload = json_encode({
            \ 'model': l:model,
            \ 'messages': l:msgs,
            \ 'stream': v:false
            \ })

        let l:tmpfile = tempname()
        call writefile([l:payload], l:tmpfile)

        if s:helper.thinks(l:model)
            call self.status('thinking...')
        else
            call self.status("sending payload to model '" . l:model . "'...")
        endif

        let l:cmd = [
            \ 'curl', '-sS',
            \ '-H', 'Authorization: Bearer ' . l:token,
            \ '-H', 'Content-Type: application/json',
            \ '-H', 'HTTP-Referer: https://github.com/vim/vim',
            \ '-H', 'X-Title: vim-ai',
            \ '-X', 'POST',
            \ '--data-binary', '@' . l:tmpfile,
            \ 'https://openrouter.ai/api/v1/chat/completions'
            \ ]

        let l:opts = {
            \ 'out_cb':  function('s:AI_on_stdout_proxy', [bufnr('%'), l:kind, l:model]),
            \ 'err_cb':  function('s:AI_on_stdout_proxy', [bufnr('%'), l:kind, l:model]),
            \ 'exit_cb': function('s:AI_on_exit_proxy', [l:tmpfile]),
            \ 'out_mode': 'raw',
            \ 'err_mode': 'raw'
            \ }

        call job_start(l:cmd, l:opts)
    endfunction 

    function! l:ai.resolve_model(marker_lnum, explicit_model, marker_params) dict
        if !empty(a:explicit_model)
            let l:target = a:explicit_model
            return has_key(s:ai_models, l:target) ? s:ai_models[l:target] : l:target
        endif

        let l:name = a:marker_params.model
        if empty(l:name) && a:marker_params.kind ==# 'continue'
            let l:thread_start = search('^>>> input\>', 'bnW', 0)
            if l:thread_start > 0
                let l:input_params = self.parse_marker(l:thread_start)
                let l:name = l:input_params.model
            endif
        endif

        if empty(l:name)
            let l:name = 'google/gemini-2.5-flash'
        endif

        if has_key(s:ai_models, l:name)
            return s:ai_models[l:name]
        endif
        if exists('g:ai_models') && type(g:ai_models) == type({}) && has_key(g:ai_models, l:name)
            return g:ai_models[l:name]
        endif
        return l:name
    endfunction

    function! l:ai.find_region_end(start_lnum) dict
        let l:save_pos = getpos('.')
        call cursor(a:start_lnum, 1)
        let l:next_input    = search('^>>> input\>',  'nW')
        let l:next_continue = search('^>>> continue\>', 'nW')
        call setpos('.', l:save_pos)

        let l:cands = filter([l:next_input, l:next_continue], 'v:val > 0')
        if empty(l:cands)
            return line('$')
        endif
        return min(l:cands) - 1
    endfunction

    function! l:ai.build_messages(input_lnum, last_continue_lnum) dict
        let l:start = a:input_lnum
        let l:last  = line('$')
        let l:lines = getline(l:start, l:last)
        let l:n     = len(l:lines)
        let l:rel_last_continue = a:last_continue_lnum - l:start

        let l:msgs = []
        let l:i = 0
        let l:cur_idx = -1

        while l:i < l:n
            let l:line = l:lines[l:i]
            if l:line =~# '^>>> input\>' || l:line =~# '^>>> continue\>'
                if l:i == l:rel_last_continue
                    let l:cur_idx = l:i
                    break
                endif

                let l:user_start = l:i + 1
                let l:j = l:user_start
                while l:j < l:n && l:lines[l:j] !~ '^>>> '
                    let l:j += 1
                endwhile
                let l:user_end = l:j - 1

                let l:user_text = ''
                if l:user_start <= l:user_end
                    let l:user_text = join(l:lines[l:user_start : l:user_end], "\n")
                endif

                if l:j >= l:n || l:lines[l:j] !~# '^>>> output\>'
                    if !empty(trim(l:user_text))
                        call add(l:msgs, {'role': 'user', 'content': l:user_text})
                    endif
                    let l:i = l:j
                    continue
                endif

                let l:assistant_start = l:j + 1
                if l:assistant_start < l:n && l:lines[l:assistant_start] =~ '^\s*$'
                    let l:assistant_start += 1
                endif

                let l:k = l:assistant_start
                while l:k < l:n && l:lines[l:k] !~ '^>>> '
                    let l:k += 1
                endwhile
                let l:assistant_end = l:k - 1

                let l:assistant_text = ''
                if l:assistant_start <= l:assistant_end
                    let l:assistant_text = join(l:lines[l:assistant_start : l:assistant_end], "\n")
                endif

                if !empty(trim(l:user_text))
                    call add(l:msgs, {'role': 'user', 'content': l:user_text})
                endif
                if !empty(trim(l:assistant_text))
                    call add(l:msgs, {'role': 'assistant', 'content': l:assistant_text})
                endif

                let l:i = l:k
                continue
            endif
            let l:i += 1
        endwhile

        if l:cur_idx == -1
            echoerr "AI: Internal error locating current block"
            return 0
        endif

        let l:user_start = l:cur_idx + 1
        let l:j = l:user_start
        while l:j < l:n && l:lines[l:j] !~ '^>>> '
            let l:j += 1
        endwhile
        let l:user_end = l:j - 1

        if l:user_start > l:user_end
            echoerr "AI: No content after block marker"
            return 0
        endif

        let l:input_text = join(l:lines[l:user_start : l:user_end], "\n")
        if empty(trim(l:input_text))
            echoerr "AI: Empty input/continue block"
            return 0
        endif

        call add(l:msgs, {'role': 'user', 'content': l:input_text})
        return l:msgs
    endfunction

    function! l:ai.build_context_messages(context_name, model) dict
        let l:system_msgs   = []
        let l:resource_msgs = []
        if empty(a:context_name)
            return [l:system_msgs, l:resource_msgs]
        endif

        let l:ignore = exists('g:ai_ignore') ? copy(g:ai_ignore) : []
        let l:seen_files = {}
        let l:seen_urls  = {}
        let l:supports_images = self.model_supports_images(a:model)

        let l:lnum = 1
        let l:last = line('$')

        while l:lnum <= l:last
            let l:line = getline(l:lnum)
            let l:m_ctx = matchlist(l:line, '^>>> context\s\+\(\S\+\)')
            
            if !empty(l:m_ctx) && l:m_ctx[1] ==# a:context_name
                let l:ctx_lnum = l:lnum + 1
                while l:ctx_lnum <= l:last && getline(l:ctx_lnum) !~# '^>>> '
                    let l:ctxline = trim(getline(l:ctx_lnum))
                    if l:ctxline ==# ''
                        let l:ctx_lnum += 1
                        continue
                    endif

                    " Now expects @kind: path (e.g. @dir: ..., @file: ...)
                    let l:m = matchlist(l:ctxline, '^@\(\w\+\)\s*:\s*\(.*\)$')
                    if empty(l:m)
                        let l:ctx_lnum += 1
                        continue
                    endif

                    let l:kind = tolower(l:m[1])
                    let l:val  = l:m[2]

                    if l:kind ==# 'ignore'
                        if !empty(l:val)
                            call add(l:ignore, l:val)
                        endif
                    elseif l:kind ==# 'role'
                        if !empty(l:val)
                            call add(l:system_msgs, {'role': 'system', 'content': l:val})
                        endif
                    elseif l:kind ==# 'file'
                        let l:path = self.normalize_path(l:val)
                        if !empty(l:path) && filereadable(l:path)
                            if !self.path_ignored(l:path, l:ignore) && !has_key(l:seen_files, l:path)
                                let l:seen_files[l:path] = 1
                                call self.status('collecting context...')
                                let l:msg = self.make_file_message(l:path, l:supports_images)
                                if type(l:msg) == type({})
                                    call add(l:resource_msgs, l:msg)
                                endif
                            endif
                        endif
                    elseif l:kind ==# 'dir'
                        let l:dir = self.normalize_path(l:val)
                        if !empty(l:dir) && isdirectory(l:dir)
                            call self.status('collecting context...')
                            for l:f in self.list_dir_files(l:dir, l:ignore)
                                if !has_key(l:seen_files, l:f)
                                    let l:seen_files[l:f] = 1
                                    let l:msg = self.make_file_message(l:f, l:supports_images)
                                    if type(l:msg) == type({})
                                        call add(l:resource_msgs, l:msg)
                                    endif
                                endif
                            endfor
                        endif
                    elseif l:kind ==# 'url'
                        let l:url = l:val
                        if !empty(l:url) && !has_key(l:seen_urls, l:url)
                            let l:seen_urls[l:url] = 1
                            call self.status('collecting context...')
                            let l:msg = self.make_url_message(l:url)
                            if type(l:msg) == type({})
                                call add(l:resource_msgs, l:msg)
                            endif
                        endif
                    endif

                    let l:ctx_lnum += 1
                endwhile

                let l:lnum = l:ctx_lnum
                continue
            endif

            let l:lnum += 1
        endwhile

        return [l:system_msgs, l:resource_msgs]
    endfunction

    function! l:ai.normalize_path(p) dict
        let l:s = trim(a:p)
        if empty(l:s)
            return ''
        endif
        let l:s = expand(l:s)
        return fnamemodify(l:s, ':p')
    endfunction

    function! l:ai.path_ignored(path, ignore_patterns) dict
        if empty(a:ignore_patterns)
            return 0
        endif
        let l:rel = fnamemodify(a:path, ':.')
        for l:pat in a:ignore_patterns
            if empty(l:pat)
                continue
            endif
            try
                if l:rel =~ glob2regpat(l:pat)
                    return 1
                endif
            catch
            endtry
        endfor
        return 0
    endfunction

    function! l:ai.list_dir_files(dir, ignore_patterns) dict
        let l:base = fnamemodify(a:dir, ':p')
        if l:base[-1:] !=# '/'
            let l:base .= '/'
        endif
        let l:paths = glob(l:base . '*', 0, 1)
        let l:files = []
        for l:p in l:paths
            if filereadable(l:p) && !self.path_ignored(l:p, a:ignore_patterns)
                call add(l:files, l:p)
            endif
        endfor
        return l:files
    endfunction

    function! l:ai.make_file_message(path, supports_images) dict
        let l:ext = tolower(fnamemodify(a:path, ':e'))
        let l:rel = fnamemodify(a:path, ':.')

        if index(['png', 'jpg', 'jpeg', 'gif', 'webp', 'bmp', 'svg'], l:ext) >= 0
            if !a:supports_images
                return {'role': 'user', 'content': 'Image file (not inlined; model has no vision support): ' . l:rel}
            endif

            let l:mime = self.guess_image_mime(l:ext)
            if l:mime ==# ''
                let l:mime = 'image/png'
            endif

            let l:cmd = 'base64 ' . shellescape(a:path)
            let l:b64 = substitute(system(l:cmd), '\s\+', '', 'g')
            if v:shell_error != 0 || empty(l:b64)
                return {'role': 'user', 'content': 'Image file (failed to read): ' . l:rel}
            endif

            let l:data_url = 'data:' . l:mime . ';base64,' . l:b64
            return {
                \ 'role': 'user',
                \ 'content': [
                \   {'type': 'text', 'text': 'Image from file ' . l:rel},
                \   {'type': 'image_url', 'image_url': {'url': l:data_url}}
                \ ]
                \ }
        endif

        let l:text = self.read_text_file(a:path)
        if empty(l:text)
            return {}
        endif

        let l:fenced = l:ext
        if l:fenced ==# ''
            let l:fenced = 'text'
        endif

        let l:content = 'File: ' . l:rel . "\n\n" . '`' . '`' . '`' . l:fenced . "\n" . l:text . "\n" . '`' . '`' . '`'
        return {'role': 'user', 'content': l:content}
    endfunction

    function! l:ai.guess_image_mime(ext) dict
        if a:ext ==# 'png'
            return 'image/png'
        elseif a:ext ==# 'jpg' || a:ext ==# 'jpeg'
            return 'image/jpeg'
        elseif a:ext ==# 'gif'
            return 'image/gif'
        elseif a:ext ==# 'webp'
            return 'image/webp'
        elseif a:ext ==# 'bmp'
            return 'image/bmp'
        elseif a:ext ==# 'svg'
            return 'image/svg+xml'
        endif
        return ''
    endfunction

    function! l:ai.read_text_file(path) dict
        if !filereadable(a:path)
            return ''
        endif

        let l:max_bytes = exists('g:ai_max_file_bytes') ? g:ai_max_file_bytes : 200000
        let l:max_lines = exists('g:ai_max_file_lines') ? g:ai_max_file_lines : 2000

        let l:size = getfsize(a:path)
        if l:size < 0
            let l:size = 0
        endif

        let l:truncated = (l:size > l:max_bytes && l:max_bytes > 0)

        if l:truncated
            let l:lines = readfile(a:path, '', l:max_lines)
        else
            let l:lines = readfile(a:path)
        endif

        let l:text = join(l:lines, "\n")
        if l:truncated
            let l:text .= "\n\n[... file truncated; original size " . l:size . " bytes ...]"
        endif
        return l:text
    endfunction

    function! l:ai.make_url_message(url) dict
        let l:max_bytes = exists('g:ai_max_url_bytes') ? g:ai_max_url_bytes : 200000

        let l:res = system('curl -fsSL ' . shellescape(a:url))
        if v:shell_error != 0
            return {
                \ 'role': 'user',
                \ 'content': 'Failed to fetch URL: ' . a:url
                \ }
        endif

        let l:body = strpart(l:res, 0, l:max_bytes)
        let l:trunc = (strlen(l:res) > l:max_bytes)
        if l:trunc
            let l:body .= "\n\n[... response truncated ...]"
        endif

        let l:content =
            \ "You are given an offline snapshot of the content of this URL:\n" . \ a:url . "\n\n" .
            \ "Use ONLY the content below as the page content when answering " . \ "questions about this website. Do NOT say that you cannot browse " . \ "the internet; you already have the page content.\n\n" .
            \ "----- BEGIN PAGE CONTENT -----\n" .
            \ l:body . "\n" .
            \ "----- END PAGE CONTENT -----"

        return {'role': 'user', 'content': l:content}
    endfunction

    function! l:ai.model_supports_images(model) dict
        let l:m = tolower(a:model)
        if l:m =~# 'vision' || l:m =~# 'gpt-4o' || l:m =~# 'gpt-4\.1' || l:m =~# 'claude-3' || l:m =~# 'llama-3\.2-vision'
            return 1
        endif
        return 0
    endfunction

    function! l:ai.on_stdout(bufnr, kind, model, job_id, data) dict
        call self.status('replying...')

        if type(a:data) == type([])
            let l:joined = join(a:data, "\n")
        else
            let l:joined = a:data
        endif

        if empty(trim(l:joined))
            return
        endif

        try
            let l:res = json_decode(l:joined)
        catch
            echoerr "AI API/HTTP Error: " . substitute(strpart(l:joined, 0, 200), '\n', ' ', 'g')
            return
        endtry

        if type(l:res) != type({}) || !has_key(l:res, 'choices') || empty(l:res.choices)
            if has_key(l:res, 'error') && type(l:res.error) == type({}) && has_key(l:res.error, 'message')
                echoerr "AI API Error: " . l:res.error.message
            else
                echoerr "AI: Unexpected response from model: " . strpart(l:joined, 0, 100)
            endif
            return
        endif

        let l:text = get(l:res.choices[0].message, 'content', '')
        if empty(l:text)
            echoerr "AI: Empty content in model response"
            return
        endif

        let l:buf = a:bufnr
        if !bufexists(l:buf)
            return
        endif

        let l:curbuf = bufnr('%')
        execute 'keepalt buffer' l:buf

        if a:kind ==# 'continue'
            let l:marker_pat = '^>>> continue\>'
        else
            let l:marker_pat = '^>>> input\>'
        endif

        let l:start = search(l:marker_pat, 'bnW')
        if l:start == 0
            echoerr "AI: Marker not found when inserting output"
            if l:curbuf != l:buf && bufexists(l:curbuf)
                execute 'keepalt buffer' l:curbuf
            endif
            return
        endif

        let l:orig_params = self.parse_marker(l:start)
        let l:followup_marker = '>>> continue'
        if !empty(l:orig_params.context)
            let l:followup_marker .= ' context=' . l:orig_params.context
        endif
        if !empty(l:orig_params.model)
            let l:followup_marker .= ' model=' . l:orig_params.model
        endif

        let l:save_pos = getpos('.')
        call cursor(l:start, 1)

        let l:next_input    = search('^>>> input\>',  'nW')
        let l:next_continue = search('^>>> continue\>', 'nW')
        call setpos('.', l:save_pos)

        let l:cands = filter([l:next_input, l:next_continue], 'v:val > 0')
        if empty(l:cands)
            let l:region_end = line('$')
        else
            let l:region_end = min(l:cands) - 1
        endif

        let l:out = 0
        for lnum in range(l:start + 1, l:region_end)
            if getline(lnum) =~# '^>>> output\>'
                let l:out = lnum
                break
            endif
        endfor

        if l:out > 0
            let l:del_start = l:out
            if l:out > l:start + 1 && getline(l:out - 1) =~ '^\s*$'
                let l:del_start = l:out - 1
            endif
            call deletebufline(l:buf, l:del_start, l:region_end)
            let l:insert_lnum = l:del_start - 1
        else
            let l:insert_lnum = l:region_end
        endif

        call append(l:insert_lnum, '')
        call append(l:insert_lnum + 1, '>>> output by ' . a:model)
        call append(l:insert_lnum + 2, '')

        let l:lines_to_insert = split(l:text, "\n")
        call append(l:insert_lnum + 3, l:lines_to_insert)

        let l:total_added_lines = 3 + len(l:lines_to_insert)
        let l:end_of_output_lnum = l:insert_lnum + l:total_added_lines

        call append(l:end_of_output_lnum, '')
        call append(l:end_of_output_lnum + 1, l:followup_marker)
        call append(l:end_of_output_lnum + 2, '')

        call cursor(l:end_of_output_lnum + 3, 1)

        call self.status('done.')

        if l:curbuf != l:buf && bufexists(l:curbuf)
            execute 'keepalt buffer' l:curbuf
        else
            startinsert!
        endif
    endfunction 

    function! l:ai.keys() dict
        nnoremap <buffer> <C-g> :call AI(expand('$OPENROUTER_API_KEY'))<CR>
        inoremap <buffer> <C-g> <Esc>:call AI(expand('$OPENROUTER_API_KEY'))<CR>
    endfunction

    function! l:ai.filetypes() dict
        augroup ai_filetype
            autocmd!
            autocmd BufNewFile,BufRead *.ai set filetype=ai
            autocmd FileType ai setlocal omnifunc=s:helper.complete
            autocmd FileType ai call s:ai_ctx.keys()
        augroup END

        if &filetype ==# 'ai'
            setlocal omnifunc=s:helper.complete
            call self.keys()
        endif
    endfunction

    let s:ai_ctx = l:ai
    call l:ai.filetypes()
endfunction

call s:__ai__()

function! s:AI_on_stdout_proxy(bufnr, kind, model, job_id, data) abort
    call s:ai_ctx.on_stdout(a:bufnr, a:kind, a:model, a:job_id, a:data)
endfunction

function! s:AI_on_exit_proxy(tmpfile, job_id, status) abort
    if filereadable(a:tmpfile)
        call delete(a:tmpfile)
    endif
endfunction

function! AI(token, ...) abort
    call call(s:ai_ctx.run, [a:token] + a:000, s:ai_ctx)
endfunction
