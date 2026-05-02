__HERE      := $(__LOCAL)/conf/system/i3
__CONF      := $(__HERE)/conf
__SCRIPTS   := $(__HERE)/scripts
__I3__      := $(HOME)/.config/i3
__SCRIPTS__ := $(__I3__)/scripts
__CONF__    := $(__I3__)/conf
__CONFIG    := $(__CONF__)/i3.conf
__CONFIG__  := $(__I3__)/config

include $(__LOCAL)/helper/helper.mk

.ONESHELL:

configure:
	$(call __link,dir,$(__CONF),$(__CONF__))
	$(call __link,dir,$(__SCRIPTS),$(__SCRIPTS__))
	$(call __link,file,$(__CONFIG),$(__CONFIG__))
