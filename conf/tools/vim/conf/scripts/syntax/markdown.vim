let s:current_dir = expand('<sfile>:p:h')
if !exists('*SyntaxRegion') && filereadable(s:current_dir . '/../helper/syntax.vim')
    execute 'source ' . s:current_dir . '/../helper/syntax.vim'
endif

if exists('*SyntaxRegion')
    call SyntaxRegion('```{ft}', '```')
endif

if hlexists('markdownCode')
    syntax clear markdownCode
endif
if hlexists('markdownCodeBlock')
   syntax clear markdownCodeBlock
endif

" preformatted: "`<text>`" and "<pre>...</pre>"
syntax region markdownCode matchgroup=markdownCodeDelimiter start=/`/ skip=/\\`/ end=/`/
syntax region markdownPreBlock matchgroup=markdownHtmlBlock start=/<pre>/ end=/<\/pre>/

" marked: "==<text>=="
syntax match markdownMarkFull /==.\{-}==/ contains=markdownMarkDelim,markdownMarkValue
syntax match markdownMarkDelim /==/ contained
syntax match markdownMarkValue /\(==\)\@<=.\{-}\ze==/ contained

" underline: "++<text>++"
syntax match markdownUnderlineFull /++.\{-}++/ contains=markdownUnderlineDelim,markdownUnderlineValue
syntax match markdownUnderlineDelim /++/ contained
syntax match markdownUnderlineValue /\(++\)\@<=.\{-}\ze++/ contained

" tagged: "=<tag>=<text>=="
syntax match markdownTagFull /=[^=]\+=.\{-}==/ contains=markdownTagStart,markdownTagValue,markdownTagEnd
syntax match markdownTagStart /=[^=]\+=/ contained contains=markdownTagDelim,markdownTagLabel
syntax match markdownTagDelim /=/ contained
syntax match markdownTagLabel /[^=]\+/ contained
syntax match markdownTagValue /\(=[^=]\+=\)\@<=.\{-}\ze==/ contained
syntax match markdownTagEnd /==/ contained

" link: "[<label>](<url>)"
syntax match markdownLinkFull /\[.\{-}\](.\{-})/ contains=markdownLinkText,markdownLinkUrl
syntax region markdownLinkText matchgroup=Comment start=/\[/ end=/\]/ contained nextgroup=markdownLinkUrl
syntax region markdownLinkUrl matchgroup=Comment start=/(/ end=/)/ contained

" title: "# <title>"
syntax match markdownTitleDelimiter /^\s*#\+/ nextgroup=markdownTitleSpaces
syntax match markdownTitleSpaces /\s\+/ contained nextgroup=markdownTitleText
syntax match markdownTitleText /.*$/ contained

" line: ":: <entry>: <arg>=xxx, <arg>=yyy"
syntax match markdownRefsLine /^\s*::\s*__refs__:.*$/ containedin=ALL contains=markdownKeyword,@NoSpell
syntax match markdownColons /^\s*::\s*/ containedin=ALL contains=markdownRefsLine nextgroup=markdownKeyword
syntax match markdownKeyword /[a-zA-Z0-9_-]\+:/ contained
syntax match markdownArgName /\(^\s*::.*\)\@<=\<[a-zA-Z0-9_-]\+\ze=/ containedin=ALL nextgroup=markdownArgEquals
syntax match markdownArgEquals /=/ contained nextgroup=markdownArgValue,markdownArgString
syntax match markdownArgValue /[^, "]\+/ contained
syntax region markdownArgString start=/"/ skip=/\\"/ end=/"/ contained
syntax match markdownArgSeparator /\(^\s*::.*\)\@<=,/ containedin=ALL

" vars: "{{ <var> }}"
syntax region markdownVar matchgroup=markdownBlockBraces start=/{{\ze[^:]*}}/ end=/}}/ keepend oneline containedin=ALL contains=markdownBlockWord,markdownBlockNamespace,markdownBlockName,markdownBlockDot

" blocks: "{{ block.<name> }}"
syntax match markdownBlockWord /[a-zA-Z0-9_-]\+/ contained
syntax match markdownBlockNamespace /[a-zA-Z0-9_-]\+\ze\./ contained
syntax match markdownBlockDot /\./ contained
syntax match markdownBlockName /\(\.\)\@<=[a-zA-Z0-9_-]\+/ contained

" html: "<tag class='...'>...</tag>"
syntax region markdownCustomHtmlTag matchgroup=markdownHtmlBlock start=/<\/\?/ end=/>/ containedin=ALL oneline contains=markdownHtmlTagName,markdownHtmlArgName,markdownHtmlArgEquals,markdownHtmlArgString
syntax match markdownHtmlTagName /\(<\/\?\)\@<=[a-zA-Z0-9_-]\+/ contained
syntax match markdownHtmlArgName /[a-zA-Z0-9_-]\+\ze=/ contained
syntax match markdownHtmlArgEquals /=/ contained
syntax region markdownHtmlArgString start=/"/ skip=/\\"/ end=/"/ contained

" refs: "{{ <topic>:<context>:<label> }}"
syntax match markdownRefDelimStart /{{\ze[^:]\+:[^:]\+:[^}]\+}}/ containedin=ALL conceal cchar=" nextgroup=markdownRefTopic
syntax match markdownRefTopic /[^:]\+/ contained conceal nextgroup=markdownRefColon1
syntax match markdownRefColon1 /:/ contained conceal nextgroup=markdownRefContext
syntax match markdownRefContext /[^:]\+/ contained conceal nextgroup=markdownRefColon2
syntax match markdownRefColon2 /:/ contained conceal nextgroup=markdownRefLabel
syntax match markdownRefLabel /[^}]\+/ contained nextgroup=markdownRefDelimEnd
syntax match markdownRefDelimEnd /}}/ contained conceal cchar="

" HIGHLIGHT
hi markdownLinkUrl ctermfg=4 cterm=underline
hi markdownLinkText ctermfg=5
hi markdownTitleDelimiter ctermfg=5
hi markdownTitleText cterm=underline

hi link markdownColons Comment
hi link markdownKeyword Delimiter
hi link markdownArgName Constant          
hi link markdownArgEquals Operator
hi link markdownArgValue String       
hi link markdownArgSeparator Operator 
hi link markdownArgString String         

hi link markdownBlockBraces Comment 
hi link markdownBlockWord Title 
hi markdownBlockNamespace ctermfg=2
hi link markdownBlockDot Comment     
hi link markdownBlockName Type

hi link markdownHtmlBlock Comment
hi markdownHtmlTagName ctermfg=4
hi link markdownHtmlArgName Constant
hi link markdownHtmlArgEquals Operator
hi link markdownHtmlArgString String

" ==something==
hi link markdownMarkDelim Comment
hi link markdownMarkValue Highlight

" ++something++
hi link markdownUnderlineDelim Comment
hi link markdownUnderlineValue Underlined

" =foo=something==
hi link markdownTagDelim Comment
hi link markdownTagEnd Comment
hi link markdownTagLabel Constant
hi link markdownTagValue Special

" {{ <topic>:<context>:<label> }}
hi link markdownRefDelimStart Comment
hi link markdownRefDelimEnd Comment
hi link markdownRefColon1 Comment
hi link markdownRefColon2 Comment
hi link markdownRefTopic Type
hi link markdownRefContext Identifier
hi markdownRefLabel ctermfg=4 cterm=underline

setlocal conceallevel=2
