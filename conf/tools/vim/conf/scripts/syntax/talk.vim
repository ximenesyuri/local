let s:current_dir = expand('<sfile>:p:h')
if !exists('*SyntaxRegion') && filereadable(s:current_dir . '/../helper/syntax.vim')
    execute 'source ' . s:current_dir . '/../helper/syntax.vim'
endif

if exists('*SyntaxRegion')
    call SyntaxRegion('```{ft}', '```')
endif

if hlexists('talkCode')
    syntax clear talkCode
endif
if hlexists('talkCodeBlock')
   syntax clear talkCodeBlock
endif

" italic: "_<text>_" (added concealends)
syntax region talkItalic matchgroup=talkItalicDelim start=/_/ skip=/\\_/ end=/_/ concealends

" bold: "__<text>__" (added concealends)
syntax region talkBold matchgroup=talkBoldDelim start=/__/ skip=/\\_/ end=/__/ concealends

" delimiters: "(", ")", "'"
syntax match talkDelimiter /[()"']/ containedin=ALL

" preformatted: "`<text>`" (added concealends)
syntax region talkCode matchgroup=talkCodeDelim start=/`/ skip=/\\`/ end=/`/ concealends

" marked: "==<text>==" (added conceal to Delim)
syntax match talkMarkFull /==.\{-}==/ contains=talkMarkDelim,talkMarkValue
syntax match talkMarkDelim /==/ contained conceal
syntax match talkMarkValue /\(==\)\@<=.\{-}\ze==/ contained

" underline: "+<text>+" (added conceal to Delim)
syntax match talkUnderlineFull /+.\{-}+/ contains=talkUnderlineDelim,talkUnderlineValue
syntax match talkUnderlineDelim /+/ contained conceal
syntax match talkUnderlineValue /\(+\)\@<=.\{-}\ze+/ contained

" tagged: "=<tag>=<text>==" (added conceal to Delim and End)
syntax match talkTagFull /=[^=]\+=.\{-}==/ contains=talkTagStart,talkTagValue,talkTagEnd
syntax match talkTagStart /=[^=]\+=/ contained contains=talkTagDelim,talkTagLabel
syntax match talkTagDelim /=/ contained conceal
syntax match talkTagLabel /[^=]\+/ contained
syntax match talkTagValue /\(=[^=]\+=\)\@<=.\{-}\ze==/ contained
syntax match talkTagEnd /==/ contained conceal

" link: "[<label>](<url>)" (added concealends to text, conceal to url)
syntax match talkLinkFull /\[.\{-}\](.\{-})/ contains=talkLinkText,talkLinkUrl
syntax region talkLinkText matchgroup=Comment start=/\[/ end=/\]/ contained nextgroup=talkLinkUrl concealends
syntax region talkLinkUrl matchgroup=Comment start=/(/ end=/)/ contained conceal

" title: "# <title>"
syntax match talkTitleDelimiter /^\s*#\+/ nextgroup=talkTitleSpaces
syntax match talkTitleSpaces /\s\+/ contained nextgroup=talkTitleText
syntax match talkTitleText /.*$/ contained

" lists: "<n>. <something>", "> <something>", and "1> <something>"
syntax match talkListMarker /^\s*\zs\d*>/
syntax match talkOrderedListMarker /^\s*\zs\d\+[.)]\ze\s\+/

" frontmatter
syntax match talkFrontmatterSeparator "^-\+$"
syntax match talkFrontmatterKey "^\w\+\ze:"
syntax match talkFrontmatterDelimiter ":"
syntax match talkFrontmatterValue ":\s*\zs.*$"

highlight default link talkFrontmatterSeparator Comment
highlight default link talkFrontmatterKey       Identifier
highlight default link talkFrontmatterDelimiter Operator
highlight default link talkFrontmatterValue     String

" numbers (ignores digits immediately followed by '>')
syntax match talkNumber /\<\d\+\([.,]\d\+\)\?\>\([.)>]\)\@!/ containedin=ALL

" HIGHLIGHT
hi talkItalic ctermfg=2 cterm=italic
hi link talkItalicDelim Comment
hi talkBold ctermfg=2 cterm=Bold
hi link talkBoldDelim Comment

hi link talkDelimiter Delimiter
hi link talkNumber Constant

hi talkLinkUrl ctermfg=4 cterm=underline
hi talkLinkText ctermfg=5
hi talkListMarker ctermfg=1 cterm=bold
hi link talkOrderedListMarker Constant

" ==something==
hi link talkMarkDelim Comment
hi link talkMarkValue Highlight

" ++something++
hi link talkUnderlineDelim Comment
hi link talkUnderlineValue Underlined

setlocal conceallevel=2
