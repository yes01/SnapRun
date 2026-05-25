# SnapRun

<p align="center">
  <img src="docs/icon.png" width="128" height="128" alt="SnapRun Icon">
</p>

<h3 align="center">SnapRun</h3>

<p align="center">
  <strong>A native macOS app for managing scheduled tasks.</strong><br>
  No crontab, no launchd - just SnapRun.
</p>

<p align="center">
  <a href="https://github.com/yes01/SnapRun/releases/latest"><img src="https://img.shields.io/github/v/release/yes01/SnapRun?style=flat-square&color=34D399&label=Latest" alt="Latest Release"></a>
  <a href="https://github.com/yes01/SnapRun/releases"><img src="https://img.shields.io/github/downloads/yes01/SnapRun/total?style=flat-square&color=7C3AED&label=Downloads" alt="Downloads"></a>
  <img src="https://img.shields.io/badge/platform-macOS%2014%2B-blue?style=flat-square" alt="Platform">
  <a href="https://www.gnu.org/licenses/gpl-3.0.html"><img src="https://img.shields.io/badge/license-GPL--3.0-blue?style=flat-square" alt="License"></a>
</p>

<p align="center">
  <a href="https://github.com/yes01/SnapRun/releases/latest">Download Latest</a>
  |
  <a href="README_zh.md">Chinese README</a>
</p>

---

<p align="center">
  <img src="https://cdn.jsdelivr.net/gh/lifedever/images@master/uPic/2026/03/CS2026-03-16-12.47.53@2x.png" width="800" alt="SnapRun Screenshot">
</p>

## Features

- Native menu bar app that stays available in the background
- Flexible scheduling for one-off and repeated runs
- Inline script or local file execution for `.sh`, `.py`, `.rb`, `.js`, and more
- Built-in script templates plus reusable custom templates
- Execution logs with stdout, stderr, duration, and exit codes
- macOS notifications for task completion and failures
- Crontab import for existing scheduled jobs
- Multilingual UI with English and Simplified Chinese support

## Install

### Download

Grab the latest `.dmg` from [Releases](https://github.com/yes01/SnapRun/releases):

| File | Architecture |
|------|-------------|
| `SnapRun-x.x.x-arm64.dmg` | Apple Silicon (M1/M2/M3/M4) |
| `SnapRun-x.x.x-x86_64.dmg` | Intel Mac |

> On first launch: right-click `SnapRun.app` and choose `Open`.
>
> Or run: `xattr -cr /Applications/SnapRun.app`

### Build from Source

```bash
git clone https://github.com/yes01/SnapRun.git
cd SnapRun
./scripts/build-dev.sh
```

## Compatibility Notes

- The app is now branded as `SnapRun`.
- The internal SwiftPM targets and CLI command still use `TaskTick` / `tasktick` for compatibility during the rename.
- If you need the CLI today, use `swift run tasktick --help`.

## License

GPL-3.0 (c) [yes01](https://github.com/yes01)
