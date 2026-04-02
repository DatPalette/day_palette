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

## 2. 头脑风暴落地（[`../Brainstorming.md`](../Brainstorming.md)）

已拍板方向见 Brainstorming「已拍板方向」；任务 ID 与原文 **T-xx** 一致。

| Key | Type | Priority | Summary | Source | Acceptance（摘要） | 排期 |
|-----|------|----------|---------|--------|-------------------|------|
| BL-BR-01 | Task | P1 | **提升「随机、精调、昨日」入口视觉权重** | Brainstorming T-01 | 保存/分享不动；更易发现与点击；对齐设计系统 | → [**iteration-02**](./iteration-02.md) |
| BL-BR-02 | Task | P1 | **「随机」文案改为「随机选」等** | Brainstorming T-02 | 中英文案与真实行为一致；`LocaleData` 等 | → [**iteration-02**](./iteration-02.md) |
| BL-BR-03 | Story | P2 | **精调：「智能配」主路径 + 可展开完整微调** | Brainstorming T-03 | 主色驱动补全 + 保留现有精调；无脏色 | Backlog |
| BL-BR-04 | Task | P2 | **出图/分享色卡版式升级** | Brainstorming T-04 | 免费模板边界遵守 PRD | → [**iteration-02**](./iteration-02.md) |
| BL-BR-05 | Task | P2 | **Hero 区三色呈现优化** | Brainstorming T-05 | 比例/圆角/动效遵守「减少动效」 | → [**iteration-02**](./iteration-02.md) |
| BL-BR-06 | Task | P2 | **顶栏微缩预览优化** | Brainstorming T-06 | 与主界面配色语言一致、可读 | → [**iteration-02**](./iteration-02.md) |
| BL-BR-07 | Epic | P2 | **预置套组与场合扩容（目标百套+分期）** | Brainstorming T-07 | 内容生产节奏与 Pro 包边界 |
| BL-BR-08 | Task | P3 | **运营侧内容管理方案调研与选型** | Brainstorming T-08 | 纪要 + 与架构对齐 |
| BL-BR-09 | Epic | P3 | **壁纸周边（非渐变/渐变/高级渐变 IAP）** | Brainstorming T-09 | 与 PRD 商业边界复核后立项 |

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
| BL-XXX- | Task | P? | （标题） | 口头/工单 | |

---

## 建议捞取顺序（非强制）

1. **BL-PRD-01～04**（商业化闭环，与 PRD MVP 验收一致）  
2. ~~**BL-BR-01、BL-BR-02**~~ → 已纳入 [**iteration-02**](./iteration-02.md)  
3. **BL-BR-03**（独立迭代，单独 `iteration-03` 亦可）  
4. ~~**BL-BR-04～06**~~ → 已纳入 [**iteration-02**](./iteration-02.md)  
5. 其余按资源与版本节奏从本节与 §3 挑选  
