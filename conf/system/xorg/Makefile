HERE := $(ENV_PATH)/conf/system/xorg
CONF := $(HERE)/conf

__XINIT   := $(CONF)/xinit
__XTERM   := $(CONF)/xterm
__XINIT__ := $${HOME}/.xinitrc
__XTERM__ := $${HOME}/.Xresources

include $(ENV_PATH)/helper/helper.mk

.ONESHELL:

configure:
	$(call __link,file,$(__XINIT),$(__XINIT__))
	$(call __link,file,$(__XTERM),$(__XTERM__))
