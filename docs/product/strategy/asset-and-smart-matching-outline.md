# 配色资产与智能配文档大纲

## 1. 文档目的

这份文档不是最终内容文档，而是后续补齐以下三项时可直接沿用的完整大纲：

1. **配色资产字段草表**  
2. **JSON 示例结构**  
3. **智能配第一版规则清单**

目标是把后续内容写作从“重新组织思路”变成“按大纲填空”。

---

## 2. 文档拆分建议

建议最终仍然落在两条主线文档中：

1. [color-asset-library-plan.md](./color-asset-library-plan.md)  
用途：承接资产结构、字段、JSON、维护流程。  
2. [conservative-smart-matching-strategy.md](./conservative-smart-matching-strategy.md)  
用途：承接智能配规则、候选池、场景策略、解释层。

如果后续内容变得很长，再考虑拆成附录文档。

---

## 3. 配色资产字段草表大纲

建议补到 [color-asset-library-plan.md](./color-asset-library-plan.md) 的附录部分。

### 3.1 附录 A：Base Color 字段草表

建议结构：

| 字段 | 必填 | 类型 | 示例 | 枚举/约束 | 用途说明 |
|------|------|------|------|-----------|----------|
| `id` | 是 | string | `bc_0001` | 唯一 | 基础单色主键 |
| `hex` | 是 | string | `#CBB7A1` | HEX 格式 | 渲染与机器标识 |
| `nameZh` | 是 | string | `雾杏` | 1-12 字 | 人类可读命名 |
| `nameEn` | 否 | string | `Mist Apricot` | 可空 | 英文展示 |
| `tone` | 是 | enum | `warm` | `warm/cool/neutral` | 色温分类 |
| `lightnessLevel` | 是 | enum | `light` | `light/mid/deep` | 明度分层 |
| `saturationLevel` | 是 | enum | `low` | `low/mid/high` | 饱和度分层 |
| `colorFamily` | 是 | enum | `beige` | 受控集合 | 色系归类 |
| `styleTags` | 否 | string[] | `['urban']` | 最多 5 个 | 风格标签 |
| `occasionTags` | 否 | string[] | `['citywalk']` | 最多 5 个 | 场景标签 |
| `seasonTags` | 否 | string[] | `['spring']` | 最多 4 个 | 季节标签 |
| `isNeutralCore` | 是 | boolean | `true` | - | 是否高复用中性色 |
| `status` | 是 | enum | `approved` | `draft/approved/archived` | 生命周期状态 |
| `notes` | 否 | string | - | 可空 | 主理人备注 |

建议补充章节：

1. 字段裁剪原则：哪些字段是 MVP 必需。  
2. 枚举值受控表。  
3. `Base Color` 与 `Palette` 的引用关系说明。

### 3.2 附录 B：Palette 字段草表

建议结构：

| 字段 | 必填 | 类型 | 示例 | 枚举/约束 | 用途说明 |
|------|------|------|------|-----------|----------|
| `id` | 是 | string | `pl_0101` | 唯一 | 配色盘主键 |
| `slug` | 是 | string | `mist-city-morning` | 稳定别名 | 路由/配置引用 |
| `nameZh` | 是 | string | `薄雾街角` | 1-16 字 | 中文标题 |
| `nameEn` | 否 | string | `Mist City Morning` | 可空 | 英文标题 |
| `primaryColorId` | 是 | string | `bc_0001` | 引用存在 | 主色 |
| `secondaryColorId` | 是 | string | `bc_0008` | 引用存在 | 辅色 |
| `accentColorId` | 是 | string | `bc_0021` | 引用存在 | 点缀色 |
| `occasionId` | 是 | string | `citywalk` | 受控集合 | 主场景 |
| `moodTags` | 否 | string[] | `['clear','relaxed']` | 最多 5 个 | 情绪标签 |
| `styleTags` | 否 | string[] | `['urban']` | 最多 5 个 | 风格标签 |
| `seasonTags` | 否 | string[] | `['spring']` | 最多 4 个 | 季节标签 |
| `genderLean` | 否 | enum | `female-leaning` | 可空 | 偏向标签 |
| `safetyLevel` | 是 | enum | `safe` | `safe/expressive/experimental` | 安全层级 |
| `fitPhotoScenario` | 是 | boolean | `true` | - | 是否适合出片专题 |
| `heroTitleZh` | 否 | string | `今天的故事` | 可空 | Hero 标题覆盖 |
| `heroSubtitleZh` | 否 | string | `城市里的一点雾感` | 可空 | Hero 副标题 |
| `sourceType` | 是 | enum | `curated` | `curated/recomposed/generated` | 资产来源 |
| `sourceCollectionIds` | 否 | string[] | `['col_0001']` | 可空 | 所属专题 |
| `isPro` | 是 | boolean | `false` | - | 付费边界 |
| `status` | 是 | enum | `published` | `draft/approved/published/archived` | 生命周期状态 |
| `reviewer` | 否 | string | `owner` | 可空 | 审核人 |
| `reviewNotes` | 否 | string | - | 可空 | 审核意见 |
| `createdAt` | 否 | string | ISO 时间 | 可空 | 创建时间 |
| `updatedAt` | 否 | string | ISO 时间 | 可空 | 更新时间 |

建议补充章节：

1. `primary / secondary / accent` 的角色定义。  
2. `safetyLevel` 的判定口径。  
3. `sourceType` 的使用边界。

### 3.3 附录 C：Collection 字段草表

建议结构：

| 字段 | 必填 | 类型 | 示例 | 枚举/约束 | 用途说明 |
|------|------|------|------|-----------|----------|
| `id` | 是 | string | `col_0001` | 唯一 | 专题主键 |
| `nameZh` | 是 | string | `Citywalk 拍照` | 1-16 字 | 专题名称 |
| `nameEn` | 否 | string | `Citywalk Photo` | 可空 | 英文名称 |
| `themeType` | 是 | enum | `scene` | `scene/season/festival/style/commercial` | 专题类型 |
| `descriptionZh` | 否 | string | - | 可空 | 专题描述 |
| `paletteIds` | 是 | string[] | `['pl_0101']` | 非空 | 收录列表 |
| `coverPaletteId` | 是 | string | `pl_0101` | 引用存在 | 专题封面 |
| `occasionTags` | 否 | string[] | `['citywalk']` | 可空 | 场景标签 |
| `styleTags` | 否 | string[] | `['urban']` | 可空 | 风格标签 |
| `isPro` | 是 | boolean | `true` | - | 是否付费专题 |
| `releaseMode` | 是 | enum | `permanent` | `permanent/seasonal/limited` | 发布模式 |
| `status` | 是 | enum | `planning` | `planning/ready/published/archived` | 生命周期状态 |

建议补充章节：

1. 专题与配色盘的多对多关系说明。  
2. 专题封面的选择规则。  
3. `releaseMode` 与内容更新机制的关系。

---

## 4. JSON 示例结构大纲

建议补到 [color-asset-library-plan.md](./color-asset-library-plan.md) 的附录部分，采用最小可用 JSON 样例。

### 4.1 示例文件建议

1. `base-colors.json`  
2. `palettes.json`  
3. `collections.json`

### 4.2 `base-colors.json` 示例大纲

建议内容结构：

```json
{
  "version": 1,
  "updatedAt": "2026-04-07T00:00:00Z",
  "items": [
    {
      "id": "bc_0001",
      "hex": "#CBB7A1",
      "nameZh": "雾杏",
      "nameEn": "Mist Apricot",
      "tone": "warm",
      "lightnessLevel": "light",
      "saturationLevel": "low",
      "colorFamily": "beige",
      "styleTags": ["urban", "soft"],
      "occasionTags": ["citywalk"],
      "seasonTags": ["spring", "autumn"],
      "isNeutralCore": true,
      "status": "approved"
    }
  ]
}
```

建议补充说明：

1. 文件级版本字段。  
2. 是否允许 `notes` 出现在发布态。  
3. 编辑态与发布态字段差异。

### 4.3 `palettes.json` 示例大纲

建议内容结构：

```json
{
  "version": 1,
  "updatedAt": "2026-04-07T00:00:00Z",
  "items": [
    {
      "id": "pl_0101",
      "slug": "mist-city-morning",
      "nameZh": "薄雾街角",
      "nameEn": "Mist City Morning",
      "primaryColorId": "bc_0001",
      "secondaryColorId": "bc_0008",
      "accentColorId": "bc_0021",
      "occasionId": "citywalk",
      "moodTags": ["clear", "relaxed"],
      "styleTags": ["urban"],
      "seasonTags": ["spring"],
      "safetyLevel": "safe",
      "fitPhotoScenario": true,
      "sourceType": "curated",
      "sourceCollectionIds": ["col_0001"],
      "isPro": false,
      "status": "published"
    }
  ]
}
```

建议补充说明：

1. 是否允许一个 palette 出现在多个专题。  
2. `isPro` 与专题付费边界冲突时的优先规则。  
3. `published` 与 `approved` 的区别。

### 4.4 `collections.json` 示例大纲

建议内容结构：

```json
{
  "version": 1,
  "updatedAt": "2026-04-07T00:00:00Z",
  "items": [
    {
      "id": "col_0001",
      "nameZh": "Citywalk 拍照",
      "nameEn": "Citywalk Photo",
      "themeType": "scene",
      "descriptionZh": "适合城市漫游和轻拍照的清爽都市系配色。",
      "paletteIds": ["pl_0101", "pl_0102"],
      "coverPaletteId": "pl_0101",
      "occasionTags": ["citywalk"],
      "styleTags": ["urban"],
      "isPro": false,
      "releaseMode": "permanent",
      "status": "published"
    }
  ]
}
```

建议补充说明：

1. 专题是否允许空集合。  
2. 专题是否允许混合免费与 Pro palette。  
3. 专题封面与展示排序字段是否需要补充。

---

## 5. 智能配第一版规则清单大纲

建议补到 [conservative-smart-matching-strategy.md](./conservative-smart-matching-strategy.md) 的附录部分。

### 5.1 附录 A：硬规则清单

建议章节结构：

1. 饱和度限制  
2. 明度冲突限制  
3. 主辅点角色限制  
4. 场景禁忌色限制  
5. 审核禁用组合列表

建议规则条目格式：

| Rule ID | 规则名称 | 触发条件 | 动作 | 说明 |
|---------|----------|----------|------|------|
| `HR-01` | 禁止三色同时高饱和 | primary/secondary/accent 均为 `high` | reject | 避免整体失控 |
| `HR-02` | 禁止双深色主辅叠加 | primary=`deep` 且 secondary=`deep` | reject | 避免整体沉闷 |
| `HR-03` | 限制高冲突双主色 | 两个强表达色同时占主角色 | reject | 避免视觉互抢 |

### 5.2 附录 B：软规则清单

建议章节结构：

1. 层次优先级  
2. 场景贴合度排序  
3. 专题基调排序  
4. 人工验证组合加权  
5. 安全优先策略

建议规则条目格式：

| Rule ID | 规则名称 | 条件 | 加权方向 | 说明 |
|---------|----------|------|----------|------|
| `SR-01` | 中性色辅色优先 | secondary 为 neutral core | up | 提升稳妥度 |
| `SR-02` | 场景色系一致优先 | 配色与场景标签一致 | up | 提升语义一致性 |
| `SR-03` | 实验性组合降权 | safetyLevel=`experimental` | down | 第一版偏保守 |

### 5.3 附录 C：场景规则清单

建议按每个场景单独成节：

#### C-1 `Citywalk 拍照`

建议包含：

1. 允许的主基调  
2. 推荐的辅色范围  
3. 允许的点缀表达  
4. 禁忌颜色或跳色示例  
5. 推荐解释文案模板

#### C-2 `公园出片`

建议包含：

1. 允许的主基调  
2. 推荐的辅色范围  
3. 允许的点缀表达  
4. 禁忌颜色或跳色示例  
5. 推荐解释文案模板

#### C-3 `国风新中式`

建议包含：

1. 允许的主基调  
2. 推荐的辅色范围  
3. 允许的点缀表达  
4. 禁忌颜色或跳色示例  
5. 推荐解释文案模板

### 5.4 附录 D：解释文案模板

建议按三个维度整理：

1. 场景匹配说明模板  
2. 层次关系说明模板  
3. 稳妥性说明模板

示例模板：

- 这套更适合 `{occasion}`，整体偏 `{mood}`。  
- 为了让 `{primary}` 不显得过闷，辅色保持了更稳定的中性层次。  
- 点缀色只做少量提气，避免抢走主色角色。

---

## 6. 推荐补文顺序

建议按以下顺序补齐正文：

1. 先补字段草表。  
2. 再补 JSON 示例结构。  
3. 最后补智能配规则清单。

原因：

- 智能配规则依赖资产结构。  
- JSON 示例要以字段草表为准。  
- 三者顺序稳定后，后续实现和内容维护更不容易返工。

---

## 7. 暂定结论

后续文档补充不需要从零开始写，而可以直接沿用本大纲：

- 资产层：先把字段说清楚，再给 JSON。  
- 规则层：先分硬规则和软规则，再按场景展开。  
- 输出层：最后补解释文案模板和实现注意事项。

这份大纲的目标就是让后续工作进入“填充与裁剪”阶段，而不是重新组织框架。