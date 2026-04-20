# 技术架构概要 · DayPalette

> 本文描述 **当前已落地实现**，不是预研态草图。若代码与本文冲突，以 `entry/src/main/ets/` 实际实现为准，并在迭代内回流本文。

## 1. 技术栈

- **平台**：HarmonyOS Next（API 版本以 DevEco 工程为准）  
- **UI**：ArkUI（声明式）  
- **语言**：ArkTS  
- **本地持久化**：Preferences  
- **桌面卡片**：Form Kit  
- **图片导出/分享**：Image Kit + Core File Kit + MediaLibrary Kit + Share Kit

## 2. 当前模块划分（按真实目录）

```
entry/src/main/ets/
  ├── pages/
  │   └── Index.ets                 # 今日页总装，负责页面编排、浮层开关、事件订阅
  ├── viewmodel/
  │   └── DayPaletteViewModel.ets   # 今日域唯一 UI 状态中心
  ├── persistence/
  │   └── TodayStateStore.ets       # 今日状态 / 昨日快照 / 设置项的 Preferences 读写
  ├── components/
  │   ├── TopBarView.ets
  │   ├── HeroDisplayView.ets
  │   ├── OccasionSelectorView.ets
  │   ├── PaletteSelectorView.ets
  │   ├── BottomActionsView.ets
  │   ├── FineTuneSheet.ets
  │   ├── MiniPalettePreviewView.ets
  │   └── SettingsPanelView.ets
  ├── export/
  │   ├── PaletteImageExporter.ets  # 纯 PixelMap 构图与模板输出
  │   ├── PaletteShareActions.ets   # 保存/分享流程、权限、缓存文件、错误归类
  │   └── HexColor.ets
  ├── formability/
  │   ├── TodayOutfitFormAbility.ets
  │   └── TodayOutfitFormSync.ets   # Form 绑定构建 + formId 跟踪 + 主应用触发刷新
  ├── widget/
  │   └── TodayOutfitFormCard.ets   # 桌面卡片 UI
  ├── model/
  │   ├── TodayOutfitState.ets
  │   ├── LocaleData.ets / LocaleTypes.ets
  │   ├── MiniPreviewStyle.ets
  │   ├── AppLanguage.ets / SystemLanguageResolver.ets
  │   └── Palette / Occasion 等领域模型
  ├── common/
  │   ├── constants/               # 设计令牌、布局常量、Hero/MiniPreview 规格、事件名
  │   └── window/                  # 底部手势区避让计算
  └── entryability/
      └── EntryAbility.ets         # Ability 生命周期、前台事件、系统配置变更转发
```

## 3. 状态边界

### 3.1 页面状态中心

- 当前没有单独的 `TodayOutfitStore` 类。  
- **唯一 UI 状态中心** 是 `DayPaletteViewModel`：负责场合、套组、精调三色、导出版式、语言、无障碍设置、顶栏微缩预览样式等。  
- `Index.ets` 只负责组装页面与转发交互，不持有业务规则本身。

### 3.2 持久化边界

- `TodayStateStore.ets` 是当前本地持久化边界。  
- 今日页状态以 `TodayOutfitState` 为主快照写入 Preferences。  
- 同时维护：
  - `today_outfit_state_json`
  - `today_outfit_calendar_day`
  - `yesterday_outfit_state_json`
  - `yesterday_outfit_calendar_day`
  - `last_open_calendar_day`
  - `reduce_motion_enabled`
  - `noise_overlay_enabled`
  - `mini_preview_style`
- 设置类写入采用短窗口合并 `flush()`；今日状态与跨日快照写入仍立即 `flush()`，优先保证状态正确性。

### 3.3 Form 同步边界

- 桌面卡片 **不直接读取页面 VM**。  
- `TodayOutfitFormAbility` 与 `TodayOutfitFormSync` 通过同一份持久化数据构建卡片绑定。  
- 主应用在 `DayPaletteViewModel.flushTodayOutfitToStorage()` 后触发已登记 formId 的刷新，保证 App 与桌面卡片读同一份本地真相源。

## 4. 页面与组件职责

### 4.1 `Index.ets`

- 今日页总装容器。  
- 管理主滚动区、TopBar、BottomActions、SettingsPanel、FineTuneSheet 的显隐与叠层。  
- 订阅 `EntryAbility` 通过 `eventHub` 发出的事件：
  - `LOCALE_CONFIG_CHANGED_EVENT`
  - `APP_FOREGROUND_EVENT`
- 负责底部手势区避让监听与 toast 展示。

### 4.2 视觉组件

- `HeroDisplayView`：主视觉 Hero 三色卡与标题。  
- `OccasionSelectorView`：场合切换。  
- `PaletteSelectorView`：精选套组列表与“随机选 / 沿用昨日 / 精调”入口。  
- `TopBarView`：顶部日期 / 收缩标题 / 微缩预览 / 设置入口。  
- `BottomActionsView`：保存与分享。  
- `SettingsPanelView`：语言、导出版式、微缩预览样式、减少动效、轻微颗粒等设置。  
- `FineTuneSheet`：三色 hex 精调面板。

### 4.3 共享渲染规格

- `HeroPaletteLayout.ets`：Hero 三卡构图规格，主视图、微缩 Hero 预览、导出链路共用。  
- `MiniPreviewLayout.ets`：顶栏与设置中的微缩预览尺寸。  
- `DesignTokens.ets` 与 `LayoutConstants.ets`：页面级语义色、霜面外壳、面板节奏、避让常量。

## 5. 关键数据流

### 5.1 今日页主链路

1. `Index.aboutToAppear()` 初始化 `DayPaletteViewModel` 上下文。  
2. 从本地读取语言、设置项、今日状态。  
3. `DayPaletteViewModel` 解析当前语言下的 `LocaleData`，决定 `activeOccasionId` / `activePaletteId` / `customHex`。  
4. 组件通过 `@ObjectLink vm` 渲染，交互回调再回到 ViewModel 修改状态。

### 5.2 今日状态写回链路

1. 用户切换场合、切换套组、随机、沿用昨日、应用精调、重置精调、修改导出版式等。  
2. `DayPaletteViewModel` 更新内存状态。  
3. 调用 `flushTodayOutfitToStorage()` 写入 `TodayStateStore`。  
4. 写入成功后同步刷新已登记桌面卡片。

### 5.3 跨自然日链路

- 首屏加载时执行一次自然日滚动检查。  
- 应用回到前台时，`EntryAbility.onForeground()` 通过 `APP_FOREGROUND_EVENT` 通知 `Index`，再由 `DayPaletteViewModel.refreshCalendarDayBoundary()` 补做检查。  
- 规则是：仅当当前草稿确实属于上一自然日时，才写入 yesterday snapshot 槽。

### 5.4 导出 / 分享链路

1. `BottomActionsView` 点击时先从 VM 生成 `PaletteExportSnapshot`，锁定当前三色、标题、模板。  
2. `PaletteShareActions` 使用 snapshot 调 `PaletteImageExporter` 生成 PixelMap。  
3. 先写入 cache PNG，再等待文件真正可读。  
4. 保存走图库/资产创建流程；分享走 Share Panel。  
- 导出链路不再依赖固定 `300ms` 盲等。

## 6. 鸿蒙 Kit 映射

| Kit | 当前用途 |
|-----|----------|
| Form Kit | 桌面卡片 Ability 与卡片数据刷新 |
| Image Kit | PixelMap 创建、PNG 编码 |
| Core File Kit | cache 文件写入、读取、unlink |
| MediaLibrary Kit | 保存到图库 |
| Share Kit | 系统分享面板 |
| ArkData Preferences | 今日状态、昨日快照、设置项、本地 formId 跟踪 |

当前未落地：IAP、Intents、通知。

## 7. 实现原则

- **状态单向回收**：组件不各自持久化业务状态，统一回到 `DayPaletteViewModel` 与 `TodayStateStore`。  
- **Form 与 App 共用同一本地真相源**：不各写一套颜色推导逻辑。  
- **导出与主视觉共用构图规格**：Hero 预览、微缩 Hero、导出模板尽量复用同一组几何参数。  
- **低风险优先**：渲染层优化以共享常量、缓存重复计算、减少无意义刷盘为主，不轻易改变用户可感知行为。

## 8. 后续仍待文档补齐的方向

- 商业化与 Pro 资源边界当前仍停留在 Backlog/PRD，尚未进入已实现架构。  
- 若后续引入真正的 Store/EventBus 分层，应在本文中明确替换当前 `Index + ViewModel + Preferences` 的边界描述。  
- 若导出模板继续扩展，应补一份单独的“导出渲染子系统”说明文档。

## 9. 配色数据文件化演进（规划）

当前 App 运行时消费的 palette 数据主入口已位于 `entry/src/main/resources/rawfile/palette-data/*.json`，`DayPaletteViewModel` 通过 catalog 加载链路消费；`LocaleData.ets` 当前主要保留 fallback bundle 与兼容回退职责。

下一阶段建议演进为：

1. 继续把 App 仓库中的 `entry/src/main/resources/rawfile/palette-data/*.json` 视为移动端消费态资源，而不是内容编辑态真相源。  
2. 编辑态与策展态开始外移到独立资产链路：`daypalette-color-assets/source/current/` 保存 source JSON，`daypalette-color-assets/bundle/current/` 保存消费态 bundle。  
3. `daypalette-palette-workbench` 负责读取 source、维护 `curation-state.v1.json`、执行 validate/build-bundle，并通过导入脚本把 bundle 回灌到 App `rawfile/palette-data/`。  
4. 在 `entry/src/main/ets/model/catalog/` 下继续通过加载器、仓库与 mapper，把 JSON 映射回当前 UI 仍可消费的 `Occasion / Palette` 结构；后续再决定是否进入“本地基础库 + 远端 JSON 覆盖”。

对应规划详见 [palette-data-file-scheme.md](./palette-data-file-scheme.md)。

## 10. 参考

- PRD：[`../product/PRD.md`](../product/PRD.md)  
- 数据模型：[`./data-model.md`](./data-model.md)  
- 设计系统：[`../design/design-system.md`](../design/design-system.md)
- 配色数据文件方案：[`./palette-data-file-scheme.md`](./palette-data-file-scheme.md)
