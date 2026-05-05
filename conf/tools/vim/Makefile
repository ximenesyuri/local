HERE    := $(ENV_PATH)/conf/tools/vim
CONF    := $(HERE)/conf
SCRIPTS := $(CONF)/scripts
OTHER   := $(CONF)/others
VIM     := $(HOME)/.vim
PACK    := $(VIM)/pack/local/start

__SYNTAX := $(SCRIPTS)/syntax
__COLORS := $(SCRIPTS)/colors
__SPELL  := $(OTHER)/spell
__SNIPS  := $(OTHER)/snips
__INIT   := $(CONF)/init.vim

__SYNTAX__ := $(VIM)/after/syntax
__COLORS__ := $(VIM)/colors
__SPELL__  := $(VIM)/spell
__SNIPS__  := $(VIM)/snips
__INIT__   := $(VIM)/vimrc

PACKAGES = yegappan/lsp

include $(ENV_PATH)/helper/helper.mk

.ONESHELL:

configure:
	rm -rf $(VIM)
	$(call __link,dir,$(__SYNTAX),$(__SYNTAX__))
	$(call __link,dir,$(__COLORS),$(__COLORS__))
	$(call __link,dir,$(__SPELL),$(__SPELL__))
	$(call __link,dir,$(__SNIPS),$(__SNIPS__))
	$(call __link,file,$(__INIT),$(__INIT__))
	$(call __clone,$(PACKAGES), $(PACK))
