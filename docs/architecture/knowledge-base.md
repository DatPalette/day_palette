# 鸿蒙开发知识库与避坑指南 (Knowledge Base)

本文档记录 DayPalette 在鸿蒙 Next (ArkTS/ArkUI) 开发过程中积累的底层机制、组件状态同步、系统权限等核心经验，供后续迭代与 Agent 查阅。

## 1. 底层引擎与 API 坑 (ImageKit / Skia)

### 1.1 红蓝通道反转 (R/B Channel Swap)
- **现象**：通过 `image.createPixelMapSync` 创建 `RGBA_8888` 格式的位图，并手动向 `ArrayBuffer` 填入像素数据时，最终保存或显示的图片颜色可能发生冷暖反相（如蓝绿色变成黄绿色，粉色变成蓝紫色）。
- **根因**：鸿蒙底层的图形引擎（Skia）在处理位图时，默认常使用 `BGRA` 的字节序。当我们声明 `RGBA_8888` 但系统按 `BGRA` 读取时，红色（R）和蓝色（B）通道会被互换。
- **解决方案**：在纯手工操作像素数组（`Uint8Array`）时，**主动将 R 和 B 对调**（按 `B, G, R, A` 的顺序写入内存），以此抵消系统的底层翻转。

### 1.2 异步编码与内存竞态 (Memory Aliasing)
- **现象**：使用 `imagePacker.packToData(pixelMap)` 导出图片时，如果编码完成后立刻调用 `pixelMap.release()`，导出的图片可能损坏或变成其它旧图。
- **根因**：`packToData` 返回的 `ArrayBuffer` 在底层可能与原 `PixelMap` 存在内存共享或异步读取延迟，过早释放会导致内存被回收或复用。
- **解决方案**：
  1. 优先使用直接落盘的 API：`imagePacker.packToFile`，确保编码结果完整写入文件后再进行后续操作。
  2. 若必须在内存中处理，务必对返回的 Buffer 进行深拷贝（如 `buf.slice(0)`）后再释放 `PixelMap`。

## 2. 系统机制与权限坑 (MediaLibrary / UIAbility)

### 2.1 「仅修改」权限与静默写入冲突
- **现象**：应用已申请 `ohos.permission.WRITE_IMAGEVIDEO`，用户在系统设置里授予了「仅修改（照片和视频）」权限，但调用 `photoAccessHelper.createAsset` 静默保存图片时依然报错（权限不足）。
- **根因**：现代 OS 对相册权限管控极严，静默新建媒体文件通常需要极高的 ACL 权限。普通应用拿到的“仅修改”权限不足以直接调用 `createAsset`。
- **解决方案**：放弃静默写入，**全面拥抱系统弹窗（Picker / Dialog）**。
  - 先将文件写入应用沙箱（Cache）。
  - 调用 `photoAccessHelper.showAssetsCreationDialog` 唤起系统保存弹窗。
  - 用户点击“允许”后，系统接管文件转移，完全绕过复杂的权限校验。

### 2.2 系统弹窗的应用名称显示异常
- **现象**：在弹出的相册授权或其它系统级弹窗中，提示语显示为“允许 label 保存 1 张图片？”。
- **根因**：系统弹窗读取的是 `entry/src/main/resources/base/element/string.json` 中的 `EntryAbility_label` 字段，而工程初始化时该字段默认值通常为 `"label"`。
- **解决方案**：全局搜索并修改所有的 `label` 和 `app_name`（包括 `AppScope` 和各个 module 下的 `string.json`），确保其值为真实的应用名称（如 `DayPalette`）。

## 3. 状态管理与架构经验 (ArkUI)

### 3.1 `@State` 与 `@ObjectLink` 的时序滞后
- **现象**：在子组件中触发点击事件（如保存/分享），父组件的事件回调中读取的 `@State` 视图模型数据，可能落后于子组件当前显示的 UI 状态（例如 UI 已经切换到了新套组，但导出的还是上一个套组）。
- **根因**：父组件用 `@State` 持有 ViewModel，子组件用 `@ObjectLink` 绑定。在事件触发的瞬间，父组件的 `@State` 可能还没来得及完成这一帧的同步刷新。
- **解决方案**：**“谁离用户最近，谁负责拍快照”**。
  - 在子组件（持有最新 `@ObjectLink` 数据）的事件处理函数中，立刻将当前需要的核心数据打包成一个 `Snapshot`（快照对象）。
  - 将该快照作为参数传递给父组件的事件回调。
  - 异步导出逻辑只依赖这份快照，彻底阻断与可变 ViewModel 的时序耦合。

## 4. UI/UX 细节对齐

### 4.1 标题层级与状态同步
- **原则**：Hero 区域和 TopBar（微缩胶囊）是展示当前选中套组的主舞台。
- **实现**：标题必须优先显示当前选中的 `Palette.name`（如“海玻璃”），只有在套组没有名字时，才兜底显示 `Occasion.title`。这保证了用户在切换套组时，主视觉和标题能做到真正的“所见即所得”。