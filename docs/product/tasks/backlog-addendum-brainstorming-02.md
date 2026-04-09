# Backlog 增补清单草案 · Brainstorming-02 / 策略文档后续

## 1. 文档目的

这份文档用于把以下来源中的新增方向，整理成可直接落入 `Backlog.md` 的正式增补清单：

- `docs/product/brainstorming/Brainstorming-02.md`
- `docs/product/strategy/color-asset-library-plan.md`
- `docs/product/strategy/conservative-smart-matching-strategy.md`

原则：

- 优先复用现有 `BL-BR-03 / 07 / 08`，避免重复开 Epic。  
- 只有在现有 Key 无法承接时，才新增 `BL-BR-10 / 11`。  
- 表述风格尽量与现有 `Backlog.md` 保持一致。

---

## 2. 建议并入现有 Key 的条目

### 2.1 并入 `BL-BR-07`：预置套组与场合扩容（目标百套+分期）

建议把 `BL-BR-07` 从“内容扩容”细化为“内容扩容 + 资产结构化”。

可直接补充的子任务：

| 建议归属 | Type | Priority | Summary | Source | Acceptance（摘要） |
|-----|------|----------|---------|--------|-------------------|
| BL-BR-07 | Story | P2 | **配色资产三层模型定义（Base Color / Palette / Collection）** | Strategy / Asset Library | 字段、状态、关联关系明确；可映射到 JSON |
| BL-BR-07 | Task | P2 | **配色资产命名与标签规范 v1** | Strategy / Asset Library | 基础单色命名、配色盘命名、标签分类与新增约束成文 |
| BL-BR-07 | Story | P2 | **首批专题策展落地：Citywalk / 公园 / 新中式** | Brainstorming-02 §8 | 完成三个专题的基调、辅色范围、点缀边界和首批 palette 清单 |
| BL-BR-07 | Task | P2 | **基础单色高复用池整理** | Strategy / Asset Library | 识别高复用中性色与安全色，形成可复用底库 |

### 2.2 并入 `BL-BR-03`：精调：「智能配」主路径 + 可展开完整微调

建议把 `BL-BR-03` 从抽象方向，继续细化成可执行项。

可直接补充的子任务：

| 建议归属 | Type | Priority | Summary | Source | Acceptance（摘要） |
|-----|------|----------|---------|--------|-------------------|
| BL-BR-03 | Story | P2 | **智能配候选池建设（core safe / occasion safe / accent expressive）** | Strategy / Smart Matching | 建立三层候选池；来源于已审核色彩资产 |
| BL-BR-03 | Story | P2 | **智能配第一版规则引擎** | Strategy / Smart Matching | 明确硬规则、软规则、排序流程与禁用组合列表 |
| BL-BR-03 | Task | P2 | **按现有场景的智能配策略 v1** | Brainstorming-02 / Smart Matching | 围绕当前 app 既有场景补齐规则与解释模板，不承接专题策展方向 |
| BL-BR-03 | Task | P2 | **智能配结果解释层文案模板** | Strategy / Smart Matching | 每套结果有简短可解释说明，增强用户信任 |

### 2.3 并入 `BL-BR-08`：运营侧内容管理方案调研与选型

建议把 `BL-BR-08` 从泛泛调研，细化成“低成本维护流程 + 工具选型”。

可直接补充的子任务：

| 建议归属 | Type | Priority | Summary | Source | Acceptance（摘要） |
|-----|------|----------|---------|--------|-------------------|
| BL-BR-08 | Task | P2 | **配色资产低成本维护流程设计** | Strategy / Asset Library | 明确编辑态、发布态、审核流与上新节奏 |
| BL-BR-08 | Task | P3 | **CMS / 数据管理工具轻量选型** | Strategy / Asset Library | 对比 JSON、表格型工具、自托管 CMS 的适用阶段和成本 |
| BL-BR-08 | Task | P2 | **配色资产审核口径与重复性检查规则** | Strategy / Asset Library | 形成可执行审核清单，避免命名漂移与资产重复 |

---

## 3. 建议新增的 Key

以下方向不完全适合继续塞进现有 `BL-BR-03 / 07 / 08`，建议新增 Key 单独承接。

### 3.1 建议新增 `BL-BR-10`

| Key | Type | Priority | Summary | Source | Acceptance（摘要） |
|-----|------|----------|---------|--------|-------------------|
| BL-BR-10 | Story | P2 | **配色数据更新机制设计（内置 / 远端覆盖 / CMS）** | Brainstorming-02 / Architecture | 明确方案选型、缓存、回滚、离线降级、版本兼容与发布边界 |

建议说明：

- 当前如果配色数据完全内置，后续调整 palette 通常需要重新发版。  
- 该任务用于明确是否引入“内置基础库 + 远端 JSON 覆盖”的中间方案。

### 3.2 建议新增 `BL-BR-11`

| Key | Type | Priority | Summary | Source | Acceptance（摘要） |
|-----|------|----------|---------|--------|-------------------|
| BL-BR-11 | Task | P2 | **灵感入口与场景文案收敛** | Brainstorming-02 | 收敛“今天没安排”场景的承接方式、入口形态与“今天的故事”文案口径；不新增更重的前置决策层 |

建议说明：

- 该任务用于承接 Brainstorming-02 中关于“有安排 / 随便走走”不拆双入口、继续通过现有主路径承接灵感态的结论。  
- 重点不是新增更重的信息架构，而是明确灵感入口形态，并同步优化场景文案与情绪表达。

---

## 4. 可直接粘贴进 Backlog 的增补片段

以下片段可在 `Backlog.md` 中 `BL-BR-03 / 07 / 08` 下方或自由输入区附近整理吸收。

```markdown
| BL-BR-10 | Story | P2 | **配色数据更新机制设计（内置 / 远端覆盖 / CMS）** | Brainstorming-02 / Architecture | 明确方案选型、缓存、回滚、离线降级、版本兼容与发布边界 |
| BL-BR-11 | Task | P2 | **灵感入口与场景文案收敛** | Brainstorming-02 | 收敛“今天没安排”场景的承接方式、入口形态与“今天的故事”文案口径；不新增更重的前置决策层 |
```

若希望把子任务也记录进 `Backlog.md`，建议采用“Notes / 子项备忘”的形式，而不是一次性把表格膨胀过大。

---

## 5. 推荐落文档顺序

建议按以下顺序吸收到正式 `Backlog.md`：

1. 先新增 `BL-BR-10 / 11` 两个独立 Key。  
2. 再为 `BL-BR-03 / 07 / 08` 补 Notes 或在对应迭代文档中展开子任务。  
3. 等进入实际排期时，再把上面子任务逐项拖到 `iteration-NN.md`。

---

## 6. 暂定结论

这轮策略文档落地后，Backlog 层最值得补的不是更多抽象想法，而是：

- 配色资产结构化  
- 智能配第一版规则化  
- 内容维护低成本化  
- 配色数据更新机制单独立项  
- 灵感入口与场景文案收敛

这五类任务已经足够支持后续迭代拆解。