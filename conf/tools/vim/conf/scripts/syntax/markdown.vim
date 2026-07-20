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

" ----------------------------------------------------------------------
" BLOCKS and VARS ({{ block.row }} and {{ some_var }})
" ----------------------------------------------------------------------
syntax region markdownVar matchgroup=markdownBlockBraces start=/{{/ end=/}}/ keepend oneline containedin=ALL contains=markdownBlockWord,markdownBlockNamespace,markdownBlockName,markdownBlockPunct
syntax match markdownBlockWord /[a-zA-Z0-9_-]\+/ contained
syntax match markdownBlockNamespace /[a-zA-Z0-9_-]\+\ze\./ contained
syntax match markdownBlockPunct /\./ contained
syntax match markdownBlockName /\(\.\)\@<=[a-zA-Z0-9_-]\+/ contained

" ----------------------------------------------------------------------
" BLOCK FIELDS (:: item: id=xxx, pos=yyy)
" ----------------------------------------------------------------------
syntax match markdownColons /^\s*::\s*/ containedin=ALL nextgroup=markdownKeyword
syntax match markdownKeyword /[a-zA-Z0-9_-]\+:/ contained
syntax match markdownArgName /\(^\s*::.*\)\@<=\<[a-zA-Z0-9_-]\+\ze=/ containedin=ALL nextgroup=markdownArgEquals
syntax match markdownArgEquals /=/ contained nextgroup=markdownArgValue,markdownArgString
syntax match markdownArgValue /[^, "]\+/ contained
syntax region markdownArgString start=/"/ skip=/\\"/ end=/"/ contained
syntax match markdownArgSeparator /\(^\s*::.*\)\@<=,/ containedin=ALL

" ----------------------------------------------------------------------
" HTML (<display class="sss">...</display>)
" ----------------------------------------------------------------------
syntax region markdownCustomHtmlTag matchgroup=markdownHtmlBlock start=/<\/\?/ end=/>/ containedin=ALL oneline contains=markdownHtmlTagName,markdownHtmlArgName,markdownHtmlArgEquals,markdownHtmlArgString
syntax match markdownHtmlTagName /\(<\/\?\)\@<=[a-zA-Z0-9_-]\+/ contained
syntax match markdownHtmlArgName /[a-zA-Z0-9_-]\+\ze=/ contained
syntax match markdownHtmlArgEquals /=/ contained
syntax region markdownHtmlArgString start=/"/ skip=/\\"/ end=/"/ contained


" ----------------------------------------------------------------------
" HIGHLIGHT
" ----------------------------------------------------------------------
hi markdownLinkUrl ctermfg=4 cterm=underline
hi markdownLinkText ctermfg=5
hi markdownTitleDelimiter ctermfg=5
hi markdownTitleText cterm=underline

hi link markdownColons Comment
hi link markdownKeyword Constant
hi link markdownArgName Type          
hi link markdownArgEquals Operator
hi link markdownArgValue String       
hi link markdownArgSeparator Operator 
hi link markdownArgString String         

hi link markdownBlockBraces Comment 
hi link markdownBlockWord Title 
hi link markdownBlockNamespace Title
hi link markdownBlockPunct Comment     
hi link markdownBlockName Type 

hi link markdownHtmlBlock Comment
hi markdownHtmlTagName ctermfg=4
hi link markdownHtmlArgName Constant
hi link markdownHtmlArgEquals Operator
hi link markdownHtmlArgString String
