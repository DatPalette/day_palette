# Git 提交流程（day_palette 仓库映射）

> 共享真相源已收口到 [`../../../../daypalette-docs/operations/git-commit-workflow.md`](../../../../daypalette-docs/operations/git-commit-workflow.md)。
> 本文只保留 `day_palette` 仓库的**特例与指针**，避免与共享版重复维护。
> 归档提示：自 2026-04-29 起，`daypalette-color-assets` / `daypalette-palette-workbench` 相关跨仓提交流程已归档。若未来重启新的配色运营多仓方案，必须先更新共享层文档，再定义新的提交顺序。

- 面向对象：Cursor、Copilot、Codex、手动命令行提交者。
- 适用场景：用户明确要求「提交 / commit / 提代码」时。
- 实现细则：若 [`.cursor/rules/git-commit-workflow.mdc`](../../.cursor/rules/git-commit-workflow.mdc) 存在更完整版本，由它承担工具落地细节；本文只声明仓库共识与特例。

---

## 1. 基本规范

请优先阅读共享版 [`git-commit-workflow.md`](../../../../daypalette-docs/operations/git-commit-workflow.md)，本仓直接采用其中：

- §1 提交前必看
- §2 按可独立回滚拆分 commit
- §3.1 默认风格 `emoji + TYPE: 中文描述`
- §4 暂存纪律
- §5 执行边界
- §6 跨仓变更协作

---

## 2. day_palette 特例

仅在共享版基础上补充以下与 HarmonyOS 工程相关的约束。

### 2.1 文档优先

若同一轮迭代既改 `docs/` 又改 `entry/`，默认 **先文档、后代码** 拆成两个 commit：先 `📖 DOC:`，再 `📦 NEW:` / `👌 IMPROVE:` / `🐛 FIX:`。

### 2.2 鸿蒙工程默认不提交

下列内容默认不进版本库；若已存在 `.gitignore`，**不要** `git add -f`：

- `entry/build/`、`entry/.hvigor/`、`entry/.preview/`
- `oh_modules/`
- 本地签名 / 证书 / `*.p7b` / `*.cer` / `*.p12`
- 个人 IDE 状态（`.idea/workspace.xml` 等）

### 2.3 与跨仓发布的衔接

2026-04-29 起，assets / workbench 的旧跨仓链路已归档。当前默认只处理 `day_palette` 与 `daypalette-docs` 的协作；若未来恢复新的配色运营多仓方案，必须先补共享层文档，再定义新的主题串联与提交顺序。

---

## 3. 与本仓其他文档的关系

- 仓库级 AI 行为约束：[`../../AGENTS.md`](../../AGENTS.md)
- AI 开发总控规则：[`00-AI-DEVELOPMENT-HARNESS.md`](./00-AI-DEVELOPMENT-HARNESS.md)
- 工具私有规则：[`.cursor/rules/git-commit-workflow.mdc`](../../.cursor/rules/git-commit-workflow.mdc)
# Git 提交流程（仓库公开版）

本文是 DayPalette 仓库内公开可见的 Git 提交流程说明，供不同 AI Agent、协作者和后续维护者共用。

- 面向对象：Cursor、Copilot、Codex、手动命令行提交者。
- 适用场景：用户明确要求“提交 / commit / 提代码”时。
- 细则来源：若 `.cursor/rules/git-commit-workflow.mdc` 存在且内容更完整，以其为实现细则；本文作为仓库公开版共识文档。

---

## 1. 提交前先看变更

提交前至少检查以下三项：

1. `git status`
2. `git diff`
3. `git diff --cached`

目的不是走流程，而是确认三件事：

- 本次提交范围是否准确。
- 是否混入无关文件、调试残留、IDE 私有状态。
- 暂存区和工作区是否与预期一致。

如存在未跟踪文件，先判断是否应该提交；构建产物、缓存、签名、密钥、证书、个人本地配置默认不提交。

---

## 2. 按可独立回滚拆分 commit

提交拆分原则：**每个 commit 都应能被单独理解、单独回滚、单独复查。**

推荐拆分方式：

- 文档与代码分开。
- 新功能与修复分开。
- UI 调整与逻辑重构分开。
- 配置 / 工具链改动与业务实现分开。

DayPalette 当前额外约束：

- 若同一轮同时修改 `docs/` 与 `entry/`，默认优先 **先文档、后代码**。
- 若需求刚确认，先完成文档落盘，再进入代码提交。
- 不把无关重构塞进功能提交中。

---

## 3. 提交信息格式

提交主题行使用：**中文 + emoji + 英文大写类型前缀**。

统一格式：

```text
emoji + TYPE: 中文描述
```

示例：

- `📦 NEW: 新增智能配结果卡片`
- `👌 IMPROVE: 优化今日页三个入口按钮布局`
- `🐛 FIX: 修复昨日快照跨多天误判问题`
- `📖 DOC: 更新配色资产与智能配策略文档`

常用类型：

- `📦 NEW:` 新增功能 / 新模块
- `👌 IMPROVE:` 改进 / 重构 / 样式优化 / 性能优化 / 文案微调
- `🐛 FIX:` 缺陷修复 / 回归修复
- `📖 DOC:` 文档 / PRD / 设计说明更新
- `🚀 RELEASE:` 发版 / 版本号 / 发布流程
- `🤖 TEST:` 测试相关
- `‼️ BREAKING:` 破坏性变更

补充约束：

- 类型统一大写。
- 主题行优先控制在约 50 字以内。
- 主题行描述“做了什么”，不要写空泛结论。
- 若存在正文，正文用于说明动机、影响范围、约束和关联文档。

---

## 4. 暂存纪律

默认使用**有选择的暂存**，而不是直接把所有变更一次性加入。

要求：

- 优先按文件或按 hunk 暂存。
- 提交前再扫一遍 diff，移除 `console.log`、临时代码、注释掉的废弃逻辑。
- 不提交个人路径、测试脏数据、签名或敏感信息。
- 不为了省事直接提交无关格式化结果。

---

## 5. 执行边界

- 只有在用户明确要求“提交 / commit”时，才执行 `git add` / `git commit`。
- 默认**不 push**，除非用户明确要求。
- 默认**不 amend 已推送提交**，除非用户明确要求并确认影响。
- 如工作区混有多轮任务改动，应先确认本次提交范围，再拆分 commit。

---

## 6. DayPalette 推荐提交流程

推荐按下列顺序执行：

1. 阅读变更：`git status`、`git diff`、`git diff --cached`
2. 识别提交边界：文档、代码、修复、配置分别归类
3. 逐组暂存：确保每组改动能单独回滚
4. 编写中文 emoji 主题行
5. 提交后再次检查 `git status`
6. 未获明确要求时，不执行 `git push`

---

## 7. 与仓库其他文档的关系

- 仓库级 AI 行为约束见 [../../AGENTS.md](../../AGENTS.md)
- AI 开发总控规则见 [00-AI-DEVELOPMENT-HARNESS.md](./00-AI-DEVELOPMENT-HARNESS.md)
- 若存在工具私有规则，以 `.cursor/rules/git-commit-workflow.mdc` 的更完整版本为细则来源

本文目标不是替代工具规则，而是把提交约定公开化、仓库化，减少不同工具执行时的偏差。