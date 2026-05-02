__HERE    := $(__LOCAL)/conf/system/xorg
__CONF    := $(__HERE)/conf
__XINIT   := $(__CONF)/xinit
__XTERM   := $(__CONF)/xterm
__XINIT__ := $${HOME}/.xinitrc
__XTERM__ := $${HOME}/.Xresources

include $(__LOCAL)/helper/helper.mk

.ONESHELL:

configure:
	$(call __link,file,$(__XINIT),$(__XINIT__))
	$(call __link,file,$(__XTERM),$(__XTERM__))
