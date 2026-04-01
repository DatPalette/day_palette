# DayPalette · 今日配色

鸿蒙应用 **今日配色（DayPalette）** 的工程与文档目录。

## AI / Agent 开发（Vibe coding 入口）

| 路径 | 说明 |
|------|------|
| **`AGENTS.md`** | Cursor 等 Agent 的短宪章（必读） |
| **`docs/ai-workflow/00-AI-DEVELOPMENT-HARNESS.md`** | **总册**：需求落盘、设计系统治理、鸿蒙目录与范式、Rules/Skills 分工 |
| 宿主仓库根 `.cursor/rules/day-palette-harmonyos.mdc` | 工作区打开**整个宿主仓库**、且本目录为其子文件夹时生效（glob 需匹配 `day-palette/**`） |
| `day-palette/.cursor/rules/day-palette-harmonyos.mdc` | 工作区**仅打开 `day-palette`** 时生效 |

## 文档

| 路径 | 说明 |
|------|------|
| `docs/product/PRD.md` | **产品需求文档**（必读） |
| `docs/design/design-system.md` | **设计系统**：色板、字体、间距、组件与动效令牌（长期约束 AI） |
| `docs/architecture/architecture.md` | 技术架构概要 |
| `docs/architecture/data-model.md` | 本地数据与 JSON 资源结构 |
| `docs/mockups/daypalette-premium-mockup.html` | 高保真 HTML 原型（像素级对照） |
| `docs/ai-workflow/` | 分阶段计划、Prompt 指南、Harness |
| `docs/release/test-release-checklist.md` | 测试与上架检查 |

## 总体规划

若宿主仓库根目录存在 **`应用规划-今日穿搭色卡.md`** 等规划文档，可与本目录文档对照阅读。

## 工程说明

使用 DevEco Studio 创建 HarmonyOS 工程时，可将模块置于本目录下，或把本目录内容迁入 `entry/` 等标准结构；以你本地 Gradle/oh-package 布局为准。
