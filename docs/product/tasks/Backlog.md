# Backlog · 产品待办池

**规则**：新想法、缺陷、PRD 缺口统一记在此文件；排入某迭代时，在对应 `iteration-NN.md` 中建立 Issue 并在此条标注 **→ iteration-NN**，或移动章节（任选一种习惯，保持可查即可）。

**状态说明**：下列默认 **Backlog**；未写 Priority 的可视为 **P2**。

---

## 1. PRD / 商业化缺口（MVP 未完成项）

| Key | Type | Priority | Summary | Source | Acceptance（摘要） |
|-----|------|----------|---------|--------|-------------------|
| BL-PRD-01 | Epic | P0 | **IAP Pro 一次性解锁** | PRD F-08 | 接 AppGallery Connect；SKU 与文案一致 |
| BL-PRD-02 | Story | P0 | **未购 Pro：高级套组/付费皮肤不可选或锁 + 引导** | PRD §7 验收 | 与数据模型 `isPro`/资源标记一致 |
| BL-PRD-03 | Story | P0 | **已购 Pro：皮肤 + 高级套组立即可用；杀进程权益保持** | PRD §7 验收 | 持久化购买状态 |
| BL-PRD-04 | Story | P0 | **恢复购买** | PRD F-07 / §7 | 设置内可用、失败提示合理 |
| BL-PRD-05 | Task | P1 | **Debug：强制免费 / 强制 Pro** | PRD §2.3 | 仅 Debug 包；见 `docs/release/test-release-checklist.md` |
| BL-PRD-06 | Story | P2 | **Intents：「打开今日配色」直达今日页** | PRD §2.3 | 权限与失败降级另文 |

---

## 2. 头脑风暴落地（[`../brainstorming/Brainstorming-01.md`](../brainstorming/Brainstorming-01.md)）

已拍板方向见 Brainstorming「已拍板方向」；任务 ID 与原文 **T-xx** 一致。

| Key | Type | Priority | Summary | Source | Acceptance（摘要） | 排期 |
|-----|------|----------|---------|--------|-------------------|------|
| BL-BR-01 | Task | P1 | **提升「随机、精调、昨日」入口视觉权重** | Brainstorming T-01 | 保存/分享不动；更易发现与点击；对齐设计系统 | → [**iteration-02**](./iteration-02.md) · **Done** |
| BL-BR-02 | Task | P1 | **「随机」文案改为「随机选」等** | Brainstorming T-02 | 中英文案与真实行为一致；`LocaleData` 等 | → [**iteration-02**](./iteration-02.md) · **Done** |
| BL-BR-03 | Story | P2 | **精调：「智能配」主路径 + 可展开完整微调** | Brainstorming T-03 | 主色驱动补全 + 保留现有精调；无脏色 | Backlog（2026-04-07 回退：当前搭配质量与 UI 交互未达标，用户侧入口已屏蔽） |
| BL-BR-04 | Task | P2 | **出图/分享色卡版式升级** | Brainstorming T-04 | 免费模板边界遵守 PRD | → [**iteration-02**](./iteration-02.md) · **Done** |
| BL-BR-05 | Task | P2 | **Hero 区三色呈现优化** | Brainstorming T-05 | 比例/圆角/动效遵守「减少动效」 | → [**iteration-02**](./iteration-02.md) · **Done** |
| BL-BR-06 | Task | P2 | **顶栏微缩预览优化** | Brainstorming T-06 | 与主界面配色语言一致、可读 | → [**iteration-02**](./iteration-02.md) · **Done** |
| BL-BR-07 | Epic | P2 | **预置套组与场合扩容（目标百套+分期）** | Brainstorming T-07 | 首批专题方向、`Collection` 结构映射、内容扩容节奏与 Pro 包边界明确 |
| BL-BR-08 | Task | P3 | **运营侧内容管理方案调研与选型** | Brainstorming T-08 | 纪要 + 与架构对齐 | → [**iteration-05**](./iteration-05.md) |
| BL-BR-09 | Epic | P3 | **壁纸周边（非渐变/渐变/高级渐变 IAP）** | Brainstorming T-09 | 与 PRD 商业边界复核后立项 |
| BL-BR-10 | Story | P2 | **配色数据更新机制设计（内置 / 远端覆盖 / CMS）** | Brainstorming-02 / Architecture | 明确方案选型、缓存、回滚、离线降级、版本兼容与发布边界 | → [**iteration-05**](./iteration-05.md) |
| BL-BR-11 | Task | P2 | **场景命名与“今天的故事”文案收敛** | Brainstorming-02 | 收敛“随便走走的一天”等场景标题与情绪语义，不新增前置决策层 | → [**iteration-05**](./iteration-05.md) |
| BL-UX-01 | Task | P1 | **精调能力升级与交互方案设计** | 口头 / 当前体验盘点 | 明确用户可改颜色范围、交互形式、确认/回退逻辑与更友好的操作路径 | → [**iteration-05**](./iteration-05.md) |

### 2.1 Brainstorming-02 / 策略文档增补备注

- `BL-BR-03` 当前继续细化为三组实现任务：  
	- 数据：主色候选池分层、场景标签与安全等级字段、`LocaleData.ets -> JSON / catalog` 读取过渡。  
	- 规则：第一版硬规则、软规则、排序与兜底，以及围绕现有 app 场景的解释模板与口径收敛。  
	- UI：智能配主路径入口、结果卡片解释层、可展开完整微调、异常与空状态提示。  
- `BL-BR-03` 已于 2026-04-07 暂停对外投放：保留已完成的数据与规则底座，但当前搭配质量与 UI 交互未达到上线标准，首页“扩展搭配”入口已先行屏蔽，后续继续留在 Backlog 评估恢复时机。  
- `BL-BR-07` 当前建议继续细化为：配色资产三层模型定义（Base Color / Palette / Collection）、命名与标签规范、基础单色高复用池整理、首批专题策展落地。首批专题方向明确收敛为 `Citywalk 拍照 / 公园出片 / 国风新中式`，不再归入 `BL-BR-03` 的场景策略范围。  
- `BL-BR-08` 当前建议继续细化为：配色资产低成本维护流程设计、审核口径与重复性检查规则、CMS / 数据管理工具轻量选型。  
- 以上增补来源见 [`../brainstorming/Brainstorming-02.md`](../brainstorming/Brainstorming-02.md)、[`../strategy/color-asset-library-plan.md`](../strategy/color-asset-library-plan.md)、[`../strategy/conservative-smart-matching-strategy.md`](../strategy/conservative-smart-matching-strategy.md)。

### 2.2 BL-BR-03 实现切片备忘

| 子项 | 分类 | 目标 | 交付摘要 |
|-----|------|------|---------|
| BL-BR-03A | Data | 建立智能配输入数据骨架 | 补齐主色候选池结构、色彩安全等级、场景与专题标签字段 |
| BL-BR-03B | Data | 建立数据加载过渡层 | 设计 `LocaleData.ets` 到 `rawfile/palette-data/*.json` / `catalog` 的兼容读取路径 |
| BL-BR-03C | Rules | 实现第一版硬规则 | 明确禁配、低饱和保护、亮度跨度、场景黑白名单与兜底策略 |
| BL-BR-03D | Rules | 实现第一版软规则与排序 | 定义 tone 权重、场景偏好、主题加分、结果排序与去重 |
| BL-BR-03E | Rules | 建立场景策略模板 | 围绕现有 app 场景建立策略配置与解释模板，不承接专题策展方向 |
| BL-BR-03F | UI | 接入智能配主路径 | 在精调主流程中提供“选主色 -> 智能补全”的低负担入口 |
| BL-BR-03G | UI | 设计结果解释层 | 为推荐结果提供短解释、原因标签、失败兜底与空状态提示 |
| BL-BR-03H | UI | 保留完整微调能力 | 智能配结果可继续手动微调，且不打断现有精调链路 |

### 2.3 BL-BR-07 首批专题方向备忘

| 子项 | 分类 | 目标 | 交付摘要 |
|-----|------|------|---------|
| BL-BR-07A | Collection | 首批专题策展落地 | 完成 `Citywalk 拍照 / 公园出片 / 国风新中式` 三个专题的基调、封面、palette 清单与说明文案 |
| BL-BR-07B | Asset | 专题与 palette 关联规则 | 明确专题标签、排序、封面与复用边界，确保可映射到 `Collection` 数据结构 |

建议验收：

- 三个首批专题都具备可落库的 `Collection` 定义，而不是只停留在命名或方向描述。
- 每个专题都至少明确：`nameZh/nameEn`、`themeType`、`descriptionZh`、`paletteIds`、`coverPaletteId`、`isPro`、`releaseMode`、`status`。
- 每个专题都要补齐用于检索与复用的 `occasionTags/styleTags`，并与对应 `Palette` 的标签体系保持一致。
- 允许一个 `Palette` 复用到多个专题，但同一发布周期内要控制重复曝光，避免三个专题看起来只是换标题。

建议的 `Collection` 映射：

| 专题方向 | 建议 `themeType` | 关键标签方向 | 最低落库要求 |
|-----|------|------|---------|
| `Citywalk 拍照` | `scene` | `occasionTags` 以城市漫游 / 轻拍照语义为主，`styleTags` 偏都市、清爽 | 至少有 1 个封面 palette 和 1 组可发布 `paletteIds` |
| `公园出片` | `scene` | `occasionTags` 以户外 / 公园语义为主，`styleTags` 偏自然、轻盈 | 至少有 1 个封面 palette 和 1 组可发布 `paletteIds` |
| `国风新中式` | `style` | `styleTags` 以东方、克制、新中式语义为主，必要时再补 `occasionTags` | 至少有 1 个封面 palette 和 1 组可发布 `paletteIds` |

字段参考：

- `Collection` 字段草表见 [`../strategy/color-asset-library-plan.md`](../strategy/color-asset-library-plan.md) §10.3。
- 三层资产与 `CollectionItem` 结构示意见 [`../../architecture/data-model.md`](../../architecture/data-model.md) §4。

---

## 3. PRD 未来规划（未立项）

| Key | Type | Priority | Summary | Source |
|-----|------|----------|---------|--------|
| BL-FUT-01 | Epic | P3 | **天气与配色推荐** | PRD §9 |
| BL-FUT-02 | Story | P3 | **顶栏：日期 + 天气摘要（有数据源后）** | PRD §9 |
| BL-FUT-03 | Task | P3 | **定位/天气权限与合规、降级策略** | PRD §9 |

---

## 4. 自由输入（模板）

在此追加行即可：

| Key | Type | Priority | Summary | Source | Notes |
|-----|------|----------|---------|--------|-------|
| BL-BUG-01 | Task | P1 | TopBar 日期与系统日期不同步修复 | 口头 | 保证顶栏日期与系统日期、时区、前后台切换和跨天刷新一致 | → [**iteration-05**](./iteration-05.md) |
| BL-XXX-1 | Task | P1 | 随机选交互优化 | 口头 | 目前的随机选，当配色盘很多的时候，看不到随机选中的配色盘 |

---

## 5. 工程治理 / 文档回流

| Key | Type | Priority | Summary | Source | Acceptance（摘要） | 排期 |
|-----|------|----------|---------|--------|-------------------|------|
| BL-ENG-01 | Task | P1 | **纯代码层面自检与冗余清理** | 当前实现盘点 | 检查未使用代码、重复实现、可合并常量/逻辑；输出处理清单并完成低风险收敛 | → [**iteration-03**](./iteration-03.md) · **Done** |
| BL-ENG-02 | Task | P1 | **渲染与状态链路的性能风险排查** | 当前实现盘点 | 检查 `build()` 内重复计算、滚动区/顶栏/导出链路的潜在热点；给出结论与必要修正 | → [**iteration-03**](./iteration-03.md) · **Done** |
| BL-DOC-01 | Task | P1 | **架构文档按实现回流校准** | 当前实现盘点 | 以 `entry/src/main/ets/` 实际模块划分为准，修正文档中的状态、渲染、持久化边界描述 | → [**iteration-03**](./iteration-03.md) · **Done** |
| BL-DOC-02 | Task | P1 | **设计系统按实现回流校准** | 当前实现盘点 | 把已落地的 Hero、微缩预览、按钮、配色盘卡片等关键实现同步回设计文档 | → [**iteration-03**](./iteration-03.md) · **Done** |
| BL-DOC-03 | Task | P1 | **产品文档按实现回流校准** | 当前实现盘点 | 校准 PRD / 任务文档与真实行为，特别是昨日、微缩预览、导出模板与当前交互规则 | → [**iteration-03**](./iteration-03.md) · **Done** |

---

## 6. 发布准备 / 多设备适配 / 品牌视觉

| Key | Type | Priority | Summary | Source | Acceptance（摘要） | 排期 |
|-----|------|----------|---------|--------|-------------------|------|
| BL-REL-01 | Task | P0 | **HarmonyOS 上架规范自检与整改** | 提审前准备 | 基于官方规范与项目发布清单完成自检；阻塞项整改闭环；输出可复查问题清单 | → [**iteration-04**](./iteration-04.md) |
| BL-ADAPT-01 | Task | P0 | **手机 / 平板多尺寸自适应收敛** | 当前目标设备 | 在手机与平板主要尺寸上保证今日页、设置面板、动作区与 Hero 的稳定布局与视觉节奏 | Backlog |
| BL-ADAPT-02 | Story | P1 | **大尺寸宽屏布局方案设计与落地** | 当前目标设备 | 为宽屏平板提供独立布局策略，不再直接横向拉伸手机版纵向结构 | Backlog |
| BL-BRAND-01 | Task | P1 | **应用图标设计与资源接入** | 产品视觉升级 | 输出符合产品气质的图标方案、资源规格与接入结果 | Backlog |
| BL-BRAND-02 | Task | P1 | **应用名称重新确定与文案对齐** | 产品视觉升级 | 明确最终中英文名称与命名规范，并同步应用内、文档与商店素材触点 | Backlog |
| BL-REL-02 | Task | P1 | **上线前最终自检与提审素材收口** | 提审前准备 | 在主要功能开发完成后，集中完成截图、隐私政策外链、最终素材、商店文案与提审前校验闭环 | Backlog |

---

## 建议捞取顺序（非强制）

1. **BL-BR-03**（精调主路径升级，可作为恢复功能开发后的优先项）  
2. **iteration-05：BL-BR-08 / 10 / 11**（先把数据更新机制、内容维护流程和场景文案收敛清楚，再进入更大规模内容扩展）  
3. **BL-ADAPT-01 / 02、BL-BRAND-01 / 02**（待主要功能开发告一段落后，再集中处理设备适配与品牌收敛）  
4. **BL-REL-02**（接近提审前，集中完成最终自检与素材收口）  
5. **BL-PRD-01～04**（商业化闭环；依赖链路长，待当前发布准备与基础体验收敛后再集中推进）  
6. ~~**BL-BR-01、BL-BR-02**~~ → 已纳入 [**iteration-02**](./iteration-02.md)  
7. ~~**iteration-03：BL-ENG-01 / 02、BL-DOC-01 / 02 / 03**~~ → 已纳入 [**iteration-03**](./iteration-03.md) · **Done**  
8. ~~**BL-BR-04～06**~~ → 已纳入 [**iteration-02**](./iteration-02.md)  
9. `BL-BR-07` 当前暂不进入迭代，待内容扩展依据与生产节奏更清晰后再启动  
10. 其余按资源与版本节奏从本节与 §3 挑选  
