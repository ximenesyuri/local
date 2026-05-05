__HERE     := $(ENV_PATH)/conf/tools/vim
__CONF     := $(__HERE)/conf
__SCRIPTS  := $(__CONF)/scripts
__OTHER    := $(__CONF)/others
__SYNTAX   := $(__SCRIPTS)/syntax
__COLORS   := $(__SCRIPTS)/colors
__SPELL    := $(__OTHER)/spell
__SNIPS    := $(__OTHER)/snips
__INIT     := $(__CONF)/init.vim
__LSP      := $(__OTHER)/lsp.json
__CONF__   := $(HOME)/.vim
__SYNTAX__ := $(__CONF__)/after/syntax
__COLORS__ := $(__CONF__)/colors
__SPELL__  := $(__CONF__)/spell
__SNIPS__  := $(__CONF__)/snips
__INIT__   := $(__CONF__)/vimrc
__LSP__    := $(__CONF__)/coc-settings.json

include $(ENV_PATH)/helper/helper.mk

.ONESHELL:

configure:
	rm -rf $(__CONF__)
	$(call __link,dir,$(__SYNTAX),$(__SYNTAX__))
	$(call __link,dir,$(__COLORS),$(__COLORS__))
	$(call __link,dir,$(__SPELL),$(__SPELL__))
	$(call __link,dir,$(__SNIPS),$(__SNIPS__))
	$(call __link,file,$(__INIT),$(__INIT__))
	$(call __link,file,$(__LSP),$(__LSP__))
