# 从 HTML 原型到原生应用：AI 辅助开发指南

经过前期的设计与打磨，我们已经得到了一个极其高保真、交互细腻且充满高级感的 HTML 原型（[`../mockups/daypalette-premium-mockup.html`](../mockups/daypalette-premium-mockup.html)）。

在使用 AI（如 Cursor、Claude、ChatGPT）将这个 HTML 原型转换为原生应用（如 HarmonyOS 的 ArkUI，或 Apple 的 SwiftUI）时，**千万不要直接把 HTML 扔给 AI 并说“帮我把这个写成 App”**。这样生成的代码往往是一团乱麻，且难以维护。

以下是一套经过验证的、能最大程度还原设计质感的 **“拆解式 Prompt 工作流”**。

---

## 1. 核心原则：拆解与分步投喂

AI 在处理大量代码和复杂逻辑时容易丢失细节（尤其是动画和毛玻璃等高级 UI 特性）。因此，必须按照 **数据层 -> 基础结构 -> 样式细节 -> 交互动效** 的顺序逐步让 AI 实现。

每次对话只专注一个具体的任务，并验证效果。

---

## 2. 准备工作：设置 AI 的上下文 (Context)

在开始写代码前，先给 AI 建立全局认知。在 Cursor 中，你可以新建一个 Chat 或开启 Agent 模式，并带入以下上下文：

> **初始 Prompt：**
> “我正在开发一个名为 DayPalette（今日配色）的原生应用（请指定你的目标平台：如 HarmonyOS Next / ArkUI 或 iOS / SwiftUI）。
> 
> 我已经有一个非常完善的 HTML 高保真原型，包含了所有的视觉、布局和交互动效。
> 请阅读以下两个文件，了解产品的业务逻辑和视觉表现：
> 1. PRD：`@day-palette/docs/product/PRD.md`
> 2. HTML 原型：`@day-palette/docs/mockups/daypalette-premium-mockup.html`
> 
> 接下来，我们将分步把这个 HTML 原型转化为原生的组件代码。在接下来的步骤中，你必须严格参考 HTML 中的 CSS 属性（如间距、字号、颜色 HEX、圆角大小）来编写原生代码，追求 1:1 的像素级还原。如果明白，请回复‘准备就绪’。”

---

## 3. 分步生成实操指南

### 步骤一：提取数据模型与状态管理 (Data & State)

原生应用需要强类型的数据结构，而 HTML 中的数据是写死在 JS 里的。

> **Prompt 示例：**
> “请参考 HTML 原型中 `<script>` 标签内的 `data` 和 `i18n` 对象，为我生成原生应用的数据模型（Models）。
> 1. 定义 Palette、Occasion 等数据结构（使用 struct / interface / class）。
> 2. 创建一个 ViewModel 或 State Manager，用于管理当前选中的场合（activeOccasion）和选中的配色盘（activePaletteId）。
> 3. 提供中英文多语言资源（i18n）的配置定义方案。”

### 步骤二：构建基础 UI 骨架 (Layout & Views)

让 AI 按照 HTML 的 DOM 结构，搭建出原生视图的层级。此时先不苛求毛玻璃或复杂动画。

> **Prompt 示例：**
> “现在，请根据 HTML 中的 `<div class="device-inner">` 内部的结构，搭建主页面的原生 UI 组件（View）。
> 请将其拆分为几个子组件结构：
> 1. `TopBarView` (包含日期和设置按钮；无占位地点文案)
> 2. `HeroDisplayView` (包含主标题和大色卡)
> 3. `OccasionSelectorView` (横向滚动的场合列表)
> 4. `PaletteSelectorView` (横向滚动的配色盘列表)
> 5. `BottomActionsView` (保存和分享按钮)
> 
> 注意：整个页面需要是一个可滚动的容器（如 ScrollView / Scroll）。请先帮我写出主页面和这几个子组件的占位结构（只包含基础的排版方向如 HStack/VStack/Row/Column，以及 CSS 中的 padding/margin 数据）。”

### 步骤三：深度还原视觉质感 (Styling & Aesthetics)

这是最重要的一步，需要引导 AI 将 CSS 特性准确映射到原生的 Modifier 或属性上。

> **Prompt 示例：**
> “接下来我们来还原 UI 质感。请特别关注以下几个在 HTML 中定义的核心 CSS 特性，并在原生代码中找到最佳的对应实现：
> 1. **色彩与圆角**：背景色使用 `#f9f8f6`，卡片圆角严格按照 HTML 中的 `border-radius` 数值（如卡片 2px，大色卡等）。
> 2. **毛玻璃效果（Backdrop Blur）**：`TopBarView` 和 `BottomActionsView` 在 HTML 中使用了 `backdrop-filter: blur(20px) saturate(150%)` 和 rgba(249, 248, 246, 0.75) 的背景。请在原生代码中实现完全相同的磨砂玻璃材质（如 SwiftUI 的 `.ultraThinMaterial` 或 ArkUI 的 `blur` / `backdropBlur` 属性）。
> 3. **字体系统（Typography）**：标题需要使用特定的衬线字体（Serif），正文使用无衬线体。请展示如何在代码中应用自定义字体配置。
> 4. **物理色卡的层叠与阴影**：`HeroDisplayView` 中的三个色卡有旋转（Rotate）、位移和阴影（Box-shadow）。请用原生的 Transform 和 Shadow 属性 1:1 还原这种纸片交叠的质感。”

### 步骤四：实现丝滑交互与动效 (Interactions & Animations)

原型的灵魂在于“Sticky Mini-Hero”和颜色的平滑过渡。

> **Prompt 示例：**
> “现在我们要实现交互和动效。请参考 HTML 原型中的 JS 逻辑和 CSS transition：
> 1. **颜色过渡动画**：当状态中的 `activePaletteId` 改变时，`HeroDisplayView` 中的三个大色块颜色必须要有平滑的过渡动画（0.6s ease/spring 动画）。
> 2. **点击回滚**：点击底部的某个配色盘时，列表本身不滚动，但如果大色卡不在视野内，应当提供一种机制（如 ScrollProxy / ScrollReader）平滑滚动回顶部。
> 3. **Sticky Mini-Hero 动效（核心）**：
>    - 监听主 Scroll 容器的滚动偏移量（Scroll Offset）。
>    - 当向下滚动超过特定阈值（如 60px）时，`TopBarView` 中的大日期文本淡出消失，同时原本隐藏的微缩三色胶囊（Mini-Palette）伴随 Y 轴位移和透明度动画浮现。
>    - 请给出完整的滚动监听与状态绑定代码。”

### 步骤五：完善设置面板与侧滑交互 (Modals & Overlays)

> **Prompt 示例：**
> “最后，实现 HTML 原型中那个通过 `transform: translateX(100%)` 实现的侧滑设置面板。
> 在原生应用中，请提供一个优雅的方案（如 SwiftUI 的 `.transition(.move(edge: .trailing))` 或 ArkUI 的 Panel / 自定义动画 Popup）。要求：
> 1. 从屏幕右侧覆盖式滑入。
> 2. 包含语言切换和外观显示的静态列表。
> 3. 语言切换时，触发全局的 i18n 重新渲染。”

---

## 4. 常见坑点与翻译字典（CSS -> Native）

为了防止 AI “自作主张”或者使用粗糙的替代方案，当你发现 AI 生成的效果不对时，可以用以下对应关系纠正它：

| HTML/CSS 特性 | SwiftUI (iOS) 最佳实践 | ArkUI (HarmonyOS) 最佳实践 |
| :--- | :--- | :--- |
| `backdrop-filter: blur(20px)` | `.background(.ultraThinMaterial)` 或 自定义 `UIVisualEffectView` | `.backdropBlur(20)` 结合 `backgroundColor(rgba)` |
| `position: sticky` | `LazyVStack` 中的 `pinnedViews: [.sectionHeaders]` | `List` 中的 `ListItemGroup` 结合 `sticky(StickyStyle.Header)` |
| `box-shadow` | `.shadow(color:radius:x:y:)` | `.shadow({ radius, color, offsetX, offsetY })` |
| `transform: translateZ` (3D层叠) | `.rotation3DEffect` + `.offset` + `.zIndex` | `.rotate` + `.translate` + `.zIndex` |
| `scroll-behavior: smooth` | `ScrollViewReader` 的 `.scrollTo(id, anchor: .top)` | `Scroller.scrollTo({ yOffset: 0, animation: { duration } })` |
| 监听滚动阈值显隐组件 | 结合 `GeometryReader` 与 `preferenceKey` 读取 `minY` | `Scroll` 组件的 `onScroll` 事件读取 `yOffset` |

## 5. 总结

使用这套文档，你在要求 AI 生成代码时，本质上扮演的是一个**高级产品经理/UI 设计师**的角色。
不要让 AI “自由发挥”界面长什么样，而是以 [`../mockups/daypalette-premium-mockup.html`](../mockups/daypalette-premium-mockup.html) 为**唯一的 Absolute Truth（绝对真理）**，强制 AI 进行**逐字逐句的翻译与像素级还原**。