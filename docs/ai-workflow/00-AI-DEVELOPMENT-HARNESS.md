# DayPalette · AI 开发 Harness（总册）

本文档是 **Vibe coding / Agent 驱动开发** 的单一入口：说明需求如何落盘、设计系统如何长期约束 AI、鸿蒙工程范式与目录结构，以及 **AGENTS.md**、**Cursor Rules**、**Skills** 三者的分工与用法。

> 自 2026-04-20 起，跨仓共享的业务流程、设计语言与仓库边界已开始收口到 [`../../../daypalette-docs/`](../../../daypalette-docs/README.md)。本仓 `docs/` 继续保留 HarmonyOS 客户端实现说明与必要补充；若遇到共享规则与本仓文档重复，优先更新 `daypalette-docs`，再回写本仓映射。

---

## 1. 三层协作模型

| 层级 | 载体 | 作用 |
|------|------|------|
| **Agent 宪章** | 仓库内 [`../../AGENTS.md`](../../AGENTS.md) | 任何会话先读的短约束：角色、文档优先级、需求确认后先改文档。 |
| **Harness（本文件）** | `docs/ai-workflow/00-AI-DEVELOPMENT-HARNESS.md` | 人类与 AI 的完整操作手册：落盘矩阵、目录结构、范式、与 Skills 映射。 |
| **强制规则** | ① **宿主仓库根** [`.cursor/rules/day-palette-harmonyos.mdc`](../../../.cursor/rules/day-palette-harmonyos.mdc)（工作区为整个仓库、本目录为其中子文件夹时；规则内 glob 需为 `day-palette/**/*.{ets,ts,json5,json}` 或按你实际文件夹名修改）② [本目录内 `.cursor/rules/…`](../../.cursor/rules/day-palette-harmonyos.mdc)（**工作区根就是本文件夹**时） | 编辑 ArkTS / `json5` 时按 glob 附加鸿蒙与项目约定。 |

**Cursor 工作区建议**

- **工作区根 = 宿主仓库根**（本文件夹是仓库里的子目录）：在宿主根目录放置 `.cursor/rules/day-palette-harmonyos.mdc`，glob 使用 `day-palette/**/*.{ets,ts,json5,json}`；若你复制后**重命名了文件夹**，请同步改 glob 与规则内文档路径描述。
- **工作区根 = 本文件夹**（单独打开文档+工程）：使用本目录内 `.cursor/rules/day-palette-harmonyos.mdc`（glob：`**/*.{ets,ts,json5,json}`）。

二者择一即可；以你实际打开的工作区为准。

---

## 2. 需求落盘矩阵（确认后写入哪里）

用户声明 **「需求已确认」** 后，Agent 应更新下表对应文档，再动代码。

| 变更类型 | 落盘文件 | 写什么 |
|----------|-----------|--------|
| 跨项目共享的业务流程、资产生命周期、仓库边界、共享设计语言 | [`../../../daypalette-docs/`](../../../daypalette-docs/README.md) 下对应文档 | 先更新共享规则层，再回写本仓实现映射。 |
| 功能范围、用户故事、验收标准、版本里程碑 | [`../product/PRD.md`](../product/PRD.md) | 新增/改章节；必要时在文内增加「变更记录」小节（日期 + 摘要）。 |
| 视觉令牌、组件形态、动效、间距圆角 | [`../design/design-system.md`](../design/design-system.md) | 改令牌表或组件节；文末注明与 HTML 原型是否已同步。 |
| 模块边界、Kit 选用、数据流 | [`../architecture/architecture.md`](../architecture/architecture.md) | 更新模块图或表格。 |
| 实体字段、JSON、存储策略 | [`../architecture/data-model.md`](../architecture/data-model.md) | 表结构、字段约束、迁移说明。 |
| 交互流程、设计方法论（非令牌） | 在 `docs/product/` 下新增或扩展独立 Markdown | 与 PRD 区分：PRD 写「做什么」，流程文档写「怎么协作/怎么评审」。 |
| 测试、上架、发布检查项 | [`../release/test-release-checklist.md`](../release/test-release-checklist.md) | 新增检查项或平台特例。 |
| HTML 像素级参考（可选） | [`../mockups/daypalette-premium-mockup.html`](../mockups/daypalette-premium-mockup.html) | 仅在需要 1:1 对照时改；改后应回写设计系统。 |

**原则**：**PRD + 设计系统** 是日常最高频真相源；HTML 为辅助，避免只改原型不落文档。

---

## 3. 设计系统治理（长期约束 AI）

- [`../../../daypalette-docs/design/shared-design-language.md`](../../../daypalette-docs/design/shared-design-language.md) 是 **跨端共享设计语言**；涉及品牌气质、语义色角色、排版角色、动效节奏时先改这里。  
- [`../design/design-system.md`](../design/design-system.md) 是 **HarmonyOS 客户端实现映射**；Agent 实现新页面时 **必须** 引用其中的 ArkUI 落地尺寸、组件形态与像素级补充。  
- **微调频率低**：每次调整设计系统，应在同一 PR/提交中说明「影响面」（哪些界面/组件）。  
- **与原型不一致**：以 HTML 校准像素 → 先判断属于共享设计语言还是 App 实现映射 → 更新对应文档 → 再写代码；禁止长期「代码与文档两套真理」。  
- 在 Prompt 中可固定附带：`@day-palette/docs/design/design-system.md`（路径随工作区根调整）。

---

## 4. 鸿蒙工程目录结构（DevEco 标准 + DayPalette 约定）

在 `day-palette/` 下创建或使用 DevEco 工程时，推荐如下结构（`entry` 为主模块名，可按实际模块名替换）：

```text
day-palette/
├── AGENTS.md                          # Agent 宪章
├── AppScope/
│   └── app.json5
├── entry/
│   ├── oh-package.json5
│   └── src/main/
│       ├── ets/
│       │   ├── entryability/
│       │   │   └── EntryAbility.ets   # 生命周期、窗口、Want
│       │   ├── pages/
│       │   │   └── Index.ets          # @Entry 路由页，宜薄：组装子组件
│       │   ├── components/            # 可复用 UI（TopBar、Hero、…）
│       │   ├── viewmodel/               # 页面/领域 ViewModel，@Observed 等
│       │   ├── model/                   # 纯数据类型、枚举、常量接口
│       │   ├── store/                   # 可选：全局 TodayOutfitStore 单例
│       │   ├── common/
│       │   │   ├── constants/           # 颜色令牌映射、魔法数字收口
│       │   │   └── utils/               # 纯函数工具
│       │   └── workers/                 # 可选：重任务
│       ├── resources/
│       │   ├── base/
│       │   │   ├── element/             # string.json、color.json（宜对齐设计令牌）
│       │   │   ├── media/
│       │   │   └── profile/
│       │   └── rawfile/                 # palettes.json 等
│       └── module.json5
├── docs/                                # 本文档树（已实现）
└── …
```

**命名约定（ArkTS）**

| 类型 | 约定 |
|------|------|
| 页面 | `XxxPage.ets`，`@Entry @Component` |
| 可复用组件 | `XxxView.ets` 或 `XxxComponent.ets`，`@Component` |
| ViewModel | `XxxViewModel.ets`，业务状态与方法 |
| Model | `Xxx.ets` 或 `types.ets`，interface / class / enum |
| 资源 | `resources` 下小写+下划线；与 `design-system` 中名称可建立注释映射 |

**ArkUI 范式要点**

- **声明式 UI**：`build()` 内组合组件；复杂逻辑抽到 ViewModel 或 `@Builder`。  
- **状态**：组件内 `@State`；跨层 `@Prop` / `@Link` / `@Provide` / `@Consume`；全局可用 `AppStorage` 或单例 Store（与 `architecture.md` 一致）。  
- **异步**：网络/IO 不阻塞 UI；错误态需在 UI 可感知（与设计系统语义色一致）。  
- **性能**：长列表用 `LazyForEach`；避免在 `build()` 里做重计算。  
- **安全区**：全屏与顶底栏使用官方 `expandSafeArea` / 边距策略，见 [`03-PROMPT-GUIDE-HARMONYOS.md`](03-PROMPT-GUIDE-HARMONYOS.md) 备用 Prompt。

**官方文档**：实现细节以当前 **HarmonyOS / API 版本** 对应开发者文档为准；Agent 不得臆造已废弃 API。

---

## 5. 与现有 AI 文档的关系

| 文件 | 用途 |
|------|------|
| [`01-AI-CONTEXT-AND-RULES.md`](01-AI-CONTEXT-AND-RULES.md) | 产品无关平台的上下文与组件拆分清单。 |
| [`02-PHASED-IMPLEMENTATION-PLAN.md`](02-PHASED-IMPLEMENTATION-PLAN.md) | 分阶段步骤与检查点。 |
| [`03-PROMPT-GUIDE-HARMONYOS.md`](03-PROMPT-GUIDE-HARMONYOS.md) | 可复制 Prompt 片段。 |
| [`how-to-prompt-ai-for-native-app.md`](how-to-prompt-ai-for-native-app.md) | HTML → 原生的一般方法论。 |

**推荐开场 Prompt 附件**（按需选）：

`@day-palette/AGENTS.md`  
`@day-palette/docs/ai-workflow/00-AI-DEVELOPMENT-HARNESS.md`  
`@daypalette-docs/design/shared-design-language.md`  
`@day-palette/docs/design/design-system.md`  
`@day-palette/docs/product/PRD.md`

---

## 6. Skills 映射（可选 User Skill）

Cursor **Skill** 适合固化「可重复的多步流程」。

### 已提供的可复制 Skill

将目录 **[`skills/daypalette-dev/`](skills/daypalette-dev/)** 整体复制到 `~/.cursor/skills/daypalette-dev/`，即可在对话中通过技能描述触发「先文档后代码 + 设计系统优先」行为。（若你的 Cursor 版本支持项目内 `.cursor/skills/`，也可将该目录迁往工作区约定位置。）

### 建议拆分的其他主题

| Skill 主题 | 触发场景 | 核心动作 |
|------------|----------|----------|
| **daypalette-requirements-landing** | 用户说需求已定稿 | 按 §2 矩阵改 PRD/架构/数据模型；再列代码任务。 |
| **daypalette-design-token-update** | 只改视觉规范 | 只改 `design-system.md`；检查 `resources/base/element` 与常量目录是否同步。 |
| **daypalette-harmonyos-feature** | 实现新功能 | 读 PRD + design-system + architecture；文件放入 §4 约定目录；补测试检查项。 |

无 Skill 时 **AGENTS.md + Cursor Rules + 本文件** 已足够约束 Agent。

---

## 7. 人类开发者最小流程（Vibe coding）

1. 打开 DevEco + Cursor，工作区含 `day-palette`。  
2. 新会话：附加 `AGENTS.md` + `00-AI-DEVELOPMENT-HARNESS.md` + `design-system.md` + `PRD.md`。  
3. 口述需求 → 让 AI **先更新文档** → 再生成/修改 `entry/src/main/ets` 与资源。  
4. 在 Previewer/模拟器验收；问题用 `03-PROMPT-GUIDE-HARMONYOS.md` 纠错 Prompt。  
5. 发布前扫 [`../release/test-release-checklist.md`](../release/test-release-checklist.md)。

---

## 8. 修订记录

| 日期 | 摘要 |
|------|------|
| 2026-04-01 | 初版：Agent 宪章、落盘矩阵、鸿蒙目录与 Skills 映射。 |
