# SnapRun

<p align="center">
  <img src="docs/icon.png" width="128" height="128" alt="SnapRun Icon">
</p>

<h3 align="center">SnapRun</h3>

<p align="center">
  <strong>一款原生 macOS 定时任务管理应用</strong><br>
  无需 crontab，无需 launchd，交给 SnapRun。
</p>

<p align="center">
  <a href="https://github.com/yes01/SnapRun/releases/latest"><img src="https://img.shields.io/github/v/release/yes01/SnapRun?style=flat-square&color=34D399&label=%E6%9C%80%E6%96%B0%E7%89%88%E6%9C%AC" alt="最新版本"></a>
  <a href="https://github.com/yes01/SnapRun/releases"><img src="https://img.shields.io/github/downloads/yes01/SnapRun/total?style=flat-square&color=7C3AED&label=%E4%B8%8B%E8%BD%BD%E6%AC%A1%E6%95%B0" alt="下载次数"></a>
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-blue?style=flat-square" alt="Platform">
  <a href="https://www.gnu.org/licenses/gpl-3.0.html"><img src="https://img.shields.io/badge/license-GPL--3.0-blue?style=flat-square" alt="License"></a>
</p>

<p align="center">
  <a href="https://github.com/yes01/SnapRun/releases/latest">下载最新版本</a>
  ·
  <a href="README.md">English</a>
</p>

---

<p align="center">
  <img src="https://cdn.jsdelivr.net/gh/lifedever/images@master/uPic/2026/03/CS2026-03-16-12.47.53@2x.png" width="800" alt="SnapRun 截图">
</p>

## 功能特性

- 原生菜单栏应用，常驻后台，随时可用
- 支持单次与重复任务的灵活调度
- 支持执行内联脚本或本地脚本文件，如 `.sh`、`.py`、`.rb`、`.js`
- 内置脚本模板，也支持保存和复用自定义模板
- 记录 stdout、stderr、耗时与退出码
- 支持 macOS 原生通知
- 支持导入已有 crontab 任务
- 支持多语言界面

## 安装

### 下载

从 [Releases](https://github.com/yes01/SnapRun/releases) 下载最新 `.dmg`：

| 文件 | 架构 |
|------|------|
| `SnapRun-x.x.x-arm64.dmg` | Apple Silicon (M1/M2/M3/M4) |
| `SnapRun-x.x.x-x86_64.dmg` | Intel Mac |

> 首次打开时，右键点击 `SnapRun.app`，选择“打开”。
>
> 或在终端执行：`xattr -cr /Applications/SnapRun.app`

### 从源码构建

```bash
git clone https://github.com/yes01/SnapRun.git
cd SnapRun
./scripts/build-dev.sh
```

## 兼容性说明

- 当前对外项目名已经统一为 `SnapRun`。
- 为了兼容现有实现，SwiftPM target 和 CLI 命令暂时仍保留 `TaskTick` / `tasktick` 命名。
- 如果现在需要使用 CLI，请执行 `swift run tasktick --help`。

## 许可证

GPL-3.0 © [yes01](https://github.com/yes01)
