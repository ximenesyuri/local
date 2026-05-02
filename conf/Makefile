TOOLS  := $(__LOCAL)/conf/tools
SYSTEM := $(__LOCAL)/conf/system

include $(__LOCAL)/helper/helper.mk

.ONESHELL:

configure:
	@$(call __make,configure,$(TOOLS))
	@$(call __make,configure,$(SYSTEM))
