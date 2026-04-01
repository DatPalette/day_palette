# 鸿蒙 ArkUI 实战 Prompt 指南 (HarmonyOS Prompt Guide)

这份文档为你提供了**直接可复制粘贴的提示词（Prompts）**。当你准备好在 DevEco Studio 中新建一个 HarmonyOS (ArkUI) 空白工程后，请在 Cursor 的 Agent 模式（或 Chat 模式）中，按照以下顺序依次发送提示词。

> **💡 核心原则**：不要一次性把所有任务发给 AI。每次发送一个 Prompt，等 AI 写完代码、你在预览器（Previewer）或模拟器中确认效果没问题后，再发送下一个 Prompt。如果效果不对，当场让 AI 修复。

---

## 阶段 0：初始化 AI 上下文 (必须第一步执行)

在全新的 Cursor 对话中，发送以下提示词，给 AI “洗脑”，让它明确目标和规范：

```text
@day-palette/AGENTS.md
@day-palette/docs/ai-workflow/00-AI-DEVELOPMENT-HARNESS.md
@day-palette/docs/product/PRD.md
@day-palette/docs/ai-workflow/01-AI-CONTEXT-AND-RULES.md
@day-palette/docs/ai-workflow/02-PHASED-IMPLEMENTATION-PLAN.md
@day-palette/docs/design/design-system.md
@day-palette/docs/mockups/daypalette-premium-mockup.html

你现在的角色是资深 HarmonyOS 鸿蒙原生应用开发专家（精通 ArkTS 和 ArkUI）。
我们将基于 PRD、设计系统与 HTML 原型，按 Harness 中的目录约定开发 DayPalette。
需求若已确认，须先更新对应文档再写代码。
请仔细阅读上述文件。理解后，请回复：“我已阅读并理解 DayPalette 的系统指令与上下文规范，随时准备开始执行 HarmonyOS 版本的开发。”
（注意：此时不需要编写任何代码，只需确认理解即可。）
```

---

## 阶段 1：数据层与状态管理

AI 确认后，开始让它搭建底层数据结构。

```text
请执行 02-PHASED-IMPLEMENTATION-PLAN.md 中的 Phase 1 (Step 1.1 到 1.4)。

技术要求（ArkUI 规范）：
1. 在 `ets/model` 目录下创建 `Palette` 和 `Occasion` 的数据接口（interface/class）（与 `00-AI-DEVELOPMENT-HARNESS.md` 目录约定一致）。
2. 将 HTML 中的 `const data` 和 `const i18n` 转换为 ArkTS 的常量或类。
3. 创建一个 `DayPaletteViewModel` 类，使用 `@Observed` 或 `@State` 装饰器来管理 `currentLang`, `activeOccasionId`, `activePaletteId`。
4. 提供 `selectOccasion` 和 `selectPalette` 方法。

完成后请告诉我你的实现思路，暂不需要写 UI 代码。
```

---

## 阶段 2：核心 UI 骨架与静态样式

数据层没问题后，开始搭建 UI。为了防止 AI 搞乱层级，我们先让它搭出基础的 `Stack` 和 `Scroll` 结构。

```text
请执行 Phase 2。我们需要将 HTML 原型转换为 ArkUI 组件。

技术要求（ArkUI 规范）：
1. 整体页面使用 `Stack` 作为根容器，背景色设为 `#e5e3df`。
2. 主体内容放在 `Scroll` 组件中，隐藏滚动条（`scrollBar(BarState.Off)`）。
3. 按照组件化原则，分别创建 `@Component struct TopBarView`, `HeroDisplayView`, `OccasionSelectorView`, `PaletteSelectorView`, `BottomActionsView`。
4. **毛玻璃效果**：TopBarView 和 BottomActionsView 请使用 `.backdropBlur(20)` 配合 `backgroundColor('rgba(249, 248, 246, 0.75)')` 实现。
5. **色卡层叠**：HeroDisplayView 中的三个色卡，请使用 `.rotate()`、`.translate()` 和 `.shadow()` 精确还原 HTML 中的 3D 层叠和阴影参数。
6. TopBarView 固定在 Stack 顶部，BottomActionsView 固定在 Stack 底部。

请逐步输出这些组件的代码，并确保它们能正确读取 ViewModel 中的数据。
```

---

## 阶段 3：交互动效与状态绑定 (灵魂所在)

UI 静态效果调好后，加入高级的联动和动画。

```text
请执行 Phase 3。我们要实现丝滑的过渡动画和 Sticky Mini-Hero 效果。

技术要求（ArkUI 规范）：
1. **颜色过渡**：当 `activePaletteId` 改变导致 HeroDisplayView 的颜色变化时，请使用 `animation({ duration: 600, curve: Curve.EaseInOut })` 或 `animateTo` 实现平滑过渡。
2. **滚动监听（核心）**：
   - 给主 `Scroll` 组件绑定 `onScroll` 事件，记录 `yOffset` 到状态变量中。
   - 当向下滚动超过 60vp 时，TopBarView 中的日期文本 `.opacity(0)` 并向上位移；同时微缩三色胶囊（Mini-Palette）`.opacity(1)` 并取消向下位移。
   - 加上平滑的 `animation` 过渡。
3. **点击回滚**：点击 Mini-Palette 或下方的场合/配色盘时，调用 `Scroller.scrollTo({ yOffset: 0, animation: { duration: 400 } })` 滚回顶部。

请提供修改后的代码。
```

---

## 阶段 4：侧滑设置面板与多语言切换

最后实现从右侧滑入的设置面板。

```text
请执行 Phase 4。实现侧滑设置面板和多语言切换。

技术要求（ArkUI 规范）：
1. 创建 `@Component struct SettingsPanelView`。
2. 交互方式：在根 `Stack` 中，将 SettingsPanelView 放在最上层（zIndex 最高）。
3. 使用 `@State isSettingsOpen: boolean` 控制显隐。
4. 动画效果：当 `isSettingsOpen` 为 true 时，面板 `.translate({ x: 0 })`；为 false 时 `.translate({ x: '100%' })`。配合 `animateTo` 实现丝滑滑入滑出。
5. 语言切换：点击面板里的 EN/中 按钮时，更新 ViewModel 的 `currentLang`，由于数据绑定，整个界面的文案应自动刷新。

请给出完整的实现代码。
```

---

## 💡 备用 Prompt：当 AI 遇到 ArkUI 常见问题时

如果在预览器中发现效果不对，可以使用以下 Prompt 纠正 AI：

**1. 顶部/底部被系统状态栏（刘海/小白条）遮挡了：**
> “UI 被系统的状态栏和底部导航条遮挡了。请在 `EntryAbility.ets` 中设置全屏（`windowClass.setWindowLayoutFullScreen(true)`），并在根容器或 TopBar/BottomActions 中使用 `expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])` 或获取系统规避区域高度来增加 padding。”

**2. 毛玻璃效果没有透出下方的内容：**
> “TopBarView 的毛玻璃效果没有生效，或者背景变成了纯色。请检查：1. 它是否和 Scroll 组件同级且放在 Stack 的更上层（zIndex 更大）？2. 它的 backgroundColor 的 alpha 值是否正确设置为了 0.75？3. 是否正确使用了 `.backdropBlur(20)`？”

**3. 阴影被裁切了：**
> “色卡的阴影被裁切了。请检查外层容器是否不小心设置了 `.clip(true)` 或者尺寸写死了导致阴影溢出被剪裁。”