# DST Dedicated Server Distribution

基于 Podman 和 Containerfile 的《Don't Starve Together》Dedicated Server 发行版镜像。镜像内置推荐 Mod preset，普通用户只需提供 cluster token 即可启动 Master 和 Caves。

## 特性

- 多阶段构建，runtime 镜像不包含 SteamCMD；
- 使用非 root 用户运行服务端；
- 自动初始化 cluster 和 shard 配置；
- 存档、配置、token 和 Mod 缓存保存在宿主机 `data/`；
- 支持通过 extra 文件追加或覆盖 Mod 配置；
- Master 和 Caves 默认共享 Mod 缓存。

## 默认 Mod

| Mod | Workshop ID |
| --- | --- |
| Global Positions | `378160973` |
| Show Me（中文） | `2287303119` |
| 防卡两招_新（维护版本） | `3044756151` |

这些 Mod 在 Master 和 Caves 中默认开启，并使用各自的默认配置。

## 快速开始

### 1. 初始化

```bash
make init
```

该命令会创建运行目录、默认配置和空的 token 文件，但不会覆盖已有配置。

### 2. 填写 cluster token

将 Klei 生成的 DST cluster token 写入：

```text
data/DoNotStarveTogether/Cluster_1/cluster_token.txt
```

文件不能为空。不要把真实 token 提交到 Git。

### 3. 构建并启动

```bash
make build
make up
```

查看状态和日志：

```bash
make ps
make logs-master
make logs-caves
```

停止并删除容器：

```bash
make down
```

该操作不会删除 `data/`。

## 配置

`make init` 会创建：

```text
data/DoNotStarveTogether/Cluster_1/cluster.ini
data/DoNotStarveTogether/Cluster_1/Master/server.ini
data/DoNotStarveTogether/Cluster_1/Caves/server.ini
```

可以直接修改这些文件。再次运行 `make init` 或重建容器不会覆盖已有配置。

## 添加用户 Mod

用户 Mod 不需要重新构建镜像。

创建 `data/user-mods/extra_mods.lua`：

```lua
ServerModSetup("1234567890")
```

然后在需要启用的 shard 创建覆盖文件，例如：

```text
data/user-mods/Master/extra_modoverrides.lua
data/user-mods/Caves/extra_modoverrides.lua
```

内容：

```lua
return {
  ["workshop-1234567890"] = {
    enabled = true,
    configuration_options = {},
  },
}
```

应用修改：

```bash
make restart
```

extra 中的同名 Workshop key 会覆盖镜像 preset。不要直接修改生成后的 shard `modoverrides.lua`，它会在下次启动时重写。

## 更新

仅修改用户 extra 配置：

```bash
make restart
```

修改发行版 preset：

```bash
make build
make restart
```

更新 DST 服务端本体：

```bash
make rebuild
make restart
```

`make rebuild` 会禁用构建缓存并重新执行 SteamCMD 下载。更新服务端前建议备份 `data/`。

## 持久化与清理

以下目录均位于宿主机：

```text
data/DoNotStarveTogether/  # token、配置和存档
data/user-mods/            # 用户 Mod 扩展
data/mod-cache/            # Mod 文件
```

删除容器不会删除这些数据。以下操作会删除全部服务器数据，执行前必须确认：

```bash
make clean-data
```

## 常用命令

```text
make init          初始化本地数据
make build         使用缓存构建镜像
make rebuild       无缓存构建镜像
make up            启动 Master 和 Caves
make down          删除容器并保留数据
make restart       重建两个容器
make ps            查看容器状态
make help          查看全部命令
```

默认针对 rootless Podman 配置用户映射，并使用共享 SELinux volume 标签。可通过 Makefile 变量覆盖镜像名、cluster、端口和数据目录。
