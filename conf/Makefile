HERE   := $(ENV_PATH)/conf
TOOLS  := $(HERE)/tools
SYSTEM := $(HERE)/system

include $(ENV_PATH)/helper/helper.mk

.ONESHELL:

configure:
	@$(call __make,configure,$(TOOLS))
	@$(call __make,configure,$(SYSTEM))
