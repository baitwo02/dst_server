# AGENTS.md

## 项目定位

本项目是一个基于 Podman/Containerfile 的《Don't Starve Together》Dedicated Server 发行版镜像。

核心思路是提供一套开箱即用的 mod preset：普通用户只需提供 cluster token；高级用户可通过宿主机 `data/user-mods` 下的 extra 文件追加或覆盖 mod 配置。

## 项目架构

```text
.
├── Containerfile              # 多阶段构建镜像
├── Makefile                   # 构建、启动、停止和日志管理
├── scripts/
│   ├── start-dst              # 初始化配置并启动 shard
│   └── merge-modoverrides.lua # 合并 preset 与用户覆盖配置
├── preset/                    # 镜像内置的发行版 mod preset
│   ├── mods.lua
│   ├── Master/modoverrides.lua
│   └── Caves/modoverrides.lua
└── config-templates/          # cluster 与 shard 默认配置
```

宿主机运行数据统一放在 `data/`：

- `DoNotStarveTogether/`：token、配置和存档；
- `user-mods/`：可选的用户 mod 扩展配置；
- `mod-cache/`：持久化的 mod 文件。

## 镜像设计

Containerfile 使用多阶段构建：

1. **builder**：使用 SteamCMD 下载 DST Dedicated Server；
2. **runtime**：仅复制 DST 本体，并安装必要运行依赖和 Lua 5.4。

运行镜像不得包含 SteamCMD，并使用非 root 用户启动。DST 本体通过重新构建镜像更新，不在容器启动时自动更新。

## 启动流程

`start-dst` 负责：

1. 初始化运行目录；
2. 在配置不存在时复制默认模板；
3. 检查用户提供的 `cluster_token.txt`；
4. 恢复被 volume 覆盖的 DST 原始 mods 目录；
5. 根据 preset 和可选 extra 文件生成最终 mod 配置；
6. 启动指定的 Master 或 Caves shard。

`dedicated_server_mods_setup.lua` 可按 preset + extra 进行文本拼接；`modoverrides.lua` 必须通过 Lua table 合并，且 extra 中的同名 key 覆盖 preset。

## 关键约束

- extra 文件是可选的，不得由脚本自动创建；文件存在即表示启用用户扩展。
- 没有 extra 文件时直接使用镜像内置 preset。
- 生成后的 shard `modoverrides.lua` 会在启动时重写，用户应修改 `data/user-mods` 下的 extra 文件。
- `cluster_token.txt` 必须由用户提供；缺失时应清晰报错并退出。
- 默认模板只能初始化缺失配置，不得覆盖已有用户配置。
- 存档、token、配置和 mod 缓存必须持久化在宿主机 `data/`。
- 删除容器不得删除数据；删除 `data/` 属于危险操作，必须明确提示。
- Master 和 Caves 默认共享持久化目录及 mod cache。

## 开发原则

- 保持发行版默认可用，同时让用户扩展保持最小侵入。
- 修改 preset 时同步检查下载列表及 Master/Caves 启用配置。
- 修改端口或挂载方式时同步检查模板、Containerfile 和 Makefile。
- 不提交 `data/`、真实 token、存档或 mod 缓存。
- Shell 脚本应严格失败，Lua 合并错误应输出到 stderr 并返回非零状态。
- 若新增用户可见行为，应同步更新 README（若存在）。

## 用户心智模型

```text
不添加 extra 文件：使用发行版默认 preset。
添加 extra_mods.lua：追加 Workshop 下载列表。
添加 extra_modoverrides.lua：追加或覆盖 shard mod 配置。
删除容器：不会删除存档。
删除 data：会删除全部持久化数据。
```
