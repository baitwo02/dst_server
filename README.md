# DST Dedicated Server Distribution

基于 Podman 和 Containerfile 的《Don't Starve Together》Dedicated Server 发行版。仓库提供推荐 Mod preset，普通用户只需提供 cluster token 即可启动 Master 和 Caves。

## 特性

- 多阶段构建，runtime 镜像不包含 SteamCMD；
- 使用非 root 用户运行服务端；
- 自动初始化 cluster 和 shard 配置；
- 存档、配置、token 和 Mod 缓存保存在宿主机 `data/`；
- `preset/` 默认以只读 volume 挂载，修改后无需重建镜像；
- 支持通过 extra 文件追加或覆盖 Mod 配置；
- Master 和 Caves 默认共享 Mod 缓存。

## 默认 Mod

| Mod | Workshop ID |
| --- | --- |
| Global Positions | `378160973` |
| Show Me（中文） | `2287303119` |
| 防卡两招_新（维护版本） | `3044756151` |

这些 Mod 在 Master 和 Caves 中默认开启，并使用各自的默认配置。Makefile 会将宿主机 `preset/` 只读挂载到 `/opt/dst_preset`。运行镜像时必须提供该挂载。

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
make logs_master
make logs_caves
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

> **重要：`config_templates/` 与 `data/` 是两个不同的地方**
>
> - `config_templates/`（镜像内为 `/opt/dst_config_templates`）**只是初始化模板**，仅在 `data/` 下对应文件**不存在**时才会被复制过去；
> - 一旦 `data/` 下的文件存在，它就**永远不会被模板覆盖**（这是刻意的，防止丢失你的配置）；
> - 所以**改配置要改 `data/DoNotStarveTogether/...` 下的文件**，改模板不会生效。
>
> 如果确实想用模板重置某个配置，先删掉 `data/` 下的那个文件再 `make init`。
>
> 修改 `cluster.ini` / `server.ini` 后 `make restart` 即可生效，**无需重新生成世界**；只有 `worldgenoverride.lua` 需要重新生成世界。

## 世界设置（worldgenoverride.lua）

发行版在 `config_templates/` 下提供了完整的世界生成覆盖模板，`make init` 或容器启动时会在缺失时复制到：

```text
data/DoNotStarveTogether/Cluster_1/Master/worldgenoverride.lua
data/DoNotStarveTogether/Cluster_1/Caves/worldgenoverride.lua
```

- 模板列出了**全部**可配置项：发行版修改的项默认生效；其余项已注释，并标注了游戏默认值与合法取值；
- preset 分别为 `SURVIVAL_TOGETHER`（Master）和 `DST_CAVE`（Caves）；
- 发行版默认修改：

| 配置项 | 值 | 含义 |
| --- | --- | --- |
| `healthpenalty` | `none` | 禁用生命惩罚 |
| `twiggytrees_regrowth` | `never` | 树枝树不再重新生长 |
| `grassgekkos` | `never` | 不再生成草壁虎 |
| `mutated_buzzard_gestalt` | `never` | 不再生成变异秃鹫 |
| `loop` | `never` | 世界不循环 |
| `prefabswaps_start` | `classic` | 经典开局配置 |

想把发行版修改恢复为游戏默认，把对应行注释掉即可。

> **不要随意启用注释项**：`task_set`、`start_location` 等项的默认值按世界而定（洞窟应为 `cave_default` / `caves`），直接启用注释里的值会导致世界生成失败（例如 `PANIC: missing required prefab`）。

> **注意**：`worldgenoverride.lua` 只在**世界生成时**生效，不会改变已生成的世界。要让上述设置生效，需要删除对应的存档重新生成（旧存档请先备份）：
>
> ```bash
> make down
> rm -rf data/DoNotStarveTogether/Cluster_1/Master/save
> rm -rf data/DoNotStarveTogether/Cluster_1/Caves/save
> make up
> ```

## 添加用户 Mod

用户 Mod 不需要重新构建镜像。

创建 `data/user_mods/extra_mods.lua`：

```lua
ServerModSetup("1234567890")
```

然后在需要启用的 shard 创建覆盖文件，例如：

```text
data/user_mods/Master/extra_modoverrides.lua
data/user_mods/Caves/extra_modoverrides.lua
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

应用修改（先预下载新增 Mod，再重建容器）：

```bash
make update_mods
make restart
```

extra 中的同名 Workshop key 会覆盖发行版 preset。不要直接修改生成后的 shard `modoverrides.lua`，它会在下次启动时重写。

## 预下载 Mod

Mod 与游戏本体分开下载，服务端启动后不会等待 Workshop 下载完成。若直接 `make up`，可能出现服务端已在运行但 Mod 尚未就绪的情况。

`make update_mods` 会拉起只更新 Mod 的容器（`-only_update_server_mods`），下载/更新完成后容器自动退出。该命令是前台阻塞的，跑完即代表 Mod 已就绪：

```bash
make update_mods   # 依次为 Master 和 Caves 预下载
make up
```

下载内容持久化在 `data/mod_cache/`（容器内挂载到 `/opt/dst/ugc_mods`），Master 与 Caves 各自缓存。修改 `preset/mods.lua` 或 `data/user_mods/extra_mods.lua` 后，重新执行 `make update_mods` 即可。

## 更新

仅修改用户 extra 配置：

```bash
make restart
```

修改发行版 `preset/`：

```bash
make restart
```

修改镜像内的模板、启动脚本或其他运行时文件：

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

## 国内 / 镜像加速构建

基础镜像和 apt 软件源可通过构建变量替换，默认保持官方源不变：

```bash
make build \
  BASE_IMAGE=mirror.ccs.tencentyun.com/library/debian \
  APT_MIRROR=mirrors.cloud.tencent.com
```

- `BASE_IMAGE`：基础镜像地址，默认 `debian`；
- `DEBIAN_VERSION`：Debian 版本，默认 `bookworm`；
- `APT_MIRROR`：替换容器内 `deb.debian.org` / `security.debian.org` 的主机名，例如 `mirrors.cloud.tencent.com`（公网）或 `mirrors.tencentyun.com`（腾讯云内网）；为空时使用 Debian 默认源。

注意：该方式只能加速基础镜像和 apt 包。SteamCMD 与 DST 服务端本体仍需从 Steam CDN 下载，不受镜像源影响。若使用 Podman，还需在 `~/.config/containers/registries.conf` 配置 registry mirror；`mirror.ccs.tencentyun.com` 仅在腾讯云内网可用。

### Steam 下载失败与重试

Steam 没有公共国内镜像。SteamCMD 会根据客户端 IP / CellID 自动选择 CDN，国内机器通常会命中国内节点（可在 `~/Steam/logs/content_log.txt` 看到 `dl.steam.clngaa.com` 等）。

国内构建常见的两类瞬时失败：

- `api.steampowered.com` 间歇不可达时，SteamCMD 拿不到 CM 列表，会回退到内置的美国 CM，并长时间卡在 `Connecting anonymously to Steam Public... Retrying...`；
- 登录成功但拉取 appinfo 失败：`Failed to install app '343050' (Missing configuration)`。

`scripts/install_dst_server` 已内置处理：每次尝试前先等待 Steam Web API 可达（避免无谓地卡在美国 CM），对单次 steamcmd 设置超时，超时后清理残留进程并重试。可通过以下变量调整：

```bash
make build \
  STEAMCMD_ATTEMPTS=5 \
  STEAMCMD_RETRY_DELAY=10 \
  STEAMCMD_TIMEOUT=1800 \
  STEAMCMD_API_WAIT=600
```

- `STEAMCMD_ATTEMPTS`：失败重试次数，默认 `5`；
- `STEAMCMD_RETRY_DELAY`：重试间隔秒数，默认 `10`；
- `STEAMCMD_TIMEOUT`：单次 steamcmd 超时秒数，默认 `1800`；
- `STEAMCMD_API_WAIT`：每次尝试前等待 Steam Web API 可达的最长秒数，默认 `600`；
- `STEAMCMD_API_CHECK_TIMEOUT`：单次 API 探测超时秒数，默认 `15`；
- `STEAMCMD_URL`：SteamCMD 自举包地址，默认为官方地址，可换成自有镜像。

若多次重试仍失败，说明当前网络到 Steam 后端确实不可用（与 CDN 和镜像无关），建议更换构建时段或构建机器。

### 构建磁盘空间

DST 服务端本体约 4.6GB。构建时 builder 层、runtime 的 COPY 层和临时文件会同时占盘，实测单次 COPY 峰值需要约 **15GB 空闲**（冷构建无缓存时建议 ≥ 20GB）。空间不足会在最后一步报 `no space left on device`。

`make build` / `make rebuild` 会先执行 `check-disk`，低于阈值时直接报错退出：

```bash
make build MIN_FREE_GB=20
```

空间不足时可清理未使用的镜像与缓存：`podman image prune` / `podman system prune`。

## Master 与 Caves 互联

Master 和 Caves 运行在同一个 Podman pod（默认名 `dst`）中，共享网络命名空间，因此 `cluster.ini` 中的 `master_ip = 127.0.0.1` 才能用于 shard 互联。

- 游戏端口（10999/11000）和 shard 端口（12346/12347）都在 pod 级别发布；
- 不要脱离 pod 单独 `podman run` 这两个容器，否则又回到各自独立 netns、shard 无法互联；
- 修改端口后需先 `make down` 再 `make up`，否则旧 pod 会保留原端口映射；
- pod 只共享 `net,uts`（不共享 `ipc`），避免两个容器争用 Steam 的 `/dev/shm` 共享内存导致 Caves 的 SteamAPI 初始化失败；
- `POD_NAME` 变量可修改 pod 名称。

## 持久化与清理

以下目录均位于宿主机：

```text
data/DoNotStarveTogether/  # token、配置和存档
data/user_mods/            # 用户 Mod 扩展
data/mod_cache/            # Workshop Mod 缓存（UGC）
```

删除容器不会删除这些数据。以下操作会删除全部服务器数据，执行前必须确认：

```bash
make clean_data
```

## 常用命令

```text
make init          初始化本地数据
make build         使用缓存构建镜像
make rebuild       无缓存构建镜像
make up            启动 Master 和 Caves（同一个 pod）
make update_mods   预下载/更新 Workshop mod 后退出
make down          删除容器和 pod，并保留数据
make restart       重建容器和 pod
make ps            查看 pod 与容器状态
make help          查看全部命令
```

### 常见场景示例

```bash
# 国内加速构建（基础镜像与 apt 源走腾讯云镜像）
make build BASE_IMAGE=mirror.ccs.tencentyun.com/library/debian APT_MIRROR=mirrors.cloud.tencent.com

# 增删 Mod 后：先预下载，再重启（否则服务端会边跑边下 Mod）
make update_mods && make restart

# 改了 data/ 下的 cluster.ini / server.ini / mod 配置后：重启即可生效
make restart

# 改了 worldgenoverride.lua 后：必须删除存档重新生成世界
make down
rm -rf data/DoNotStarveTogether/Cluster_1/{Master,Caves}/{save,backup}
make up

# 改了 Containerfile / scripts 后：先重建镜像再重启
make build && make restart
```

默认针对 rootless Podman 配置用户映射，并使用共享 SELinux volume 标签。可通过 Makefile 变量覆盖镜像名、cluster、端口和数据目录。
