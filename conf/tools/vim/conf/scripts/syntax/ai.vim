syntax clear

let s:current_dir = expand('<sfile>:p:h')

if !exists('*SyntaxRegion') && filereadable(s:current_dir . '/../helper/syntax.vim')
    execute 'source ' . s:current_dir . '/../helper/syntax.vim'
endif

if exists('*SyntaxRegion')
    call SyntaxRegion('```{ft}', '```')
endif

" Markers: >>> input | >>> continue
syn match aiInputMarker '^>>> \(input\|continue\)\>' nextgroup=aiMarkerParams skipwhite
syn match aiMarkerParams '.*$' contained contains=aiParamContext,aiParamModel

" In-marker params matching: context=<context_name> and model=<model_name>
syn match aiParamContext '\<context=\S\+' contained contains=aiParamKey,aiParamValue
syn match aiParamModel '\<model=\S\+' contained contains=aiParamKey,aiParamValue
syn match aiParamKey '\<\(context\|model\)=' contained
syn match aiParamValue '=\@<=\S\+' contained

" Context declarations
syn match aiContextMarker '^>>> context\>' nextgroup=aiContextName skipwhite
syn match aiContextName '\S\+' contained

" Context attributes (e.g., @dir: /path, @file: /path)
syn match aiContextAttr '^@\w\+:' contains=aiContextAt,aiContextColon
syn match aiContextAt '@' contained
syn match aiContextColon ':' contained

" Output Markers
syn match aiOutputMarker '^>>> output\>.*$' contains=aiOutputKeyword,aiOutputLabel,aiModelName
syn match aiOutputKeyword '^>>> output\>' contained
syn match aiOutputLabel '\<by\>' contained
syn match aiModelName '\S\+$' contained

" Highlight Bindings
hi aiInputMarker   ctermfg=2
hi aiParamKey      ctermfg=6
hi aiParamValue    ctermfg=3
hi aiContextMarker ctermfg=4
hi aiContextName   ctermfg=3
hi aiContextAttr   ctermfg=6
hi aiContextAt     ctermfg=5
hi aiContextColon  ctermfg=5
hi aiOutputKeyword ctermfg=1
hi aiOutputMarker  ctermfg=1
hi aiOutputLabel   ctermfg=7
hi aiModelName     ctermfg=5 guifg=#FF00FF

let b:current_syntax = "ai"
