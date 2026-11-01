# SKlauncher 4.0.55 简体中文补丁

非官方中文语言包。适用于 **SKlauncher 4.0.55 Windows x64 安装版**。

> **普通用户请到本仓库的 Releases 下载：**
> - `SKlauncher-zh-CN-patch-4.0.55.zip`（中文补丁）
> - `SKlauncher-4.0.55-setup.exe`（原版安装包镜像）
>
> 仓库源码里不包含这些二进制文件。

## 这个补丁做了什么

- 在启动器原有 `en / pl / es / pt` 语言框架中新增 `zh`（简体中文）。
- 翻译了 1657 条界面文案：主页、设置、实例、下载、账号、错误提示、崩溃报告等。
- 托盘菜单、检查更新对话框、顶部版本徽章也已中文化。
- 首次启动会自动切换到中文，之后可在「设置 → 通用 → 语言」中切换。
- 保留英文、波兰文、西班牙文、葡萄牙文，可随时切回。

以下内容有意保留英文：

- 服务器标签和玩法缩写：`PVP`、`SMP`、`PvE`、`BedWars`、`SkyBlock`、`Lifesteal`、`Anarchy`、`KitPvP` 等。
- 服务器名称、服务器简介、新闻标题/正文（来自在线接口）。
- 模组名、整合包名、作者名、品牌名（Minecraft、Fabric、Forge、Modrinth、CurseForge 等）。

## 使用前提

1. 先安装 **SKlauncher 4.0.55 原版**（本仓库 Release 中附有原版安装包镜像）。
2. 不需要开启代理。
3. 关闭正在运行的 SKlauncher。

## 安装步骤

1. 下载 `SKlauncher-zh-CN-patch-4.0.55.zip` 并**完整解压**。
2. 双击 `安装中文.bat`。
3. 看到「安装完成」后，启动器会自动打开，界面为中文。
4. 如果 Windows 拦截脚本，右键 `安装中文.bat` → 以管理员身份运行。

补丁会自动：

- 找到 SKlauncher 安装目录；
- 备份原版 `resources\app.asar` 和 `sklauncher.exe` 到 `zh-backup`；
- 替换为中文 `app.asar`；
- 关闭 exe 中的 asar 完整性校验（否则修改后的 asar 无法加载）。

## 恢复原版

双击 `恢复原版.bat`，会从 `zh-backup` 目录恢复最近一次的原版文件。

## 常见问题

### 提示 app.asar 大小不对

说明安装的不是 4.0.55，或者已经被其他补丁改过。请先安装本仓库提供的 4.0.55 原版。

### 提示找不到 SKlauncher

默认安装路径是：

```text
C:\Users\<用户名>\AppData\Local\Programs\sklauncher
```

如果安装到了其他位置，可以在 PowerShell 中指定：

```powershell
powershell -ExecutionPolicy Bypass -File install.ps1 -InstallDir "D:\Games\sklauncher"
```

### 启动器打不开

运行 `恢复原版.bat`。如果仍然打不开，重新安装原版 4.0.55。

### 自动更新后中文消失

SKlauncher 自动更新会覆盖 `app.asar`，需要重新运行一次补丁。更新后的版本如果不再是 4.0.55，本补丁会拒绝执行。

## 文件说明

| 文件 | 用途 |
|---|---|
| `app.asar` | 已编译中文语言包的启动器资源 |
| `install.ps1` | 安装/打补丁脚本 |
| `restore.ps1` | 恢复原版脚本 |
| `安装中文.bat` | 双击安装 |
| `恢复原版.bat` | 双击恢复 |
| `zh-CN.json` | 词典导出（1502 条界面词条，供查阅） |

## 免责声明

- 本项目是非官方修改版，与 SKlauncher 作者无关。
- SKlauncher 是闭源软件，使用本补丁前请确保你拥有合法的 SKlauncher 副本。
- 本补丁只修改本地安装文件，不上传账号、不收集数据。
- 因自动更新、重装或其他修改导致的失效或损坏，请使用备份恢复。
- 如果你要重新分发，请自行确认是否符合 SKlauncher 的许可条款。

## 注
- PCL和HMCL最近因为中国法律原因用不了了，SKLauncher可能需要代理，如果无法使用，推荐使用[BHL](https://github.com/zqq-699/BlockHelm-Launcher)
