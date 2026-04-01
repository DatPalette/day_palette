---
name: daypalette-dev
description: >-
  DayPalette 鸿蒙项目：需求落盘、遵守设计系统与 PRD、按约定目录写 ArkTS。
  在开发今日配色 App、改需求、或 Vibe coding 时使用。
---

# DayPalette 鸿蒙开发 Skill

## 何时使用

- 用户要新增/变更功能且已口头确认需求。
- 用户要你实现 ArkUI 界面或 ViewModel。
- 用户说「按项目规范」「先看文档再写代码」。

## 必须遵守的顺序

1. 读 **`day-palette/AGENTS.md`** 与 **`day-palette/docs/ai-workflow/00-AI-DEVELOPMENT-HARNESS.md`**（至少浏览 §2 落盘矩阵与 §4 目录）。
2. 若用户已确认需求：**先改文档**（PRD / design-system / architecture / data-model 等对应项），再改 `entry/` 代码。
3. 实现 UI 时：**`day-palette/docs/design/design-system.md`** 为默认令牌源；疑难像素对照 **`day-palette/docs/mockups/daypalette-premium-mockup.html`**。
4. 代码放入约定目录：`pages/`（薄）、`components/`、`viewmodel/`、`model/`、`common/constants/`（见 Harness §4）。

## 不要做的事

- 不新增设计系统未覆盖的色板/圆角体系（除非同步更新 `design-system.md`）。
- 不把整页 UI 写进单个巨型 `Index.ets` 不拆分。
- 不在未更新 PRD 的情况下实现 PRD 未描述的功能。

## 参考路径

以下路径相对于**包含 `day-palette` 文件夹的仓库根**。若工作区根就是本 Skill 所在项目根，则去掉前缀 `day-palette/`。

- PRD：`day-palette/docs/product/PRD.md`
- 设计系统：`day-palette/docs/design/design-system.md`
- 分阶段任务：`day-palette/docs/ai-workflow/02-PHASED-IMPLEMENTATION-PLAN.md`
- Prompt 片段：`day-palette/docs/ai-workflow/03-PROMPT-GUIDE-HARMONYOS.md`

## 安装到 Cursor

将本目录 **复制** 到 `~/.cursor/skills/daypalette-dev/`，或在本机 Cursor 支持「项目技能」时链接到该目录。详细说明见 Harness §6。
