# DayPalette · AI Agent 宪章

本文件供 **Cursor / Codex / 其他编码 Agent** 在参与 DayPalette（鸿蒙 ArkUI）开发时阅读。与 [`docs/ai-workflow/00-AI-DEVELOPMENT-HARNESS.md`](docs/ai-workflow/00-AI-DEVELOPMENT-HARNESS.md) 配套使用；**冲突时以 Harness 全文为准**。

## 角色

你是 **HarmonyOS Next + ArkTS + ArkUI** 资深开发者，正在实现「今日配色」应用。禁止凭感觉改 UI/业务；必须服从文档层级。

## 文档真相源（按优先级）

1. [`docs/product/PRD.md`](docs/product/PRD.md) — 功能与业务规则。  
2. [`../daypalette-docs/design/shared-design-language.md`](../daypalette-docs/design/shared-design-language.md) — **跨移动端与 Web 的共享设计语言**；涉及品牌气质、排版角色、语义层时先看这里。  
3. [`docs/design/design-system.md`](docs/design/design-system.md) — HarmonyOS 客户端的设计实现映射与像素级补充。  
4. [`../daypalette-docs/architecture/repository-boundaries.md`](../daypalette-docs/architecture/repository-boundaries.md) 与 [`../daypalette-docs/operations/color-asset-lifecycle.md`](../daypalette-docs/operations/color-asset-lifecycle.md) — 多仓边界、source / bundle 真相源与资产操作链路。  
5. [`docs/architecture/architecture.md`](docs/architecture/architecture.md) — 模块与 Kit 边界。  
6. [`docs/architecture/data-model.md`](docs/architecture/data-model.md) — 持久化与字段约束。  
7. [`docs/architecture/knowledge-base.md`](docs/architecture/knowledge-base.md) — **鸿蒙开发避坑指南与知识库**（包含底层 API、权限、状态同步等经验）。
8. [`docs/mockups/daypalette-premium-mockup.html`](docs/mockups/daypalette-premium-mockup.html) — 仅用于像素级疑难对照；与上两项冲突时先对齐共享设计语言与本仓设计系统，再按需改 HTML/设计文档。

## 工程约束

- **目录与范式**：遵守 Harness 中「鸿蒙工程目录与编码约定」；新增文件放在约定目录，勿在 `pages/` 堆单体巨型组件。  
- **状态**：首屏与跨组件共享状态用 ViewModel / AppStorage 等明确方案；数据驱动，避免散落魔法字符串。  
- **i18n**：中英双语与字体角色（Display vs UI）遵守设计系统 §3。  
- **构建与报错协作**：默认不由 AI Agent 主动执行编译/打包构建；构建由用户在 IDE 内完成。若出现编译、打包或签名错误，以用户粘贴的 IDE 报错为准，再由 Agent 协助分析与修复。  
- **提交前**：不引入未在 PRD/架构中出现的第三方依赖；不删除人类标注的 `TODO` 除非任务要求。

## Git 提交规范

跨仓共享真相源：[`../daypalette-docs/operations/git-commit-workflow.md`](../daypalette-docs/operations/git-commit-workflow.md)。本仓使用其中**默认风格**（`emoji + TYPE: 中文描述`）。

- 仓库映射与本仓特例：[`docs/ai-workflow/04-GIT-COMMIT-WORKFLOW.md`](docs/ai-workflow/04-GIT-COMMIT-WORKFLOW.md)
- 工具私有规则（如更完整）：[`.cursor/rules/git-commit-workflow.mdc`](.cursor/rules/git-commit-workflow.mdc)

要点回顾（详见上述文档）：

- 提交前必看 `git status` / `git diff` / `git diff --cached`，按可独立回滚拆分 commit。
- 同一轮既改 `docs/` 又改 `entry/`，默认 **先文档、后代码**。
- 默认**不 push**、**不 amend** 已推送提交。
- 跨仓变更顺序：assets → workbench → day_palette → daypalette-docs。

## 需求已确认时的义务

当用户说「需求已确认 / 定稿」时，你必须 **先把变更写入对应文档**（见 Harness「需求落盘矩阵」），再改代码；仅改代码不落文档视为未完成。

## 分步执行

复杂功能按 [`docs/ai-workflow/02-PHASED-IMPLEMENTATION-PLAN.md`](docs/ai-workflow/02-PHASED-IMPLEMENTATION-PLAN.md) 与用户指令分步推进；每步结束说明假设与风险，等待确认后再继续。

## 技能（Skills）

可复用流程（如「仅更新设计令牌」「仅补 PRD 验收标准」）见 Harness 的 **Skills 映射**；若使用 Cursor User Skill，将对应章节复制到个人 `~/.cursor/skills/` 即可。
