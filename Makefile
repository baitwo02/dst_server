RUNTIME ?= podman

IMAGE ?= dst-distribution:latest
CONTAINER_MASTER ?= dst-master
CONTAINER_CAVES ?= dst-caves

DATA_DIR ?= ./data
KLEI_DIR ?= $(DATA_DIR)/DoNotStarveTogether
USER_MODS_DIR ?= $(DATA_DIR)/user-mods
MOD_CACHE_DIR ?= $(DATA_DIR)/mod-cache

CLUSTER ?= Cluster_1

MASTER_PORT ?= 10999
CAVES_PORT ?= 11000
MASTER_SHARD_PORT ?= 12346
CAVES_SHARD_PORT ?= 12347

CONTAINERFILE ?= Containerfile
CONFIG_TEMPLATE_DIR ?= ./config-templates

# 将容器内 dst 用户映射为当前 rootless Podman 用户。
USERNS ?= keep-id:uid=10001,gid=10001
# Master 与 Caves 共享这些挂载，因此使用共享 SELinux 标签。
VOLUME_SUFFIX ?= :z

.PHONY: help
help:
	@echo "DST Dedicated Server Distribution"
	@echo ""
	@echo "Common targets:"
	@echo "  make init             Initialize local data files and directories"
	@echo "  make build            Build image"
	@echo "  make rebuild          Rebuild image without cache"
	@echo "  make up               Start Master and Caves"
	@echo "  make up-master        Start Master only"
	@echo "  make up-caves         Start Caves only"
	@echo "  make down             Stop and remove Master and Caves"
	@echo "  make restart          Recreate Master and Caves"
	@echo "  make restart-master   Restart Master container"
	@echo "  make restart-caves    Restart Caves container"
	@echo "  make logs-master      Follow Master logs"
	@echo "  make logs-caves       Follow Caves logs"
	@echo "  make ps               Show containers"
	@echo "  make shell-master     Open shell in Master container"
	@echo "  make shell-caves      Open shell in Caves container"
	@echo "  make clean-data       Delete local data directory"
	@echo ""
	@echo "Variables:"
	@echo "  RUNTIME=$(RUNTIME)"
	@echo "  IMAGE=$(IMAGE)"
	@echo "  CLUSTER=$(CLUSTER)"
	@echo "  DATA_DIR=$(DATA_DIR)"
	@echo "  USERNS=$(USERNS)"
	@echo "  VOLUME_SUFFIX=$(VOLUME_SUFFIX)"

.PHONY: init
init:
	@mkdir -p "$(KLEI_DIR)/$(CLUSTER)/Master"
	@mkdir -p "$(KLEI_DIR)/$(CLUSTER)/Caves"
	@mkdir -p "$(USER_MODS_DIR)/Master"
	@mkdir -p "$(USER_MODS_DIR)/Caves"
	@mkdir -p "$(MOD_CACHE_DIR)"
	@if [ ! -f "$(KLEI_DIR)/$(CLUSTER)/cluster.ini" ]; then \
		cp "$(CONFIG_TEMPLATE_DIR)/cluster.ini" "$(KLEI_DIR)/$(CLUSTER)/cluster.ini"; \
	fi
	@if [ ! -f "$(KLEI_DIR)/$(CLUSTER)/Master/server.ini" ]; then \
		cp "$(CONFIG_TEMPLATE_DIR)/Master/server.ini" "$(KLEI_DIR)/$(CLUSTER)/Master/server.ini"; \
	fi
	@if [ ! -f "$(KLEI_DIR)/$(CLUSTER)/Caves/server.ini" ]; then \
		cp "$(CONFIG_TEMPLATE_DIR)/Caves/server.ini" "$(KLEI_DIR)/$(CLUSTER)/Caves/server.ini"; \
	fi
	@touch "$(KLEI_DIR)/$(CLUSTER)/cluster_token.txt"
	@echo "Initialized data directory:"
	@echo "  $(DATA_DIR)"
	@echo ""
	@echo "Required action:"
	@echo "  Fill in your DST cluster token:"
	@echo "  $(KLEI_DIR)/$(CLUSTER)/cluster_token.txt"
	@echo ""
	@echo "Optional server customization:"
	@echo "  $(KLEI_DIR)/$(CLUSTER)/cluster.ini"
	@echo "  $(KLEI_DIR)/$(CLUSTER)/Master/server.ini"
	@echo "  $(KLEI_DIR)/$(CLUSTER)/Caves/server.ini"
	@echo ""
	@echo "Optional user mod files are not created automatically:"
	@echo "  $(USER_MODS_DIR)/extra_mods.lua"
	@echo "  $(USER_MODS_DIR)/Master/extra_modoverrides.lua"
	@echo "  $(USER_MODS_DIR)/Caves/extra_modoverrides.lua"

.PHONY: build
build:
	$(RUNTIME) build -t "$(IMAGE)" -f "$(CONTAINERFILE)" .

.PHONY: rebuild
rebuild:
	$(RUNTIME) build --no-cache -t "$(IMAGE)" -f "$(CONTAINERFILE)" .

.PHONY: check-token
check-token:
	@if [ ! -s "$(KLEI_DIR)/$(CLUSTER)/cluster_token.txt" ] \
		|| ! grep -q '[^[:space:]]' "$(KLEI_DIR)/$(CLUSTER)/cluster_token.txt"; then \
		echo "ERROR: cluster token is missing or empty:"; \
		echo "  $(KLEI_DIR)/$(CLUSTER)/cluster_token.txt"; \
		echo ""; \
		echo "Run 'make init', then put your DST cluster token into that file."; \
		exit 1; \
	fi

.PHONY: up
up: up-master up-caves

.PHONY: up-master
up-master: check-token
	@$(RUNTIME) rm -f "$(CONTAINER_MASTER)" >/dev/null 2>&1 || true
	$(RUNTIME) run -d \
		--name "$(CONTAINER_MASTER)" \
		--userns "$(USERNS)" \
		-p "$(MASTER_PORT):10999/udp" \
		-p "$(MASTER_SHARD_PORT):12346/udp" \
		-v "$(KLEI_DIR):/data/DoNotStarveTogether$(VOLUME_SUFFIX)" \
		-v "$(USER_MODS_DIR):/data/user-mods$(VOLUME_SUFFIX)" \
		-v "$(MOD_CACHE_DIR):/opt/dst/mods$(VOLUME_SUFFIX)" \
		-e DST_CLUSTER="$(CLUSTER)" \
		-e DST_SHARD="Master" \
		"$(IMAGE)"

.PHONY: up-caves
up-caves: check-token
	@$(RUNTIME) rm -f "$(CONTAINER_CAVES)" >/dev/null 2>&1 || true
	$(RUNTIME) run -d \
		--name "$(CONTAINER_CAVES)" \
		--userns "$(USERNS)" \
		-p "$(CAVES_PORT):11000/udp" \
		-p "$(CAVES_SHARD_PORT):12347/udp" \
		-v "$(KLEI_DIR):/data/DoNotStarveTogether$(VOLUME_SUFFIX)" \
		-v "$(USER_MODS_DIR):/data/user-mods$(VOLUME_SUFFIX)" \
		-v "$(MOD_CACHE_DIR):/opt/dst/mods$(VOLUME_SUFFIX)" \
		-e DST_CLUSTER="$(CLUSTER)" \
		-e DST_SHARD="Caves" \
		"$(IMAGE)"

.PHONY: down
down:
	@$(RUNTIME) rm -f "$(CONTAINER_MASTER)" >/dev/null 2>&1 || true
	@$(RUNTIME) rm -f "$(CONTAINER_CAVES)" >/dev/null 2>&1 || true
	@echo "Stopped and removed containers."

.PHONY: restart
restart: down up

.PHONY: restart-master
restart-master:
	$(RUNTIME) restart "$(CONTAINER_MASTER)"

.PHONY: restart-caves
restart-caves:
	$(RUNTIME) restart "$(CONTAINER_CAVES)"

.PHONY: logs-master
logs-master:
	$(RUNTIME) logs -f "$(CONTAINER_MASTER)"

.PHONY: logs-caves
logs-caves:
	$(RUNTIME) logs -f "$(CONTAINER_CAVES)"

.PHONY: ps
ps:
	$(RUNTIME) ps -a --filter "name=$(CONTAINER_MASTER)" --filter "name=$(CONTAINER_CAVES)"

.PHONY: shell-master
shell-master:
	$(RUNTIME) exec -it "$(CONTAINER_MASTER)" /bin/bash

.PHONY: shell-caves
shell-caves:
	$(RUNTIME) exec -it "$(CONTAINER_CAVES)" /bin/bash

.PHONY: stop
stop:
	-$(RUNTIME) stop "$(CONTAINER_MASTER)"
	-$(RUNTIME) stop "$(CONTAINER_CAVES)"

.PHONY: start
start:
	$(RUNTIME) start "$(CONTAINER_MASTER)"
	$(RUNTIME) start "$(CONTAINER_CAVES)"

.PHONY: clean
clean: down

.PHONY: clean-image
clean-image:
	-$(RUNTIME) rmi "$(IMAGE)"

.PHONY: clean-data
clean-data:
	@echo "This will delete:"
	@echo "  $(DATA_DIR)"
	@echo ""
	@printf "Type 'delete data' to continue: "; \
	read confirm; \
	if [ "$$confirm" = "delete data" ]; then \
		rm -rf "$(DATA_DIR)"; \
		echo "Deleted $(DATA_DIR)"; \
	else \
		echo "Cancelled."; \
	fi

.PHONY: show-paths
show-paths:
	@echo "DATA_DIR=$(DATA_DIR)"
	@echo "KLEI_DIR=$(KLEI_DIR)"
	@echo "USER_MODS_DIR=$(USER_MODS_DIR)"
	@echo "MOD_CACHE_DIR=$(MOD_CACHE_DIR)"
	@echo "TOKEN=$(KLEI_DIR)/$(CLUSTER)/cluster_token.txt"
	@echo "MASTER_CONFIG=$(KLEI_DIR)/$(CLUSTER)/Master/server.ini"
	@echo "CAVES_CONFIG=$(KLEI_DIR)/$(CLUSTER)/Caves/server.ini"
