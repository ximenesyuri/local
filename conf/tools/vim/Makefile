__HERE     := $(__LOCAL)/conf/tools/vim
__CONF     := $(__HERE)/conf
__SYNTAX   := $(__CONF)/syntax
__COLORS   := $(__CONF)/colors
__SPELL    := $(__CONF)/other/spell
__SNIPS    := $(__CONF)/other/snips
__INIT     := $(__CONF)/init
__LSP      := $(__CONF)/other/lsp.json
__CONF__   := $(HOME)/.vim
__SYNTAX__ := $(__CONF__)/after/syntax
__COLORS__ := $(__CONF__)/colors
__SPELL__  := $(__CONF__)/spell
__SNIPS__  := $(__CONF__)/snips
__INIT__   := $(__CONF__)/vimrc
__LSP__    := $(__CONF__)/coc-settings.json

include $(__LOCAL)/helper/helper.mk

.ONESHELL:

configure:
	rm -rf $(__CONF__)
	$(call __link,dir,$(__SYNTAX),$(__SYNTAX__))
	$(call __link,dir,$(__COLORS),$(__COLORS__))
	$(call __link,dir,$(__SPELL),$(__SPELL__))
	$(call __link,dir,$(__SNIPS),$(__SNIPS__))
	$(call __link,file,$(__INIT),$(__INIT__))
	$(call __link,file,$(__LSP),$(__LSP__))
