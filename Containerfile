# syntax=docker/dockerfile:1

# 基础镜像可通过 BASE_IMAGE 指向任意镜像源，例如：
#   docker.m.daocloud.io/library/debian
#   mirror.ccs.tencentyun.com/library/debian
ARG BASE_IMAGE=debian
ARG DEBIAN_VERSION=bookworm

# SteamCMD 仅保留在构建阶段。
FROM ${BASE_IMAGE}:${DEBIAN_VERSION}-slim AS builder

ARG DST_APP_ID=343050
ARG APT_MIRROR=

# SteamCMD 自举包地址，可替换为自有镜像。
# Steam 官方无公共国内镜像；游戏本体由 Steam 按 CellID 自动选择 CDN。
ARG STEAMCMD_URL=https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz
ARG STEAMCMD_ATTEMPTS=5
ARG STEAMCMD_RETRY_DELAY=10
ARG STEAMCMD_TIMEOUT=1800
ARG STEAMCMD_API_WAIT=600
ARG STEAMCMD_API_CHECK_TIMEOUT=15

# 可选：将 Debian 默认软件源替换为镜像源（例如 mirrors.cloud.tencent.com）。
# 直接使用字面路径，避免不同构建器对 "$$" 转义处理不一致。
RUN if [ -n "${APT_MIRROR}" ]; then \
      if [ -f /etc/apt/sources.list ]; then \
        sed -i "s|deb.debian.org|${APT_MIRROR}|g; s|security.debian.org|${APT_MIRROR}|g" /etc/apt/sources.list; \
      fi; \
      if [ -f /etc/apt/sources.list.d/debian.sources ]; then \
        sed -i "s|deb.debian.org|${APT_MIRROR}|g; s|security.debian.org|${APT_MIRROR}|g" /etc/apt/sources.list.d/debian.sources; \
      fi; \
    fi
ENV DEBIAN_FRONTEND=noninteractive
ENV STEAMCMD_DIR=/opt/steamcmd
ENV DST_DIR=/opt/dst
ENV STEAMCMD_ATTEMPTS="${STEAMCMD_ATTEMPTS}" \
    STEAMCMD_RETRY_DELAY="${STEAMCMD_RETRY_DELAY}" \
    STEAMCMD_TIMEOUT="${STEAMCMD_TIMEOUT}" \
    STEAMCMD_API_WAIT="${STEAMCMD_API_WAIT}" \
    STEAMCMD_API_CHECK_TIMEOUT="${STEAMCMD_API_CHECK_TIMEOUT}"

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        lib32gcc-s1 \
        lib32stdc++6 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p "${STEAMCMD_DIR}" "${DST_DIR}" \
    && curl -fsSL "${STEAMCMD_URL}" \
      | tar -xz -C "${STEAMCMD_DIR}"

COPY scripts/install_dst_server /usr/local/bin/install_dst_server
RUN chmod +x /usr/local/bin/install_dst_server \
    && /usr/local/bin/install_dst_server


FROM ${BASE_IMAGE}:${DEBIAN_VERSION}-slim AS runtime

ARG APT_MIRROR=

ENV DEBIAN_FRONTEND=noninteractive
ENV DST_DIR=/opt/dst
ENV DST_DATA_DIR=/data
ENV DST_CLUSTER=Cluster_1
ENV DST_SHARD=Master

# 可选：将 Debian 默认软件源替换为镜像源（例如 mirrors.cloud.tencent.com）。
# 直接使用字面路径，避免不同构建器对 "$$" 转义处理不一致。
RUN if [ -n "${APT_MIRROR}" ]; then \
      if [ -f /etc/apt/sources.list ]; then \
        sed -i "s|deb.debian.org|${APT_MIRROR}|g; s|security.debian.org|${APT_MIRROR}|g" /etc/apt/sources.list; \
      fi; \
      if [ -f /etc/apt/sources.list.d/debian.sources ]; then \
        sed -i "s|deb.debian.org|${APT_MIRROR}|g; s|security.debian.org|${APT_MIRROR}|g" /etc/apt/sources.list.d/debian.sources; \
      fi; \
    fi

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        lua5.4 \
        lib32gcc-s1 \
        lib32stdc++6 \
        libc6:i386 \
        libgcc-s1:i386 \
        libstdc++6:i386 \
        libcurl3-gnutls:i386 \
    && rm -rf /var/lib/apt/lists/* \
    && useradd -m -u 10001 -s /usr/sbin/nologin dst

# 复制时直接设置所有者，避免递归 chown 复制整个 DST 镜像层。
COPY --from=builder --chown=dst:dst /opt/dst /opt/dst

# 保留原始 mods，以便挂载空的持久化目录后进行初始化。
RUN cp -a /opt/dst/mods /opt/dst_default_mods

COPY --chown=dst:dst config_templates /opt/dst_config_templates
COPY scripts/start_dst /usr/local/bin/start_dst
COPY scripts/merge_modoverrides.lua /usr/local/bin/merge_modoverrides.lua

RUN chmod +x \
      /usr/local/bin/start_dst \
      /usr/local/bin/merge_modoverrides.lua

USER dst
WORKDIR /opt/dst/bin

EXPOSE 10999/udp 11000/udp 12346/udp 12347/udp

ENTRYPOINT ["/usr/local/bin/start_dst"]
