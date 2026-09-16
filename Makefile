RUNTIME ?= podman

IMAGE ?= dst_distribution:latest
CONTAINER_MASTER ?= dst_master
CONTAINER_CAVES ?= dst_caves
POD_NAME ?= dst

DATA_DIR ?= ./data
KLEI_DIR ?= $(DATA_DIR)/DoNotStarveTogether
USER_MODS_DIR ?= $(DATA_DIR)/user_mods
MOD_CACHE_DIR ?= $(DATA_DIR)/mod_cache
PRESET_DIR ?= ./preset

CLUSTER ?= Cluster_1

MASTER_PORT ?= 10999
CAVES_PORT ?= 11000
MASTER_SHARD_PORT ?= 12346
CAVES_SHARD_PORT ?= 12347

CONTAINERFILE ?= Containerfile
CONFIG_TEMPLATE_DIR ?= ./config_templates

# 基础镜像与软件源，可用于国内加速构建：
#   make build BASE_IMAGE=mirror.ccs.tencentyun.com/library/debian APT_MIRROR=mirrors.cloud.tencent.com
# APT_MIRROR 为空时沿用 Debian 默认源。
BASE_IMAGE ?= debian
DEBIAN_VERSION ?= bookworm
APT_MIRROR ?=

# SteamCMD 自举包与下载重试。Steam 无公共国内镜像；
# 游戏本体由 Steam 根据 CellID 自动选择 CDN。
STEAMCMD_URL ?= https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
STEAMCMD_ATTEMPTS ?= 5
STEAMCMD_RETRY_DELAY ?= 10
STEAMCMD_TIMEOUT ?= 1800
STEAMCMD_API_WAIT ?= 600
STEAMCMD_API_CHECK_TIMEOUT ?= 15

# 构建容器的 nofile 限制。rootless Podman 的构建容器默认只有 1024:1024，
# 会导致 SteamCMD 的 `ulimit -n 2048` 报 "Operation not permitted"。
# 置空可禁用该参数。
BUILD_ULIMIT ?= nofile=65535:65535
ULIMIT_ARG := $(if $(BUILD_ULIMIT),--ulimit "$(BUILD_ULIMIT)")

# DST 构建峰值磁盘占用：builder 层(~4.8GB) + runtime COPY 的新层与临时文件，
# 实测单次 COPY 峰值可达 ~15GB。低于此值构建会在最后一步报 no space left on device。
# 冷构建（无缓存）建议提高到 20。
MIN_FREE_GB ?= 15

BUILD_ARGS ?= \
	--build-arg BASE_IMAGE="$(BASE_IMAGE)" \
	--build-arg DEBIAN_VERSION="$(DEBIAN_VERSION)" \
	--build-arg APT_MIRROR="$(APT_MIRROR)" \
	--build-arg STEAMCMD_URL="$(STEAMCMD_URL)" \
	--build-arg STEAMCMD_ATTEMPTS="$(STEAMCMD_ATTEMPTS)" \
	--build-arg STEAMCMD_RETRY_DELAY="$(STEAMCMD_RETRY_DELAY)" \
	--build-arg STEAMCMD_TIMEOUT="$(STEAMCMD_TIMEOUT)" \
	--build-arg STEAMCMD_API_WAIT="$(STEAMCMD_API_WAIT)" \
	--build-arg STEAMCMD_API_CHECK_TIMEOUT="$(STEAMCMD_API_CHECK_TIMEOUT)" \
	$(ULIMIT_ARG)

# 将容器内 dst 用户映射为当前 rootless Podman 用户。
USERNS ?= keep-id:uid=10001,gid=10001
# Master 与 Caves 共享这些挂载，因此使用共享 SELinux 标签。
VOLUME_SUFFIX ?= :z
PRESET_VOLUME_SUFFIX ?= :ro,z

.PHONY: help
help:
	@echo "DST Dedicated Server Distribution"
	@echo ""
	@echo "Common targets:"
	@echo "  make init             Initialize local data files and directories"
	@echo "  make build            Build image"
	@echo "  make rebuild          Rebuild image without cache"
	@echo "  make up               Start Master and Caves"
	@echo "  make up_master        Start Master only"
	@echo "  make up_caves         Start Caves only"
	@echo "  make down             Stop and remove Master, Caves and pod"
	@echo "  make restart          Recreate Master and Caves"
	@echo "  make restart_master   Restart Master container"
	@echo "  make restart_caves    Restart Caves container"
	@echo "  make logs_master      Follow Master logs"
	@echo "  make logs_caves       Follow Caves logs"
	@echo "  make ps               Show containers"
	@echo "  make update_mods      Download/update all Workshop mods then exit"
	@echo "  make shell_master     Open shell in Master container"
	@echo "  make shell_caves      Open shell in Caves container"
	@echo "  make clean_data       Delete local data directory"
	@echo ""
	@echo "Variables:"
	@echo "  RUNTIME=$(RUNTIME)"
	@echo "  IMAGE=$(IMAGE)"
	@echo "  POD_NAME=$(POD_NAME)"
	@echo "  CLUSTER=$(CLUSTER)"
	@echo "  DATA_DIR=$(DATA_DIR)"
	@echo "  PRESET_DIR=$(PRESET_DIR)"
	@echo "  BASE_IMAGE=$(BASE_IMAGE)"
	@echo "  DEBIAN_VERSION=$(DEBIAN_VERSION)"
	@echo "  APT_MIRROR=$(APT_MIRROR)"
	@echo "  STEAMCMD_ATTEMPTS=$(STEAMCMD_ATTEMPTS)"
	@echo "  STEAMCMD_TIMEOUT=$(STEAMCMD_TIMEOUT)"
	@echo "  MIN_FREE_GB=$(MIN_FREE_GB)"
	@echo "  USERNS=$(USERNS)"
	@echo "  VOLUME_SUFFIX=$(VOLUME_SUFFIX)"
	@echo "  PRESET_VOLUME_SUFFIX=$(PRESET_VOLUME_SUFFIX)"

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
	@if [ ! -f "$(KLEI_DIR)/$(CLUSTER)/Master/worldgenoverride.lua" ]; then \
		cp "$(CONFIG_TEMPLATE_DIR)/Master/worldgenoverride.lua" "$(KLEI_DIR)/$(CLUSTER)/Master/worldgenoverride.lua"; \
	fi
	@if [ ! -f "$(KLEI_DIR)/$(CLUSTER)/Caves/worldgenoverride.lua" ]; then \
		cp "$(CONFIG_TEMPLATE_DIR)/Caves/worldgenoverride.lua" "$(KLEI_DIR)/$(CLUSTER)/Caves/worldgenoverride.lua"; \
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
	@echo "  $(KLEI_DIR)/$(CLUSTER)/Master/worldgenoverride.lua"
	@echo "  $(KLEI_DIR)/$(CLUSTER)/Caves/worldgenoverride.lua"
	@echo ""
	@echo "Optional user mod files are not created automatically:"
	@echo "  $(USER_MODS_DIR)/extra_mods.lua"
	@echo "  $(USER_MODS_DIR)/Master/extra_modoverrides.lua"
	@echo "  $(USER_MODS_DIR)/Caves/extra_modoverrides.lua"

.PHONY: check_disk
check_disk:
	@storage="$$( $(RUNTIME) info --format '{{.Store.GraphRoot}}' 2>/dev/null || echo . )"; \
	[ -d "$$storage" ] || storage=.; \
	avail_kb=$$(df -Pk "$$storage" | awk 'NR==2 {print $$4}'); \
	avail_gb=$$((avail_kb / 1024 / 1024)); \
	if [ "$$avail_gb" -lt "$(MIN_FREE_GB)" ]; then \
		echo "ERROR: 容器存储可用空间不足：$${avail_gb}GB < $(MIN_FREE_GB)GB"; \
		echo "  路径: $$storage"; \
		echo "  DST 构建峰值磁盘占用约 15GB，冷构建（无缓存）建议 ≥ 20GB。"; \
		echo "  可执行 '$(RUNTIME) image prune' / '$(RUNTIME) system prune' 清理，或调小 MIN_FREE_GB。"; \
		exit 1; \
	fi; \
	echo "Disk check OK: $${avail_gb}GB free (>= $(MIN_FREE_GB)GB) at $$storage"

.PHONY: build
build: check_disk
	$(RUNTIME) build $(BUILD_ARGS) -t "$(IMAGE)" -f "$(CONTAINERFILE)" .

.PHONY: rebuild
rebuild: check_disk
	$(RUNTIME) build --no-cache $(BUILD_ARGS) -t "$(IMAGE)" -f "$(CONTAINERFILE)" .

.PHONY: check_token
check_token:
	@if [ ! -s "$(KLEI_DIR)/$(CLUSTER)/cluster_token.txt" ] \
		|| ! grep -q '[^[:space:]]' "$(KLEI_DIR)/$(CLUSTER)/cluster_token.txt"; then \
		echo "ERROR: cluster token is missing or empty:"; \
		echo "  $(KLEI_DIR)/$(CLUSTER)/cluster_token.txt"; \
		echo ""; \
		echo "Run 'make init', then put your DST cluster token into that file."; \
		exit 1; \
	fi

.PHONY: check_preset
check_preset:
	@for file in \
		"$(PRESET_DIR)/mods.lua" \
		"$(PRESET_DIR)/Master/modoverrides.lua" \
		"$(PRESET_DIR)/Caves/modoverrides.lua"; do \
		if [ ! -f "$$file" ]; then \
			echo "ERROR: missing preset file: $$file"; \
			exit 1; \
		fi; \
	done

.PHONY: up
up: up_master up_caves

# Master 与 Caves 必须共享网络命名空间：cluster.ini 中 master_ip = 127.0.0.1，
# 而 rootless Podman 下普通容器各自独立 netns 且没有独立 IP，只有同一个 pod 才能互通。
.PHONY: pod
pod:
	@$(RUNTIME) pod exists "$(POD_NAME)" >/dev/null 2>&1 || \
		$(RUNTIME) pod create --name "$(POD_NAME)" \
			--userns "$(USERNS)" \
			--share net,uts \
			-p "$(MASTER_PORT):10999/udp" \
			-p "$(CAVES_PORT):11000/udp" \
			-p "$(MASTER_SHARD_PORT):12346/udp" \
			-p "$(CAVES_SHARD_PORT):12347/udp"

.PHONY: up_master
up_master: check_token check_preset pod
	@$(RUNTIME) rm -f "$(CONTAINER_MASTER)" >/dev/null 2>&1 || true
	$(RUNTIME) run -d \
		--name "$(CONTAINER_MASTER)" \
		--pod "$(POD_NAME)" \
		-v "$(KLEI_DIR):/data/DoNotStarveTogether$(VOLUME_SUFFIX)" \
		-v "$(USER_MODS_DIR):/data/user_mods$(VOLUME_SUFFIX)" \
		-v "$(MOD_CACHE_DIR):/opt/dst/ugc_mods$(VOLUME_SUFFIX)" \
		-v "$(PRESET_DIR):/opt/dst_preset$(PRESET_VOLUME_SUFFIX)" \
		-e DST_CLUSTER="$(CLUSTER)" \
		-e DST_SHARD="Master" \
		"$(IMAGE)"

.PHONY: up_caves
up_caves: check_token check_preset pod
	@$(RUNTIME) rm -f "$(CONTAINER_CAVES)" >/dev/null 2>&1 || true
	$(RUNTIME) run -d \
		--name "$(CONTAINER_CAVES)" \
		--pod "$(POD_NAME)" \
		-v "$(KLEI_DIR):/data/DoNotStarveTogether$(VOLUME_SUFFIX)" \
		-v "$(USER_MODS_DIR):/data/user_mods$(VOLUME_SUFFIX)" \
		-v "$(MOD_CACHE_DIR):/opt/dst/ugc_mods$(VOLUME_SUFFIX)" \
		-v "$(PRESET_DIR):/opt/dst_preset$(PRESET_VOLUME_SUFFIX)" \
		-e DST_CLUSTER="$(CLUSTER)" \
		-e DST_SHARD="Caves" \
		"$(IMAGE)"

# 预下载 Workshop mod：拉起只更新 mod 的容器，下载完成后自行退出。
# 该目标是前台阻塞的，跑完即代表 mod 已就绪，可再 make up。
.PHONY: update_mods
update_mods: update_mods_master update_mods_caves

.PHONY: update_mods_master
update_mods_master: check_preset
	$(RUNTIME) run --rm \
		--userns "$(USERNS)" \
		-v "$(USER_MODS_DIR):/data/user_mods$(VOLUME_SUFFIX)" \
		-v "$(MOD_CACHE_DIR):/opt/dst/ugc_mods$(VOLUME_SUFFIX)" \
		-v "$(PRESET_DIR):/opt/dst_preset$(PRESET_VOLUME_SUFFIX)" \
		-e DST_MODS_ONLY=1 \
		-e DST_CLUSTER="$(CLUSTER)" \
		-e DST_SHARD="Master" \
		"$(IMAGE)"

.PHONY: update_mods_caves
update_mods_caves: check_preset
	$(RUNTIME) run --rm \
		--userns "$(USERNS)" \
		-v "$(USER_MODS_DIR):/data/user_mods$(VOLUME_SUFFIX)" \
		-v "$(MOD_CACHE_DIR):/opt/dst/ugc_mods$(VOLUME_SUFFIX)" \
		-v "$(PRESET_DIR):/opt/dst_preset$(PRESET_VOLUME_SUFFIX)" \
		-e DST_MODS_ONLY=1 \
		-e DST_CLUSTER="$(CLUSTER)" \
		-e DST_SHARD="Caves" \
		"$(IMAGE)"

.PHONY: down
down:
	@$(RUNTIME) rm -f "$(CONTAINER_MASTER)" >/dev/null 2>&1 || true
	@$(RUNTIME) rm -f "$(CONTAINER_CAVES)" >/dev/null 2>&1 || true
	@$(RUNTIME) pod rm -f "$(POD_NAME)" >/dev/null 2>&1 || true
	@echo "Stopped and removed containers and pod."

.PHONY: restart
restart: down up

.PHONY: restart_master
restart_master:
	$(RUNTIME) restart "$(CONTAINER_MASTER)"

.PHONY: restart_caves
restart_caves:
	$(RUNTIME) restart "$(CONTAINER_CAVES)"

.PHONY: logs_master
logs_master:
	$(RUNTIME) logs -f "$(CONTAINER_MASTER)"

.PHONY: logs_caves
logs_caves:
	$(RUNTIME) logs -f "$(CONTAINER_CAVES)"

.PHONY: ps
ps:
	$(RUNTIME) pod ps --filter "name=$(POD_NAME)"
	$(RUNTIME) ps -a --filter "name=$(CONTAINER_MASTER)" --filter "name=$(CONTAINER_CAVES)"

.PHONY: shell_master
shell_master:
	$(RUNTIME) exec -it "$(CONTAINER_MASTER)" /bin/bash

.PHONY: shell_caves
shell_caves:
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

.PHONY: clean_image
clean_image:
	-$(RUNTIME) rmi "$(IMAGE)"

.PHONY: clean_data
clean_data:
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

.PHONY: show_paths
show_paths:
	@echo "DATA_DIR=$(DATA_DIR)"
	@echo "KLEI_DIR=$(KLEI_DIR)"
	@echo "USER_MODS_DIR=$(USER_MODS_DIR)"
	@echo "MOD_CACHE_DIR=$(MOD_CACHE_DIR)"
	@echo "TOKEN=$(KLEI_DIR)/$(CLUSTER)/cluster_token.txt"
	@echo "MASTER_CONFIG=$(KLEI_DIR)/$(CLUSTER)/Master/server.ini"
	@echo "CAVES_CONFIG=$(KLEI_DIR)/$(CLUSTER)/Caves/server.ini"
