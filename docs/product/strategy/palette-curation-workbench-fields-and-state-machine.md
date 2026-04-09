# 配色策展工作台运营字段与状态机文档

## 1. 文档定位

本文用于定义配色策展工作台中，配色盘在“策展、筛选、审核、入选、发布准备”流程下所需的运营字段与状态流转规则。

本文重点回答：

1. 每个配色盘在策展阶段需要记录哪些额外信息。  
2. 哪些字段属于基础元数据，哪些字段属于运营判断信息。  
3. 配色盘从候选到入选，应如何流转。  
4. 哪些状态可以互相切换，哪些不应允许直接跳转。

---

## 2. 一句话结论

如果要高效管理几十到上百个候选配色盘，必须把“人工审美判断”结构化为一组清晰的运营字段，并通过状态机把筛选过程显式记录下来。

否则后续会出现三个问题：

1. 为什么某个配色盘被淘汰，无法追溯。  
2. 不同场景下的判断标准混乱。  
3. 最终发布候选缺乏稳定边界。

---

## 3. 字段分层原则

建议把配色盘字段分成四层。

## 3.1 基础资产字段

这类字段描述“它是什么”。

例如：

- `id`  
- `slug`  
- `nameZh`  
- `nameEn`  
- `primaryColorId`  
- `secondaryColorId`  
- `accentColorId`

## 3.2 内容语义字段

这类字段描述“它适合什么”。

例如：

- `primaryScene`  
- `sceneTags`  
- `styleTags`  
- `moodTags`  
- `seasonTags`  
- `safetyLevel`

## 3.3 策展运营字段

这类字段描述“它目前被如何看待”。

例如：

- `reviewStatus`  
- `curationScore`  
- `isSelected`  
- `reviewNotes`  
- `rejectionReason`  
- `lastReviewedAt`

## 3.4 发布辅助字段

这类字段描述“它是否已进入发布准备”。

例如：

- `readyForBundle`  
- `publishCandidateVersion`  
- `validationFlags`  
- `previewVariant`

---

## 4. 必备运营字段定义

## 4.1 `primaryScene`

类型：`string`

作用：

- 表示该配色盘主要服务的场景。  
- 用于场景视图和首层筛选。  

建议枚举首版控制在有限集合，例如：

- `commute`  
- `citywalk`  
- `dating`  
- `park`  
- `weekend`  
- `photo`

## 4.2 `sceneTags`

类型：`string[]`

作用：

- 用于一盘多场景覆盖。  
- 用于次级筛选和推荐。  

## 4.3 `styleTags`

类型：`string[]`

作用：

- 用于风格维度归类。  
- 帮助同风格候选集中比较。

## 4.4 `moodTags`

类型：`string[]`

作用：

- 用于表达情绪倾向。  
- 帮助做视觉语义上的聚类。

## 4.5 `safetyLevel`

类型：`enum`

建议值：

- `safe`  
- `expressive`  
- `experimental`

作用：

- 区分稳定推荐候选与实验性候选。  
- 控制不同场景下的候选池边界。

## 4.6 `reviewStatus`

类型：`enum`

建议值：

- `candidate`  
- `shortlisted`  
- `approved`  
- `rejected`  
- `archived`

作用：

- 描述当前策展生命周期。  
- 是整个工作台里最核心的运营状态字段。

## 4.7 `curationScore`

类型：`number`

建议范围：`1-5`

作用：

- 记录人工主观评分。  
- 用于初筛排序，不作为唯一决策依据。

## 4.8 `isSelected`

类型：`boolean`

作用：

- 用于表示是否进入某个场景的最终入选集。  
- 它不是 `reviewStatus` 的替代，而是一个更明确的“进入最终集合”标记。

## 4.9 `reviewNotes`

类型：`string`

作用：

- 记录人工判断结论。  
- 支持在后续复盘中理解保留理由。

## 4.10 `rejectionReason`

类型：`string | null`

作用：

- 记录淘汰理由。  
- 减少重复比较与重复误判。

推荐使用有限枚举加可选补充文本，例如：

- `too-dark`  
- `too-flat`  
- `low-contrast`  
- `too-similar`  
- `scene-mismatch`  
- `brand-mismatch`

## 4.11 `previewVariant`

类型：`enum`

建议值：

- `today-hero`  
- `list-card`  
- `detail-atmosphere`

作用：

- 指示默认预览模板。  
- 帮助提高预览效率。

---

## 5. 推荐扩展字段

这些字段不是首版绝对必需，但建议预留。

## 5.1 `visualWeight`

建议值：`light / balanced / heavy`

## 5.2 `contrastRisk`

建议值：`low / medium / high`

## 5.3 `noveltyLevel`

建议值：`common / distinct / standout`

## 5.4 `similarToPaletteIds`

类型：`string[]`

作用：

- 标记与哪些候选相近。  
- 便于快速进入对比流程。

## 5.5 `heroCopyHint`

类型：`string`

作用：

- 记录适合搭配的文案方向。  
- 为未来详情预览服务。

---

## 6. 状态机设计原则

策展状态机不应过于复杂，但必须满足以下目标：

1. 能表达初筛、中筛、最终入选、淘汰、归档。  
2. 能支持误操作恢复。  
3. 能区分“还没看过”和“看过但没入选”。  
4. 能支持后续发布前检查。

---

## 7. 推荐状态机

## 7.1 状态定义

### `candidate`

含义：

- 新进入候选池。  
- 尚未完成明确判断。  

### `shortlisted`

含义：

- 经过初筛后保留下来。  
- 值得进一步比较。  

### `approved`

含义：

- 已通过当前轮策展判断。  
- 可进入入选集或发布候选集。  

### `rejected`

含义：

- 已明确淘汰。  
- 但仍保留记录以供追溯。  

### `archived`

含义：

- 已不再参与当前运营周期。  
- 通常用于历史淘汰项或过时资产。

## 7.2 状态图

```text
candidate -> shortlisted -> approved
candidate -> rejected
shortlisted -> rejected
approved -> shortlisted
rejected -> shortlisted
rejected -> archived
approved -> archived
```

---

## 8. 状态流转规则

## 8.1 `candidate -> shortlisted`

触发条件：

- 初筛后认为值得进一步看。  
- 或者人工评分达到保留阈值。  

需要记录：

- `lastReviewedAt`  
- 可选 `curationScore`  
- 可选 `reviewNotes`

## 8.2 `candidate -> rejected`

触发条件：

- 初筛直接淘汰。  

需要记录：

- `rejectionReason` 必填。  
- `lastReviewedAt` 必填。

## 8.3 `shortlisted -> approved`

触发条件：

- 已完成精筛或对比。  
- 确认进入当前场景的可用候选集。  

需要记录：

- `curationScore`  
- `reviewNotes`  
- `isSelected` 可同步更新为 `true`

## 8.4 `shortlisted -> rejected`

触发条件：

- 经过对比后被淘汰。  

需要记录：

- `rejectionReason` 必填。  
- 建议写入对比结论摘要。

## 8.5 `approved -> shortlisted`

触发条件：

- 后续新增更优候选。  
- 需要重新比较。  

作用：

- 支持“从入选回退到待比较”，避免只能单向推进。

## 8.6 `rejected -> shortlisted`

触发条件：

- 人工复核后决定恢复。  
- 或因场景变化，原本淘汰项重新变得合适。  

作用：

- 防止误淘汰成为不可逆动作。

## 8.7 `approved / rejected -> archived`

触发条件：

- 当前运营周期结束。  
- 或资产不再参与后续比较。

作用：

- 把历史项移出高频工作区，但仍保留数据。

---

## 9. 字段与状态的约束关系

## 9.1 `rejected` 状态要求

当 `reviewStatus = rejected` 时：

- `rejectionReason` 应为必填。  
- `isSelected` 必须为 `false`。

## 9.2 `approved` 状态要求

当 `reviewStatus = approved` 时：

- `curationScore` 建议必填。  
- `reviewNotes` 建议至少有简短说明。  
- `isSelected` 可为 `true` 或 `false`。

说明：

- `approved` 表示通过策展判断。  
- `isSelected` 表示是否进入当前正式入选集。  
- 两者不能完全等同。

## 9.3 `archived` 状态要求

当 `reviewStatus = archived` 时：

- 不应再默认出现在主工作区。  
- 只能在历史视图中查看。  

---

## 10. 推荐的批量操作规则

## 10.1 批量标记为 `shortlisted`

适用于：

- 同一场景下的第一轮保留。  

## 10.2 批量标记为 `rejected`

适用于：

- 明显不符合场景的候选。  

要求：

- 应支持统一填写一个默认 `rejectionReason`。  

## 10.3 批量加入入选集

适用于：

- 一组已通过判断的稳定候选。  

要求：

- 仅允许 `approved` 状态的项批量加入。  

---

## 11. 运营视角下的最小决策闭环

建议每个配色盘至少沉淀以下最小信息：

1. 它属于什么场景。  
2. 它现在是什么状态。  
3. 它为什么被保留或淘汰。  
4. 它是否进入正式入选集。  

只要这四个问题能被数据回答，后续规模上来时，你就不会完全依赖记忆。

---

## 12. 最终建议

如果只给一个字段层面的建议，那就是：

**优先把“reviewStatus + curationScore + rejectionReason + reviewNotes + isSelected”这五个运营字段稳定下来。**

如果只给一个流程层面的建议，那就是：

**先用 `candidate -> shortlisted -> approved / rejected` 这条最小状态机跑通，再考虑更复杂的发布状态。**

这会比一开始设计一个很重的状态系统更稳。