# DayPalette 分阶段实施计划 (Phased Implementation Plan)

> **⚠️ 给 AI 助手的执行指令：**
> 以下是 DayPalette 原生应用开发的完整步骤清单。
> 你必须按照以下 Phase（阶段）和 Step（步骤）的顺序，**逐一执行**。
> 每次人类开发者指定你执行某个 Step 时，你必须先读取 [`../mockups/daypalette-premium-mockup.html`](../mockups/daypalette-premium-mockup.html) 中对应的 DOM 和 CSS，然后编写原生代码，并**等待人类开发者的审核**。

---

## Phase 1: 基础工程搭建与数据层 (Foundation & Data Layer)

### [ ] Step 1.1: 初始化项目结构
- 创建项目的目录结构（Models, Views, ViewModels, Utils 等）。
- 设置全局的颜色、间距、圆角常量（提取自 HTML 的 `:root` 变量）。
- 配置应用的入口文件（App/WindowStage/SceneDelegate）。

### [ ] Step 1.2: 定义数据模型 (Data Models)
- 参考 HTML 中的 `const data` 和 `const i18n`。
- 定义 `Palette`（配色盘）结构体（包含 id, name, desc, colors 数组）。
- 定义 `Occasion`（场合）结构体（包含 id, label, title, palettes 数组）。

### [ ] Step 1.3: 实现国际化字典 (i18n Dictionary)
- 创建一个多语言资源管理器或枚举。
- 录入 HTML 中 `en` 和 `zh` 的所有静态文案（如 "Story of the Day" / "今天的故事"）和动态数据（Occasions & Palettes）。

### [ ] Step 1.4: 构建全局状态管理 (State / ViewModel)
- 创建一个 `DayPaletteViewModel`（或等效的状态容器）。
- 管理 `@Published` / `@State` 变量：`currentLang` (默认 'en'), `activeOccasionId` (默认 'workday'), `activePaletteId` (默认 'w1')。
- 实现 `selectOccasion(id)` 和 `selectPalette(id)` 方法，确保切换场合时自动选中第一个配色盘。

---

## Phase 2: 核心 UI 骨架与静态样式 (Core UI Skeletons & Styling)

### [ ] Step 2.1: 搭建主滚动视图 (Main ScrollView)
- 创建主页面的基础结构，背景色设置为 `#e5e3df`（或 `--bg-color` `#f9f8f6`）。
- 包含一个全屏的 `ScrollView`（或 `List`），隐藏滚动条。

### [ ] Step 2.2: 实现 TopBarView (顶部导航栏)
- 提取 HTML 中 `.top-bar` 的布局。
- 包含日期（Date）、地点（Location）和设置按钮（Settings Button）。
- 应用毛玻璃效果（Backdrop Blur / UltraThinMaterial）和半透明背景 `rgba(249, 248, 246, 0.75)`。
- 固定在顶部（Sticky Header / Pinned View）。

### [ ] Step 2.3: 实现 HeroDisplayView (大色卡预览区)
- 提取 HTML 中 `.hero-display` 的布局。
- 包含主标题（Mood Title，注意中英文字体栈的区别）。
- **核心难点**：实现三个物理色卡（`.swatch-main`, `.swatch-sec`, `.swatch-acc`）的 3D 层叠效果。使用原生代码的 Rotation、Offset 和 Shadow 属性 1:1 还原 HTML 中的 `transform: translateZ(...) rotateY(...)` 和 `box-shadow`。
- 添加底部的色值标签（Color Labels）。

### [ ] Step 2.4: 实现 OccasionSelectorView & PaletteSelectorView (横向滚动列表)
- 提取 HTML 中 `.occasion-selector` 和 `.palette-selector` 的布局。
- 实现两个横向滚动的视图（Horizontal ScrollView / Scroll(Axis.Horizontal)）。
- 还原场合项（Occasion Item）的选中态下划线（Active Indicator）。
- 还原配色盘卡片（Palette Card）的边框、阴影、微缩色块（Mini-swatches）和文字排版。

### [ ] Step 2.5: 实现 BottomActionsView (底部操作栏)
- 提取 HTML 中 `.bottom-actions` 的布局。
- 包含“保存（Save）”和“分享（Share）”按钮。
- 应用与 TopBar 相同的毛玻璃效果，并固定在屏幕底部。

---

## Phase 3: 交互动效与状态绑定 (Interactions & Animations)

### [ ] Step 3.1: 视图与状态绑定 (Data Binding)
- 将 Phase 2 中创建的静态 UI 组件与 Phase 1 中的 ViewModel 绑定。
- 确保点击场合或配色盘时，UI 能实时响应状态变化。

### [ ] Step 3.2: 颜色平滑过渡动画 (Color Transition Animation)
- 当 `activePaletteId` 改变时，为 `HeroDisplayView` 中的大色卡和色值标签添加 0.6s 的缓动动画（Ease-in-out / Spring），实现颜色的平滑切换。

### [ ] Step 3.3: 实现 Sticky Mini-Hero 滚动监听动效
- **核心难点**：监听主 ScrollView 的滚动偏移量（Scroll Offset）。
- 当向下滚动超过阈值（如 60px）时：
  1. `TopBarView` 中的日期/地点文本淡出（Opacity 0, TranslateY -10px）。
  2. 原本隐藏的微缩三色胶囊（`.top-mini-palette`）淡入并滑现（Opacity 1, TranslateY 0）。
- 点击微缩胶囊时，触发滚动回顶部（Scroll to Top）的动画。

---

## Phase 4: 设置面板与细节打磨 (Settings Panel & Polish)

### [ ] Step 4.1: 实现 SettingsPanelView (侧滑设置面板)
- 提取 HTML 中 `.settings-panel` 的布局。
- 实现一个覆盖全屏的视图，初始状态在屏幕右侧外（TranslateX 100%）。
- 点击 TopBar 的设置按钮时，触发平滑滑入动画（Slide-in Animation）。
- 包含返回按钮（Back Button）用于关闭面板。

### [ ] Step 4.2: 实现语言切换逻辑 (Language Toggle)
- 在设置面板中实现语言切换组件（Segmented Control / Toggle Buttons）。
- 绑定 ViewModel 的 `currentLang` 状态。
- 确保切换语言时，全局的文案（包括设置面板自身的文案）和排版字体栈能即时、平滑地更新。

### [ ] Step 4.3: 最终走查与像素级对齐 (Final Pixel-Perfect Review)
- 人类开发者与 AI 共同对照 HTML 原型，检查所有的边距（Padding/Margin）、字号（Font Size）、颜色（HEX）、圆角（Border Radius）和阴影（Shadow）是否 100% 还原。
- 修复任何在真实设备/模拟器上出现的 UI 溢出或安全区（SafeArea）遮挡问题。

---
> **执行完毕后，请人类开发者勾选对应的 Checkbox `[x]` 以记录进度。**