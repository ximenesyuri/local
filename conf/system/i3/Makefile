HERE := $(ENV_PATH)/conf/system/i3
I3   := $(HOME)/.config/i3

__CONF      := $(HERE)/conf
__SCRIPTS   := $(HERE)/scripts
__SCRIPTS__ := $(I3)/scripts
__CONF__    := $(I3)/conf
__CONFIG    := $(__CONF__)/i3.conf
__CONFIG__  := $(I3)/config

include $(ENV_PATH)/helper/helper.mk

.ONESHELL:

configure:
	$(call __link,dir,$(__CONF),$(__CONF__))
	$(call __link,dir,$(__SCRIPTS),$(__SCRIPTS__))
	$(call __link,file,$(__CONFIG),$(__CONFIG__))
