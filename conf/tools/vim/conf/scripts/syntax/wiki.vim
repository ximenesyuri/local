let s:current_dir = expand('<sfile>:p:h')
if !exists('*SyntaxRegion') && filereadable(s:current_dir . '/../helper/syntax.vim')
    execute 'source ' . s:current_dir . '/../helper/syntax.vim'
endif

if exists('*SyntaxRegion')
    call SyntaxRegion('```{ft}', '```')
endif

if hlexists('wikiCode')
    syntax clear wikiCode
endif
if hlexists('wikiCodeBlock')
   syntax clear wikiCodeBlock
endif

" italic: "_<text>_"
syntax region wikiItalic matchgroup=wikiItalicDelim start=/_/ skip=/\\_/ end=/_/

" bold: "__<text>__"
syntax region wikiBold matchgroup=wikiBoldDelim start=/__/ skip=/\\_/ end=/__/

" delimiters: "(", ")", "'"
syntax match wikiDelimiter /[()"']/ containedin=ALL

" preformatted: "`<text>`" and "<pre>...</pre>"
syntax region wikiCode matchgroup=wikiCodeDelim start=/`/ skip=/\\`/ end=/`/
syntax region wikiPreBlock matchgroup=wikiHtmlBlock start=/<pre>/ end=/<\/pre>/

" marked: "==<text>=="
syntax match wikiMarkFull /==.\{-}==/ contains=wikiMarkDelim,wikiMarkValue
syntax match wikiMarkDelim /==/ contained
syntax match wikiMarkValue /\(==\)\@<=.\{-}\ze==/ contained

" underline: "++<text>++"
syntax match wikiUnderlineFull /++.\{-}++/ contains=wikiUnderlineDelim,wikiUnderlineValue
syntax match wikiUnderlineDelim /++/ contained
syntax match wikiUnderlineValue /\(++\)\@<=.\{-}\ze++/ contained

" tagged: "=<tag>=<text>=="
syntax match wikiTagFull /=[^=]\+=.\{-}==/ contains=wikiTagStart,wikiTagValue,wikiTagEnd
syntax match wikiTagStart /=[^=]\+=/ contained contains=wikiTagDelim,wikiTagLabel
syntax match wikiTagDelim /=/ contained
syntax match wikiTagLabel /[^=]\+/ contained
syntax match wikiTagValue /\(=[^=]\+=\)\@<=.\{-}\ze==/ contained
syntax match wikiTagEnd /==/ contained

" link: "[<label>](<url>)"
syntax match wikiLinkFull /\[.\{-}\](.\{-})/ contains=wikiLinkText,wikiLinkUrl
syntax region wikiLinkText matchgroup=Comment start=/\[/ end=/\]/ contained nextgroup=wikiLinkUrl
syntax region wikiLinkUrl matchgroup=Comment start=/(/ end=/)/ contained

" title: "# <title>"
syntax match wikiTitleDelimiter /^\s*#\+/ nextgroup=wikiTitleSpaces
syntax match wikiTitleSpaces /\s\+/ contained nextgroup=wikiTitleText
syntax match wikiTitleText /.*$/ contained

" lists: "<n>. <something>" and "- <something>"
syntax match wikiListMarker /^\s*\zs\(-\)\ze\s\+/
syntax match wikiOrderedListMarker /^\s*\zs\d\+[.)]\ze\s\+/

" line: ":: <entry>: <arg>=xxx, <arg>=yyy"
syntax match wikiRefsLine /^\s*::\s*__refs__:.*$/ containedin=ALL contains=wikiKeyword,@NoSpell
syntax match wikiColons /^\s*::\s*/ containedin=ALL contains=wikiRefsLine nextgroup=wikiKeyword
syntax match wikiKeyword /[a-zA-Z0-9_-]\+:/ contained
syntax match wikiArgName /\(^\s*::.*\)\@<=\<[a-zA-Z0-9_-]\+\ze=/ containedin=ALL nextgroup=wikiArgEquals
syntax match wikiArgEquals /=/ contained nextgroup=wikiArgValue,wikiArgString
syntax match wikiArgValue /[^, "]\+/ contained
syntax region wikiArgString start=/"/ skip=/\\"/ end=/"/ contained
syntax match wikiArgSeparator /\(^\s*::.*\)\@<=,/ containedin=ALL

" vars: "{{ <var> }}"
syntax region wikiVar matchgroup=wikiBlockBraces start=/{{\ze[^:]*}}/ end=/}}/ keepend oneline containedin=ALL contains=wikiBlockWord,wikiBlockNamespace,wikiBlockName,wikiBlockDot

" blocks: "{{ block.<name> }}"
syntax match wikiBlockWord /[a-zA-Z0-9_-]\+/ contained
syntax match wikiBlockNamespace /[a-zA-Z0-9_-]\+\ze\./ contained
syntax match wikiBlockDot /\./ contained
syntax match wikiBlockName /\(\.\)\@<=[a-zA-Z0-9_-]\+/ contained

" html: "<tag class='...'>...</tag>"
syntax region wikiCustomHtmlTag matchgroup=wikiHtmlBlock start=/<\/\?/ end=/>/ containedin=ALL oneline contains=wikiHtmlTagName,wikiHtmlArgName,wikiHtmlArgEquals,wikiHtmlArgString
syntax match wikiHtmlTagName /\(<\/\?\)\@<=[a-zA-Z0-9_-]\+/ contained
syntax match wikiHtmlArgName /[a-zA-Z0-9_-]\+\ze=/ contained
syntax match wikiHtmlArgEquals /=/ contained
syntax region wikiHtmlArgString start=/"/ skip=/\\"/ end=/"/ contained

" refs: "{{ <topic>:<context>:<label> }}"
syntax match wikiRefDelimStart /{{\ze[^:]\+:[^:]\+:[^}]\+}}/ containedin=ALL conceal cchar=" nextgroup=wikiRefTopic
syntax match wikiRefTopic /[^:]\+/ contained conceal nextgroup=wikiRefColon1
syntax match wikiRefColon1 /:/ contained conceal nextgroup=wikiRefContext
syntax match wikiRefContext /[^:]\+/ contained conceal nextgroup=wikiRefColon2
syntax match wikiRefColon2 /:/ contained conceal nextgroup=wikiRefLabel
syntax match wikiRefLabel /[^}]\+/ contained nextgroup=wikiRefDelimEnd
syntax match wikiRefDelimEnd /}}/ contained conceal cchar="

" numbers
syntax match wikiNumber /\<\d\+\([.,]\d\+\)\?\>\([.)]\s\)\@!/ containedin=ALL

" HIGHLIGHT
hi WikiItalic ctermfg=2 cterm=italic
hi link WikiItalicDelim Comment
hi WikiBold ctermfg=2 cterm=Bold
hi link WikiBoldDelim Comment

hi link WikiDelimiter Delimiter
hi link WikiNumber Constant

hi wikiLinkUrl ctermfg=4 cterm=underline
hi wikiLinkText ctermfg=5
hi wikiTitleDelimiter ctermfg=5
hi wikiTitleText cterm=underline
hi link wikiListMarker Statement
hi link wikiOrderedListMarker Statement


hi link wikiColons Comment
hi link wikiKeyword Delimiter
hi link wikiArgName Constant          
hi link wikiArgEquals Operator
hi link wikiArgValue String       
hi link wikiArgSeparator Operator 
hi link wikiArgString String         

hi link wikiBlockBraces Comment 
hi link wikiBlockWord Title 
hi wikiBlockNamespace ctermfg=5
hi link wikiBlockDot Comment     
hi link wikiBlockName Type

hi link wikiHtmlBlock Comment
hi wikiHtmlTagName ctermfg=4
hi link wikiHtmlArgName Constant
hi link wikiHtmlArgEquals Operator
hi link wikiHtmlArgString String

" ==something==
hi link wikiMarkDelim Comment
hi link wikiMarkValue Highlight

" ++something++
hi link wikiUnderlineDelim Comment
hi link wikiUnderlineValue Underlined

" =foo=something==
hi link wikiTagDelim Comment
hi link wikiTagEnd Comment
hi link wikiTagLabel Constant
hi link wikiTagValue Special

" {{ <topic>:<context>:<label> }}
hi link wikiRefDelimStart Comment
hi link wikiRefDelimEnd Comment
hi link wikiRefColon1 Comment
hi link wikiRefColon2 Comment
hi link wikiRefTopic Type
hi link wikiRefContext Identifier
hi wikiRefLabel ctermfg=4 cterm=underline

setlocal conceallevel=2
