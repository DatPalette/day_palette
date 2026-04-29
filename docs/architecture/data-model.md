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

### 1.1 轻量持久化槽位（用于“昨日”）

为保持工具属性与本地轻量，不建立按日历史表；仅维护以下 Preferences 槽位：

| 槽位 | 类型 | 说明 |
|------|------|------|
| `today_outfit_state_json` | string | 当前 draft 的 `TodayOutfitState` JSON。 |
| `today_outfit_calendar_day` | string | 当前 draft 对应的本地自然日，格式 `YYYY-MM-DD`。 |
| `yesterday_outfit_state_json` | string | 上一自然日快照。 |
| `yesterday_outfit_calendar_day` | string | `yesterday_outfit_state_json` 对应日期，必须严格等于“今天的昨天”才算有效。 |
| `last_open_calendar_day` | string | 最近一次打开 App 时的本地自然日，用于跨日滚动。 |

**滚动规则**

1. 用户当天的修改持续覆盖 `today_outfit_state_json`，并同步写入 `today_outfit_calendar_day`。
2. App 启动时若发现 `today_outfit_calendar_day` 恰好等于昨天，则将该 draft 复制到 `yesterday_*` 槽位。
3. 若 `today_outfit_calendar_day` 早于昨天，不自动覆盖 `yesterday_*`，避免将更早草稿误判为“昨日”。
4. “昨日”按钮仅在 `yesterday_outfit_calendar_day` 严格等于昨天时视为有效。

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

## 4. 结构化配色资产（旧运营方案已归档）

> 归档提示：自 2026-04-29 起，旧 `source / curation-state / workbench / bundle` 运营方案已整体归档，统一入口见 [`../../../daypalette-docs/archive/color-operations-reset-2026-04.md`](../../../daypalette-docs/archive/color-operations-reset-2026-04.md)。
> 使用约束：本节只保留 `day_palette` 当前运行时资源的历史兼容事实，不应外推为新的运营链路或仓库边界。

如需回看旧共享层材料，请从上面的归档说明进入。

本文件只保留 `day_palette` 仓库内仍需要说明的运行时映射与兼容原则。

### 4.1 App 运行时 bundle 落点

当前移动端消费态资源位于：

- `entry/src/main/resources/rawfile/palette-data/base-colors.v1.json`
- `entry/src/main/resources/rawfile/palette-data/palettes.v1.json`
- `entry/src/main/resources/rawfile/palette-data/collections.v1.json`
- `entry/src/main/resources/rawfile/palette-data/manifest.json`
- `entry/src/main/resources/rawfile/palette-data/locale/zh-CN.v1.json`
- `entry/src/main/resources/rawfile/palette-data/locale/en-US.v1.json`

### 4.2 UI 文案与内容文案分层

纯 UI 国际化文案与配色内容文案当前已分开：

- `entry/src/main/resources/rawfile/i18n/ui/zh-CN.v1.json`
- `entry/src/main/resources/rawfile/i18n/ui/en-US.v1.json`

这样可以保证：

1. UI 设置项、按钮、错误提示与内容资产文案解耦。
2. 后续远端覆盖可只更新内容层，不必默认动 UI 文案层。
3. 内容管理和产品国际化可以分别演进。

### 4.3 App 侧兼容原则

1. 当前 App 运行时默认消费本地 `rawfile` bundle；旧 workbench / assets 的编辑态链路已归档，不应据此推导新方案。
2. 即使后续支持远端 JSON 覆盖，运行时结构也应与 App 当前 `rawfile` bundle 兼容，避免维护第二套 mapper。
3. 当前 UI 仍通过 `ColorCatalogMapper` 映射回 `Occasion / Palette` 旧模型，降低重构风险。
4. `LocaleData.ets` 当前保留 fallback bundle，用于 catalog 读取失败时回退。
5. `curation-state.v1.json` 属于已归档旧工作台方案中的运营层状态，不直接参与 App UI 渲染；这里只保留其历史职责说明。

## 5. 修订

随 PRD 与实现变更更新本表，并在 PRD 修订记录中交叉注明。

- 2026-04-03：新增“昨日”轻量快照槽位说明；明确不做按日历史，仅维护 today draft 与 yesterday snapshot。
- 2026-04-07：补充配色资产三层模型与建议文件落点；为结构化 JSON 资源与后续远端覆盖预留边界。
- 2026-04-07：阶段 0 开始落地 `base-colors / palettes / collections` 三层本地资源，并将 UI 文案从内容 locale 中拆分到 `rawfile/i18n/ui/*.json`。
- 2026-04-17：补充独立资产仓库 `daypalette-color-assets` 的 `source/current` 与 `bundle/current` 落点，并记录 `manifest.json` 与 `curation-state.v1.json` 的职责边界。
- 2026-04-20：将跨仓共享的资产结构、source / bundle 边界与生命周期说明上收至 `daypalette-docs`，本文件改为保留 App 运行时落点与兼容原则。
