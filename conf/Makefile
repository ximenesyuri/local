ENV    := $(ENV_PATH)
TOOLS  := $(ENV)/conf/tools
SYSTEM := $(ENV)/conf/system

include $(ENV)/helper/helper.mk

.ONESHELL:

configure:
	@$(call __make,configure,$(TOOLS))
	@$(call __make,configure,$(SYSTEM))
