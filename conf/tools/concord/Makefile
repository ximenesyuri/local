HERE    := $(ENV_PATH)/conf/tools/concord
CONF    := $(HERE)/conf
CONCORD := $(HOME)/.config/concord

__CONF     := $(CONF)/config.toml
__KEYMAP   := $(CONF)/keymap.toml
__THEME    := $(CONF)/theme.toml
__CONF__   := $(CONCORD)/config.toml
__KEYMAP__ := $(CONCORD)/keymap.toml
__THEME__  := $(CONCORD)/theme.toml

include $(ENV_PATH)/helper/helper.mk

configure:
	$(call __link,file,$(__CONF),$(__CONF__))
	$(call __link,file,$(__KEYMAP),$(__KEYMAP__))
	$(call __link,file,$(__THEME),$(__THEME__))
