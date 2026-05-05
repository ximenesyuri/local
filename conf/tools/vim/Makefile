HERE    := $(ENV_PATH)/conf/tools/vim
CONF    := $(HERE)/conf
SCRIPTS := $(CONF)/scripts
OTHER   := $(CONF)/others
__VIM__     := $(HOME)/.vim
PACK    := $(__VIM__)/pack/local/start

__SYNTAX := $(SCRIPTS)/syntax
__COLORS := $(SCRIPTS)/colors
__SPELL  := $(OTHER)/spell
__SNIPS  := $(OTHER)/snips
__INIT   := $(CONF)/init.vim

__SYNTAX__ := $(__VIM__)/after/syntax
__COLORS__ := $(__VIM__)/colors
__SPELL__  := $(__VIM__)/spell
__SNIPS__  := $(__VIM__)/snips
__INIT__   := $(__VIM__)/vimrc

PACKAGES = yegappan/lsp

include $(ENV_PATH)/helper/helper.mk

.ONESHELL:

configure:
	rm -rf $(__VIM__)
	$(call __link,dir,$(__SYNTAX),$(__SYNTAX__))
	$(call __link,dir,$(__COLORS),$(__COLORS__))
	$(call __link,dir,$(__SPELL),$(__SPELL__))
	$(call __link,dir,$(__SNIPS),$(__SNIPS__))
	$(call __link,file,$(__INIT),$(__INIT__))
	$(call __clone,$(PACKAGES), $(PACK))
