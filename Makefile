SHELL := /bin/zsh

PUBLIC_REPO ?= $(CURDIR)
PRIVATE_REPO ?= $(HOME)/projects/network-configs-private
SITE ?= cape-town
SYNC_SCRIPT := setups/mikrotik-rb5009/sync-public-to-private.sh

.PHONY: sync-private sync-private-dry-run

sync-private:
	$(SYNC_SCRIPT) "$(PUBLIC_REPO)" "$(PRIVATE_REPO)" "$(SITE)"

sync-private-dry-run:
	DRY_RUN=1 $(SYNC_SCRIPT) "$(PUBLIC_REPO)" "$(PRIVATE_REPO)" "$(SITE)"
