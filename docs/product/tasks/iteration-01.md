# 迭代一 · Iteration 01


| 字段     | 值                                                                                                                                                                          |
| ------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **状态** | **已完成（Done）**                                                                                                                                                              |
| **目标** | MVP 核心体验闭环：今日配色、持久化、多路径选色、出图分享、桌面卡片、设置与无障碍（不含 IAP/Pro 商业化闭环）                                                                                                               |
| **依据** | `[docs/ai-workflow/02-PHASED-IMPLEMENTATION-PLAN.md](../../ai-workflow/02-PHASED-IMPLEMENTATION-PLAN.md)` Phase 1～5 已全部勾选；与 `[../PRD.md](../PRD.md)` F-01～F-06、F-07 部分能力对齐 |


---

## Epic E1 · 基础与数据


| Key    | Type | Summary                                            | Status |
| ------ | ---- | -------------------------------------------------- | ------ |
| DP-001 | Task | 工程目录、设计令牌、入口 Ability / 窗口                          | Done   |
| DP-002 | Task | 数据模型：`Palette` / `Occasion` / `TodayOutfitState` 等 | Done   |
| DP-003 | Task | 国际化字典与中英 `LocaleData`                              | Done   |
| DP-004 | Task | `DayPaletteViewModel` 状态与场合/套组切换                   | Done   |


## Epic E2 · 今日页 UI 与动效


| Key    | Type | Summary                       | Status |
| ------ | ---- | ----------------------------- | ------ |
| DP-010 | Task | 主滚动容器、TopBar（日期 + 设置）、毛玻璃     | Done   |
| DP-011 | Task | Hero 三色预览、衬线标题、色值标签、过渡动画      | Done   |
| DP-012 | Task | 场合横滑 + 配色盘横滑（选中态与卡片）          | Done   |
| DP-013 | Task | 底部保存 / 分享毛玻璃栏                 | Done   |
| DP-014 | Task | Sticky Mini-Hero：滚动收缩、微缩胶囊、回顶 | Done   |


## Epic E3 · 设置与体验开关


| Key    | Type | Summary                   | Status |
| ------ | ---- | ------------------------- | ------ |
| DP-020 | Task | 侧滑设置面板                    | Done   |
| DP-021 | Task | 语言切换（含跟随系统）               | Done   |
| DP-022 | Task | 出图模板选择（多套基础模板）            | Done   |
| DP-023 | Task | 主题跟随系统展示文案、减少动效、Hero 噪点开关 | Done   |


## Epic E4 · MVP 功能扩展


| Key    | Type  | Summary                               | Status |
| ------ | ----- | ------------------------------------- | ------ |
| DP-030 | Story | 今日状态 Preferences 持久化；跨日昨日快照           | Done   |
| DP-031 | Story | 选色路径：随机（安全集）、昨日、精调 Sheet（HEX 覆盖）      | Done   |
| DP-032 | Story | 离屏出图、相册保存、Share Kit 分享；BGRA/Skia 通道处理 | Done   |
| DP-033 | Story | Form 服务卡片（中卡）、与 App 同源、点击进应用          | Done   |
| DP-034 | Task  | 无障碍：对比度标签、减少动效联动等                     | Done   |


---

## 本迭代明确不包含（已进 Backlog）

以下在 PRD 中仍为 MVP 范围但**代码侧未交付**，不记入迭代一完成项：

- **IAP / Pro**：一次性解锁、高级配色包、Form 皮肤包、恢复购买（见 Backlog `BL-PRD-`*）。
- **Debug 强制免费/Pro**：测试开关（见 Backlog）。
- **Intents**：系统直达今日页（PRD 预留）。

---

## PRD 映射（便于审计）


| PRD ID             | 迭代一结论                                                |
| ------------------ | ---------------------------------------------------- |
| F-01 今日状态          | Done                                                 |
| F-02 场合与联动         | Done                                                 |
| F-03 选色路径（安全随机、精调） | Done                                                 |
| F-04 主界面预览         | Done                                                 |
| F-05 出图 + 分享       | Done                                                 |
| F-06 Form 中卡       | Done                                                 |
| F-07 设置            | 语言/主题/动效/关于/模板 **Done**；**Pro 展示与购买/恢复未做** → Backlog |
| F-08 IAP           | **未做** → Backlog                                     |


