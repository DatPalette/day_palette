# 配色数据文件方案 · 从 LocaleData 到结构化资源

> 配色内容系统总览与资产生命周期，当前请优先阅读 [`../../../daypalette-docs/product/content-system-overview.md`](../../../daypalette-docs/product/content-system-overview.md) 与 [`../../../daypalette-docs/operations/color-asset-lifecycle.md`](../../../daypalette-docs/operations/color-asset-lifecycle.md)。
> 本文件只保留 `day_palette` 仓库内的 **rawfile 落点、catalog 映射与 fallback 兼容说明**，避免与顶层共享文档重复维护。

## 1. 文档目的

本文用于把 Brainstorming-02 和策略文档中的字段、JSON 结构，映射到 DayPalette 当前项目里的**真实文件方案**。

重点不是直接改代码，而是回答三个问题：

1. 当前真实数据放在哪里。  
2. 下一阶段应该拆成哪些真实文件。  
3. 后续如果支持远端覆盖，这些文件如何保持兼容。

---

## 2. 当前真实实现

截至目前，配色与场景数据的真实来源是：

- [entry/src/main/ets/model/LocaleData.ets](../../../entry/src/main/ets/model/LocaleData.ets)
- [entry/src/main/ets/model/Palette.ets](../../../entry/src/main/ets/model/Palette.ets)
- [entry/src/main/ets/model/Occasion.ets](../../../entry/src/main/ets/model/Occasion.ets)

当前特点：

- 历史真相源是 `LocaleData.ets` 中的硬编码 `Occasion + Palette`。  
- 当前阶段 0 已开始引入本地 `rawfile` 结构化 JSON 与 `catalog` 加载层。  
- `DayPaletteViewModel` 仍通过 `getLocaleBundle()` 消费数据，但 `LocaleData.ets` 已支持“优先读 catalog，失败再回退硬编码”。

这意味着：

- **当前若要调整 palette 数据，通常需要改 ArkTS 并重新发版。**

---

## 3. 映射目标

### 3.1 不再把所有内容长期堆在 `LocaleData.ets`

后续建议逐步把：

- UI 文案  
- 场景结构  
- 配色资产  
- 专题合集

拆成不同层次的数据源。

### 3.2 首轮目标不是完整 CMS，而是结构化本地资源

建议先从“**硬编码 ArkTS -> 结构化本地 JSON 资源**”这一步开始。

理由：

- 与当前项目结构最兼容。  
- 风险低。  
- 后续如果要加远端覆盖，也能直接复用 JSON 结构。

---

## 4. 建议的真实文件落点

### 4.1 当前已落地资源目录

当前已落地目录：

- `entry/src/main/resources/rawfile/palette-data/`
- `entry/src/main/resources/rawfile/palette-data/locale/`
- `entry/src/main/resources/rawfile/i18n/ui/`

当前已落地文件：

- `entry/src/main/resources/rawfile/palette-data/base-colors.v1.json`  
- `entry/src/main/resources/rawfile/palette-data/palettes.v1.json`  
- `entry/src/main/resources/rawfile/palette-data/collections.v1.json`  
- `entry/src/main/resources/rawfile/palette-data/locale/zh-CN.v1.json`  
- `entry/src/main/resources/rawfile/palette-data/locale/en-US.v1.json`  
- `entry/src/main/resources/rawfile/i18n/ui/zh-CN.v1.json`  
- `entry/src/main/resources/rawfile/i18n/ui/en-US.v1.json`

说明：

- `base-colors / palettes / collections` 放结构化业务数据。  
- `palette-data/locale/*.json` 只放**内容文案**，如场景 label/title、palette 名称与描述。  
- `i18n/ui/*.json` 只放**纯 UI 文案**，如按钮、设置项、错误提示。  
- 这样可以把产品界面文案与配色资产内容文案拆开，便于后续分别管理与远端覆盖。

### 4.2 ArkTS 类型与加载层

当前已落地目录：

- `entry/src/main/ets/model/catalog/`

当前已落地文件：

- `ColorCatalogTypes.ets`：定义 `UiCatalogFile / BaseColorCatalogFile / PaletteCatalogFile / CollectionCatalogFile / LocaleContentCatalogFile`  
- `ColorCatalogLoader.ets`：读取 `rawfile` 下 JSON 并做基础解析  
- `ColorCatalogRepository.ets`：按语言组合 `base-colors + palettes + ui + locale-content` 形成 `LocaleBundle`  
- `ColorCatalogMapper.ets`：把结构化资产映射回当前 UI 仍在使用的 `Occasion / Palette` 结构

---

## 5. 与当前模型的映射关系

### 5.1 当前模型

- `Palette`: `{ id, name, desc, colors }`  
- `Occasion`: `{ id, label, title, palettes }`

### 5.2 过渡期建议

过渡期不强行重写 UI 组件，可以先保持 `ViewModel` 面向当前模型，新增一个“目录仓库 -> 当前 UI 模型”的映射层。

当前映射方式：

1. `base-colors.v1.json` 提供颜色原子层。  
2. `palettes.v1.json` 提供 `primaryColorId / secondaryColorId / accentColorId`、标签和状态等结构。  
3. `palette-data/locale/*.json` 提供场景与 palette 的内容文案。  
4. `i18n/ui/*.json` 提供纯 UI 文案。  
5. `ColorCatalogMapper.ets` 最终把它们组装成当前 UI 仍可直接消费的：
   - `Palette.colors = [primaryHex, secondaryHex, accentHex]`
   - `Occasion.label / title`
   - `Occasion.palettes`

这样可以保证：

- UI 层短期不必大改。  
- 数据层已经开始结构化。  
- 后续再逐步替换 `Palette` 与 `Occasion` 的旧模型。

---

## 6. 本地资源与远端覆盖的兼容方案

### 6.1 阶段 0：纯本地资源

当前阶段 0 运行时读取：

- `rawfile/palette-data/*.json`
- `rawfile/palette-data/locale/*.json`
- `rawfile/i18n/ui/*.json`

特点：

- 改数据仍需发版。  
- 但已经摆脱“所有内容都堆在 ArkTS 硬编码里”的旧形态。  
- `LocaleData.ets` 当前保留 fallback，可在本地 catalog 读取失败时回退到原硬编码 bundle。

### 6.2 阶段 1：本地基础库 + 远端覆盖

后续如果需要降低发版频率，可在本地资源之上增加：

- 缓存在 Preferences 或应用文件目录中的远端 JSON 覆盖包。

建议原则：

1. 本地 `rawfile` 永远是安全回退源。  
2. 远端包必须带 `version` 与 `updatedAt`。  
3. 远端拉取失败时，应用自动回退到本地资源。  
4. 远端包结构必须与本地 JSON 结构保持兼容。

### 6.3 阶段 2：后台或 CMS

只有在这些条件成立时，才值得再往前：

- 内容更新频率明显提高。  
- 不再只是个人主理人单点维护。  
- 需要权限、审核、回滚和多人协作。

---

## 7. 建议的迁移顺序

1. 先补类型文档和 JSON 资源结构。  
2. 再把 `LocaleData.ets` 中的 palette 数据迁移到 `rawfile`。  
3. 将纯 UI 文案与内容文案分层，避免混在同一 locale 文件里。  
4. 新增加载器和映射层。  
5. 等本地文件化稳定后，再决定是否引入远端覆盖。

---

## 8. 与当前工程目录的对应关系

建议对应如下：

| 目标 | 当前位置 | 建议位置 |
|------|----------|----------|
| UI 文案 | `entry/src/main/ets/model/LocaleData.ets` 旧硬编码 | `rawfile/i18n/ui/*.json` |
| 场景内容文案 | `entry/src/main/ets/model/LocaleData.ets` 旧硬编码 | `rawfile/palette-data/locale/*.json` |
| 配色盘结构 | `entry/src/main/ets/model/LocaleData.ets` 旧硬编码 | `rawfile/palette-data/palettes.v1.json` |
| 基础单色库 | 已落地 | `rawfile/palette-data/base-colors.v1.json` |
| 专题合集 | 已落地 | `rawfile/palette-data/collections.v1.json` |
| 数据加载逻辑 | `LocaleData.ets` 旧硬编码直返 | `entry/src/main/ets/model/catalog/ColorCatalogLoader.ets` |
| ViewModel 查询入口 | `getLocaleBundle()` | `ColorCatalogRepository + mapper + LocaleData fallback` |

---

## 9. 暂定结论

当前已落地的阶段 0 方案是：

- 将配色资产拆成 `base-colors / palettes / collections` 三层 JSON。  
- 将纯 UI 文案与配色内容文案拆成两层本地化文件。  
- 通过 ArkTS `catalog` 加载层映射回当前 UI 结构。  
- 暂时保留 `LocaleData.ets` 作为 fallback，降低迁移风险。  
- 等本地结构稳定后，再决定是否进入远端 JSON 覆盖。