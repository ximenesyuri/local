ENV   := $(ENVS[$__ENV])
TOOLS := vim

include $(ENV)/helper/helper.mk

.ONESHELL:

configure:
	$(call __recursive,configure,$(TOOLS))


