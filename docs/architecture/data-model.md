# 数据模型 · DayPalette

> 与 `应用规划-今日穿搭色卡.md` 第五章一致；实现时可为 RDB 表 + JSON 列或拆表。

## 1. TodayOutfitState（首版主实体）

| 字段 | 类型 | 必填 | 说明 |
|------|------|------|------|
| `schemaVersion` | int | 是 | 迁移用，首版如 `1` |
| `primaryColor` | string | 是 | HEX，如 `#C4A484` |
| `secondaryColor` | string | 是 | HEX |
| `accentColor` | string | 是 | HEX |
| `occasionId` | string \| null | 否 | 枚举 id，如 `commute` |
| `shortNote` | string | 否 | 最大长度 **20**（与 PRD 一致，可调） |
| `templateId` | string | 是 | 出图/预览版式 |
| `layoutVariantId` | string \| null | 否 | 预留多套竖版结构 |
| `featureFlags` | int \| null | 否 | 预留位运算开关 |
| `ext` | object | 是 | 首版 `{}`；预留 `wearStats`、`careReminder` |
| `updatedAt` | number / string | 是 | ISO 或毫秒时间戳 |

**约束**：`ext` 建议始终序列化为对象，避免 `null` 与缺键混用。

## 2. Entitlement（Pro）

| 字段 | 类型 | 说明 |
|------|------|------|
| `isPro` | boolean | 是否已购 Pro |
| `purchaseToken` / `originalPurchaseTime` | 按 IAP SDK | 以华为文档为准 |
| `lastVerifiedAt` | timestamp | 可选，用于校验策略 |

本地以 **Preferences 安全存储** 或加密存储为准，按官方推荐实践。

## 3. 后期占位（仅文档，首版可不建表）

**WeeklyWearCounts（3.3）**  
- `weekStartDate`  
- `tagCounts`: Record\<tagId, number\>

**CareReminder（3.4）**  
- `nextNotifyAt`  
- `labelId` 或短标题

可整体塞进 `ext`，待功能立项再规范化。

## 4. JSON 资源结构（示例）

**套组条目 `PaletteItem`**（示意）：

```json
{
  "id": "oat_milk",
  "name": "燕麦奶咖",
  "colors": ["#C4A484", "#8B6914", "#F5F0E8"],
  "occasionIds": ["commute", "casual"],
  "tier": "free"
}
```

- `tier`: `free` | `pro`  
- 随机/筛选：先 `filter(occasion)` 再 `filter(tier)`。

## 5. 修订

随 PRD 与实现变更更新本表，并在 PRD 修订记录中交叉注明。
