# DayPalette 上架自检记录 · Iteration 04

> 首轮审计时间：2026-04-07  
> 范围：应用信息、权限声明、隐私与发布文档、图标与名称、调试入口/IAP 现状、商店素材准备度。

---

## 1. 当前结论

当前工程**适合先做短链路上架自检**，优先消化那些现在就能修掉的问题，避免拖到提审前集中爆发。

- **本轮立即整改项**：存在。
- **本轮观察项**：存在。
- **回到 Backlog 的长依赖项**：存在。

本轮结论更偏“提前拆雷”，不是一次性完成所有提审前置条件。

---

## 2. 本轮立即整改项

| ID | 问题 | 当前现状 | 建议动作 |
|----|------|----------|----------|
| REL-BLOCK-01 | 应用基础信息仍有占位值 | 已于本轮整改：`vendor`、模块描述、Ability 描述与 Form 描述占位值已替换为可发布文本。 | 后续只需在名称最终定稿后复核显示文本，不再视为当前阻塞。 |
| REL-BLOCK-02 | 隐私政策文件缺失 | 已于本轮新增 [privacy-policy.md](/Users/wuxinbo/Documents/Personal/day_palette/docs/release/privacy-policy.md)。 | 后续需要补“外部可访问链接或最终承载位置”，但本地文案底稿已建立。 |
| REL-BLOCK-03 | 发布素材与品牌资源仍未成型 | [background.png](/Users/wuxinbo/Documents/Personal/day_palette/AppScope/resources/base/media/background.png) 仍是蓝底；[foreground.png](/Users/wuxinbo/Documents/Personal/day_palette/AppScope/resources/base/media/foreground.png) 仍是默认四宫格样式，不符合当前产品品牌；同时仓库中未见统一的商店素材清单。 | 先完成名称、图标与素材清单收敛，让后续提审资源不再处于默认工程状态。 |

---

## 3. 本轮观察项

| ID | 问题 | 当前现状 | 建议动作 |
|----|------|----------|----------|
| REL-FIX-01 | 应用展示名当前只有英文 | [AppScope/resources/base/element/string.json](/Users/wuxinbo/Documents/Personal/day_palette/AppScope/resources/base/element/string.json#L4) 中 `app_name` 为 `DayPalette`。当前中文品牌名“今日配色”主要存在于文档，不在应用主资源里统一收敛。 | 与 BL-BRAND-02 一起确定最终展示名策略，决定是否保留英文展示名，或在中文环境下切换为中文名。 |
| REL-FIX-02 | 权限文案还不够“提审说明化” | 已新增 [privacy-policy.md](/Users/wuxinbo/Documents/Personal/day_palette/docs/release/privacy-policy.md)，但仍需在最终上架页补齐外部展示口径。 | 后续将隐私政策落到最终提审使用的公开地址，并与权限说明页对齐。 |
| REL-FIX-03 | 平板 / 宽屏提审素材还不能现在关闭 | 设备类型已声明 `phone` / `tablet`，但真正的大屏截图与适配验收还依赖 `BL-ADAPT-01 / 02`。 | 暂记为观察项，等适配任务推进后再回到发布清单中关闭。 |
| REL-FIX-04 | 商店素材包尚未建档 | 已新增 [app-store-assets-checklist.md](/Users/wuxinbo/Documents/Personal/day_palette/docs/release/app-store-assets-checklist.md) 作为素材清单底稿，但实际素材仍待补齐。 | 在名称、图标和适配完成后逐项补素材并关闭此项。 |

---

## 4. 回到 Backlog 的长依赖项

| ID | 观察点 | 当前判断 |
|----|--------|----------|
| REL-OBS-01 | 商业化 / IAP 边界未落地 | PRD 中已写明 Pro、恢复购买与 IAP 边界，但当前实现与文档仍明确标注 IAP 未落地。 | 继续由 [Backlog.md](/Users/wuxinbo/Documents/Personal/day_palette/docs/product/tasks/Backlog.md#L11) 中 `BL-PRD-01～04` 跟踪；本轮只要求当前版本不要误导用户。 |
| REL-OBS-02 | 调试入口清理 | 代码侧暂未检索到显式 `forcePro` / `forceFree` / `sandbox` 入口；当前更多是文档计划项。 | 等未来真正实现 Debug 强制开关后，再按发布前清单确保 release 剔除。 |

---

## 5. 已审计依据

- 应用基础配置：
  - [AppScope/app.json5](/Users/wuxinbo/Documents/Personal/day_palette/AppScope/app.json5)
  - [entry/src/main/module.json5](/Users/wuxinbo/Documents/Personal/day_palette/entry/src/main/module.json5)
  - [build-profile.json5](/Users/wuxinbo/Documents/Personal/day_palette/build-profile.json5)
- 资源与文案：
  - [AppScope/resources/base/element/string.json](/Users/wuxinbo/Documents/Personal/day_palette/AppScope/resources/base/element/string.json)
  - [entry/src/main/resources/base/element/string.json](/Users/wuxinbo/Documents/Personal/day_palette/entry/src/main/resources/base/element/string.json)
  - [AppScope/resources/base/media/layered_image.json](/Users/wuxinbo/Documents/Personal/day_palette/AppScope/resources/base/media/layered_image.json)
- 发布与产品文档：
  - [docs/release/test-release-checklist.md](/Users/wuxinbo/Documents/Personal/day_palette/docs/release/test-release-checklist.md)
  - [docs/product/PRD.md](/Users/wuxinbo/Documents/Personal/day_palette/docs/product/PRD.md)
  - [README.md](/Users/wuxinbo/Documents/Personal/day_palette/README.md)

---

## 6. 下一步建议

1. 先修本轮立即整改项：基础信息占位值、隐私政策、发布文档路径、上架素材清单。
2. 再收敛品牌项：应用名称与图标，避免商店字段和应用内展示分裂。
3. 然后推进手机 / 平板适配，待 `BL-ADAPT-01 / 02` 产出后补大屏提审素材。
4. 商业化与 IAP 继续留在 Backlog，不纳入本轮短链路整改关闭条件。

## 7. 本轮已完成整改

- 已修正应用基础信息中的明显占位值：`vendor`、模块描述、Ability 描述、Form 描述。
- 已新增隐私政策底稿：[privacy-policy.md](/Users/wuxinbo/Documents/Personal/day_palette/docs/release/privacy-policy.md)。
- 已新增商店素材清单底稿：[app-store-assets-checklist.md](/Users/wuxinbo/Documents/Personal/day_palette/docs/release/app-store-assets-checklist.md)。
- 已修正发布检查文档中的旧 PRD 引用路径，并补入上述两份发布文档入口。

## 8. 收口说明

- 本轮自检到此按“短链路清理”目标收口，不继续扩展为完整提审准备。
- 需要依赖大量功能完成后再判断的事项，如最终截图、宽屏验收、商店商业化材料，统一回到 Backlog，待后续功能开发基本结束后再集中处理。