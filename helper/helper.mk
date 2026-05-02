.ONESHELL:

define __link
	echo "Linking $(1): $(3) -> $(2)"
	rm -rf "$(3)"
	mkdir -p "$$(dirname "$(3)")"
	ln -snf "$(2)" "$(3)"

endef

define __make
	if [ ! -f $(2)/Makefile ]; then
		echo "error: missing Makefile in $(2)." && exit 1
	fi
	$(MAKE) --directory $(2) $(1)
endef

define __recursive
	for x in $(2); do
		if [ -d "$$x" ]; then
			$(call __make,$(1),$$x)
		fi
	done
endef
