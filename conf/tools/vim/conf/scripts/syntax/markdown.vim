let s:current_dir = expand('<sfile>:p:h')
if !exists('*SyntaxRegion') && filereadable(s:current_dir . '/../helper/syntax.vim')
    execute 'source ' . s:current_dir . '/../helper/syntax.vim'
endif

if exists('*SyntaxRegion')
    call SyntaxRegion('```{ft}', '```')
endif

syntax match markdownLinkFull /\[.\{-}\](.\{-})/ contains=markdownLinkText,markdownLinkUrl
syntax region markdownLinkText matchgroup=Comment start=/\[/ end=/\]/ contained nextgroup=markdownLinkUrl
syntax region markdownLinkUrl matchgroup=Comment start=/(/ end=/)/ contained

syntax match markdownTitleDelimiter /^\s*#\+/ nextgroup=markdownTitleSpaces
syntax match markdownTitleSpaces /\s\+/ contained nextgroup=markdownTitleText
syntax match markdownTitleText /.*$/ contained

syntax region markdownKeyword matchgroup=markdownColons start=/^\s*::\s*/ end=/:/ oneline
syntax region markdownCustomTag matchgroup=markdownBracketBraces start=/{{/ end=/}}/ keepend contains=markdownBracketWord,markdownBracketPunct
syntax match markdownBracketPunct /[.:]/ contained
syntax match markdownBracketWord /[^.:{}]\+/ contained

hi link markdownColons Comment
hi link markdownKeyword Constant
hi markdownLinkUrl ctermfg=4 cterm=underline
hi markdownLinkText ctermfg=5
hi markdownTitleDelimiter ctermfg=5
hi markdownTitleText cterm=underline
hi link markdownBracketBraces Comment
hi link markdownBracketPunct Comment
hi link markdownBracketWord Title
