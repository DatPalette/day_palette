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

## 当前开发进度

目前已完成 MVP（Minimum Viable Product）阶段的核心功能开发：
- **UI & 交互**：完成主界面（Hero 区域、横向列表）、微缩胶囊（Sticky Mini-Hero）、设置面板的像素级还原与动效。
- **数据层**：完成 `TodayOutfitState` 的 Preferences 持久化，支持跨日快照与恢复。
- **选色扩展**：支持随机配色、昨日配色读取，以及自定义 HEX 精调（Fine-tune）。
- **出图与分享**：接入 ImageKit 实现离屏渲染（支持多套版式），接入 MediaLibrary 实现系统弹窗安全保存相册，接入 Share Kit 实现原生分享。
- **桌面卡片**：完成中卡（2x4）服务卡片（Form Card），与主应用状态同源并支持点击直达。
- **无障碍与体验**：支持“减少动效”、“轻噪点叠层”开关，主题跟随系统。

详细的阶段划分与完成情况请见：[`docs/ai-workflow/02-PHASED-IMPLEMENTATION-PLAN.md`](docs/ai-workflow/02-PHASED-IMPLEMENTATION-PLAN.md)。

## 工程说明

使用 DevEco Studio 创建 HarmonyOS 工程时，可将模块置于本目录下，或把本目录内容迁入 `entry/` 等标准结构；以你本地 Gradle/oh-package 布局为准。
