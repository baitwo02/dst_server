# syntax=docker/dockerfile:1

ARG DEBIAN_VERSION=bookworm

# SteamCMD 仅保留在构建阶段。
FROM debian:${DEBIAN_VERSION}-slim AS builder

ARG DST_APP_ID=343050
ENV DEBIAN_FRONTEND=noninteractive
ENV STEAMCMD_DIR=/opt/steamcmd
ENV DST_DIR=/opt/dst

RUN dpkg --add-architecture i386 \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        lib32gcc-s1 \
        lib32stdc++6 \
    && rm -rf /var/lib/apt/lists/*

RUN mkdir -p "${STEAMCMD_DIR}" "${DST_DIR}" \
    && curl -fsSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" \
      | tar -xz -C "${STEAMCMD_DIR}"

RUN "${STEAMCMD_DIR}/steamcmd.sh" \
      +force_install_dir "${DST_DIR}" \
      +login anonymous \
      +app_update "${DST_APP_ID}" validate \
      +quit


FROM debian:${DEBIAN_VERSION}-slim AS runtime

ENV DEBIAN_FRONTEND=noninteractive
ENV DST_DIR=/opt/dst
ENV DST_DATA_DIR=/data
ENV DST_CLUSTER=Cluster_1
ENV DST_SHARD=Master

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
RUN cp -a /opt/dst/mods /opt/dst-default-mods

COPY --chown=dst:dst config-templates /opt/dst-config-templates
COPY scripts/start-dst /usr/local/bin/start-dst
COPY scripts/merge-modoverrides.lua /usr/local/bin/merge-modoverrides.lua

RUN chmod +x \
      /usr/local/bin/start-dst \
      /usr/local/bin/merge-modoverrides.lua

USER dst
WORKDIR /opt/dst/bin

EXPOSE 10999/udp 11000/udp 12346/udp 12347/udp

ENTRYPOINT ["/usr/local/bin/start-dst"]
