let s:current_dir = expand('<sfile>:p:h')
if !exists('*SyntaxRegion') && filereadable(s:current_dir . '/../helper/syntax.vim')
    execute 'source ' . s:current_dir . '/../helper/syntax.vim'
endif

if exists('*SyntaxRegion')
    call SyntaxRegion('```{ft}', '```')
endif

syntax match markdownCustomRef /{{:[^:]\+:[^:]\+:}}/ contains=markdownRefBracket,markdownRefColon,markdownRefTopic,markdownRefTarget

syntax match markdownRefStart /{{\ze:[^:]\+:[^:]\+:}}/ nextgroup=markdownRefColon1
syntax match markdownRefColon1 /:/ contained nextgroup=markdownRefTopic
syntax match markdownRefTopic /[^:]\+/ contained nextgroup=markdownRefColon2
syntax match markdownRefColon2 /:/ contained nextgroup=markdownRefTarget
syntax match markdownRefTarget /[^:]\+/ contained nextgroup=markdownRefColon3
syntax match markdownRefColon3 /:/ contained nextgroup=markdownRefEnd
syntax match markdownRefEnd /}}/ contained

hi link markdownRefStart            markdownRefBracket
hi link markdownRefEnd              markdownRefBracket
hi link markdownRefColon1           markdownRefColon
hi link markdownRefColon2           markdownRefColon
hi link markdownRefColon3           markdownRefColon

hi link markdownRefBracket          Delimiter
hi link markdownRefColon            Delimiter
hi markdownRefTopic                 ctermfg=1 cterm=underline
hi markdownRefTarget                ctermfg=1 cterm=underline
