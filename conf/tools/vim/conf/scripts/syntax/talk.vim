let s:current_dir = expand('<sfile>:p:h')
if !exists('*SyntaxRegion') && filereadable(s:current_dir . '/../helper/syntax.vim')
    execute 'source ' . s:current_dir . '/../helper/syntax.vim'
endif

if exists('*SyntaxRegion')
    call SyntaxRegion('```{ft}', '```')
endif

if hlexists('txtCode')
    syntax clear txtCode
endif
if hlexists('txtCodeBlock')
   syntax clear txtCodeBlock
endif

" italic: "_<text>_"
syntax region txtItalic matchgroup=txtItalicDelim start=/_/ skip=/\\_/ end=/_/

" bold: "__<text>__"
syntax region txtBold matchgroup=txtBoldDelim start=/__/ skip=/\\_/ end=/__/

" delimiters: "(", ")", "'"
syntax match txtDelimiter /[()"']/ containedin=ALL

" preformatted: "`<text>`" and "<pre>...</pre>"
syntax region txtCode matchgroup=txtCodeDelim start=/`/ skip=/\\`/ end=/`/

" marked: "==<text>=="
syntax match txtMarkFull /==.\{-}==/ contains=txtMarkDelim,txtMarkValue
syntax match txtMarkDelim /==/ contained
syntax match txtMarkValue /\(==\)\@<=.\{-}\ze==/ contained

" underline: "++<text>++"
syntax match txtUnderlineFull /++.\{-}++/ contains=txtUnderlineDelim,txtUnderlineValue
syntax match txtUnderlineDelim /++/ contained
syntax match txtUnderlineValue /\(++\)\@<=.\{-}\ze++/ contained

" tagged: "=<tag>=<text>=="
syntax match txtTagFull /=[^=]\+=.\{-}==/ contains=txtTagStart,txtTagValue,txtTagEnd
syntax match txtTagStart /=[^=]\+=/ contained contains=txtTagDelim,txtTagLabel
syntax match txtTagDelim /=/ contained
syntax match txtTagLabel /[^=]\+/ contained
syntax match txtTagValue /\(=[^=]\+=\)\@<=.\{-}\ze==/ contained
syntax match txtTagEnd /==/ contained

" link: "[<label>](<url>)"
syntax match txtLinkFull /\[.\{-}\](.\{-})/ contains=txtLinkText,txtLinkUrl
syntax region txtLinkText matchgroup=Comment start=/\[/ end=/\]/ contained nextgroup=txtLinkUrl
syntax region txtLinkUrl matchgroup=Comment start=/(/ end=/)/ contained

" title: "# <title>"
syntax match txtTitleDelimiter /^\s*#\+/ nextgroup=txtTitleSpaces
syntax match txtTitleSpaces /\s\+/ contained nextgroup=txtTitleText
syntax match txtTitleText /.*$/ contained

" lists: "<n>. <something>" and "> <something>"
syntax match txtListMarker /^\s*\zs\(>\)\ze\s\+/
syntax match txtOrderedListMarker /^\s*\zs\d\+[.)]\ze\s\+/

syntax match txtFrontmatterSeparator "^-\+$"

syntax match txtFrontmatterKey "^\w\+\ze:"

syntax match txtFrontmatterDelimiter ":"

syntax match txtFrontmatterValue ":\s*\zs.*$"

highlight default link txtFrontmatterSeparator Comment
highlight default link txtFrontmatterKey       Identifier
highlight default link txtFrontmatterDelimiter Operator
highlight default link txtFrontmatterValue     String


" numbers
syntax match txtNumber /\<\d\+\([.,]\d\+\)\?\>\([.)]\s\)\@!/ containedin=ALL

" HIGHLIGHT
hi txtItalic ctermfg=2 cterm=italic
hi link txtItalicDelim Comment
hi txtBold ctermfg=2 cterm=Bold
hi link txtBoldDelim Comment

hi link txtDelimiter Delimiter
hi link txtNumber Constant

hi txtLinkUrl ctermfg=4 cterm=underline
hi txtLinkText ctermfg=5
hi txtListMarker ctermfg=1 cterm=bold
hi link txtOrderedListMarker Constant

" ==something==
hi link txtMarkDelim Comment
hi link txtMarkValue Highlight

" ++something++
hi link txtUnderlineDelim Comment
hi link txtUnderlineValue Underlined

setlocal conceallevel=2
