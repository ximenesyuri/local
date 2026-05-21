syntax clear

let s:current_dir = expand('<sfile>:p:h')

if !exists('*SyntaxRegion') && filereadable(s:current_dir . '/../helper/syntax.vim')
    execute 'source ' . s:current_dir . '/../helper/syntax.vim'
endif

if exists('*SyntaxRegion')
    call SyntaxRegion('```{ft}', '```')
endif

syn match aiInputMarker '^>>> \(input\|thread\)\>' nextgroup=aiModelName skipwhite
syn match aiOutputMarker '^>>> output\>.*$' contains=aiOutputKeyword,aiModelName,aiOutputLabel
syn match aiOutputKeyword '^>>> output\>' contained
syn match aiOutputLabel '\<by\>' contained
syn match aiModelName '\S\+$' contained

hi aiInputMarker   ctermfg=2
hi aiOutputKeyword ctermfg=red
hi aiOutputMarker  ctermfg=red
hi aiOutputLabel   ctermfg=white
hi aiModelName     ctermfg=Magenta guifg=#FF00FF

let b:current_syntax = "ai"
