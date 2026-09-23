augroup HimalayaMailMappings
    autocmd!
    autocmd FileType himalaya-email-* call s:set_himalaya_mappings()
augroup END

function! s:set_himalaya_mappings()
    nmap <buffer> A    <plug>(himalaya-account-select)
    nmap <buffer> F    <plug>(himalaya-folder-select)
    nmap <buffer> >    <plug>(himalaya-folder-select-previous-page)
    nmap <buffer> <    <plug>(himalaya-folder-select-next-page)
    nmap <buffer> <cr> <plug>(himalaya-email-read)
    nmap <buffer> n    <plug>(himalaya-email-write)
    nmap <buffer> r    <plug>(himalaya-email-reply)
    nmap <buffer> R    <plug>(himalaya-email-reply-all)
    nmap <buffer> f    <plug>(himalaya-email-forward)
    nmap <buffer> cp   <plug>(himalaya-email-copy)
    nmap <buffer> mv   <plug>(himalaya-email-move)
    nmap <buffer> dd   <plug>(himalaya-email-delete)
    nmap <buffer> t    <plug>(himalaya-email-flag-add)
    nmap <buffer> e    <plug>(himalaya-email-flag-remove)
    nmap <buffer> x    <plug>(himalaya-email-open-browser)
    nmap <buffer> a    <plug>(himalaya-email-add-attachment)
    nmap <buffer> da   <plug>(himalaya-email-download-attachments)
endfunction
