let s:current_dir = expand('<sfile>:p:h')
if !exists('*SyntaxRegion') && filereadable(s:current_dir . '/../helper/syntax.vim')
    execute 'source ' . s:current_dir . '/../helper/syntax.vim'
endif

if exists('*SyntaxRegion')
    call SyntaxRegion('```{ft}', '```')
endif

syntax region markdownDoubleBracket matchgroup=Comment start=/{{/ end=/}}/ keepend

syntax match markdownCustomRef /{{:[^:]\+:[^:]\+:}}/ contains=markdownRefBracket,markdownRefColon,markdownRefTopic,markdownRefTarget
syntax match markdownRefStart /{{\ze:[^:]\+:[^:]\+:}}/ nextgroup=markdownRefColon1
syntax match markdownRefColon1 /:/ contained nextgroup=markdownRefTopic
syntax match markdownRefTopic /[^:]\+/ contained nextgroup=markdownRefColon2
syntax match markdownRefColon2 /:/ contained nextgroup=markdownRefTarget
syntax match markdownRefTarget /[^:]\+/ contained nextgroup=markdownRefColon3
syntax match markdownRefColon3 /:/ contained nextgroup=markdownRefEnd
syntax match markdownRefEnd /}}/ contained

syntax match markdownLinkFull /\[.\{-}\](.\{-})/ contains=markdownLinkText,markdownLinkUrl
syntax region markdownLinkText matchgroup=Comment start=/\[/ end=/\]/ contained nextgroup=markdownLinkUrl
syntax region markdownLinkUrl matchgroup=Comment start=/(/ end=/)/ contained

syntax match markdownTitleDelimiter /^\s*#\+/ nextgroup=markdownTitleSpaces
syntax match markdownTitleSpaces /\s\+/ contained nextgroup=markdownTitleText
syntax match markdownTitleText /.*$/ contained

syntax match markdownProperty /^\s*::\s*[^:]\+:/ contained
syntax region markdownKeyword matchgroup=markdownColons start=/^\s*::\s*/ end=/:/ contained oneline
syntax match markdownBlockName /{{\zs[^}]\+\ze}}/ contained
syntax match markdownBlockHeader /\(```\)\@<={{[^}]\+}}/ contained contains=markdownBlockName
syntax region markdownBlock matchgroup=Comment start=/^\s*```\ze{{[^}]\+}}\s*$/ end=/^\s*```\s*$/ keepend contains=markdownBlockHeader,markdownKeyword,markdownItalic,markdownBold,markdownBoldItalic,markdownDoubleBracket,markdownCustomRef,markdownLinkFull,markdownTitleDelimiter,@Spell

hi link markdownColons Comment
hi link markdownKeyword Constant
hi link markdownBlockHeader Comment
hi link markdownBlockName Title

hi markdownLinkUrl ctermfg=4 cterm=underline
hi markdownLinkText ctermfg=5

hi link markdownRefStart            markdownRefBracket
hi link markdownRefEnd              markdownRefBracket
hi link markdownRefColon1           markdownRefColon
hi link markdownRefColon2           markdownRefColon
hi link markdownRefColon3           markdownRefColon

hi markdownDoubleBracket ctermfg=4 cterm=underline
hi link markdownRefBracket          Comment
hi link markdownRefColon            Comment
hi markdownRefTopic                 ctermfg=5
hi markdownRefTarget                ctermfg=4 cterm=underline

hi markdownTitleDelimiter ctermfg=5
hi markdownTitleText cterm=underline
