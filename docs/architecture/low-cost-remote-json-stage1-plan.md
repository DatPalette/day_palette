# 阶段 1 低成本远端 JSON 方案（客户端接入补充）

> 跨仓共享的发布策略、托管选型、manifest 结构、版本边界与最小控制要求，已收口到 [`../../../../daypalette-docs/operations/remote-json-rollout-plan.md`](../../../../daypalette-docs/operations/remote-json-rollout-plan.md)。
> 本文件只保留 `day_palette` 仓库内的**客户端请求、缓存、回退与接入边界**，避免与共享层重复维护。

## 1. 客户端目标

HarmonyOS 客户端在引入远端 JSON 覆盖时，应同时满足：

1. 首屏仍然可在无网或远端失败时直接可用。
2. 远端覆盖只影响**内容**，不影响客户端逻辑边界。
3. 远端包损坏、版本不兼容或校验失败时，可以自动回退到包内基础库。
4. UI 层不感知数据来自包内还是远端，只消费统一 Repository 结果。

## 2. 客户端请求与回退链路

推荐链路如下：

1. App 启动时先加载包内 `rawfile` 基础库。
2. 页面首屏直接用基础库渲染，不等待网络。
3. 后台请求 `manifest.json`。
4. 若远端版本较新，则下载对应 JSON 文件。
5. 本地校验远端包的 `schemaVersion`、字段结构、版本号与可读性。
6. 校验通过后缓存到本地。
7. Repository 优先返回“远端缓存包”，失败时回退“包内基础库”。

这个链路的重点是：

- **网络请求不阻塞首屏。**
- **远端包坏了也不影响基础可用性。**
- **客户端不依赖数据库或动态接口。**

## 3. App 仓内的接入边界

当前阶段应保持以下边界：

1. 包内基础库仍然位于 `entry/src/main/resources/rawfile/palette-data/`。
2. 远端缓存包的结构应与包内 bundle 兼容，避免维护第二套解析链路。
3. Repository / mapper 层应负责决定当前读取包内基础库还是远端缓存，不把判断逻辑散落到 UI 层。
4. `LocaleData.ets` 与 catalog fallback 的存在意义不变：任何远端失败都必须能回退到本地基线。

## 4. 客户端最低控制要求

即使进入远端覆盖，也建议客户端继续坚持：

1. 只消费 bundle 态，不消费编辑态 source。
2. 只接受与当前客户端兼容的 `schemaVersion`。
3. 不因远端覆盖改变既有付费边界与资源校验边界。
4. 不让远端内容下载成为页面首屏成功与否的前置条件。

## 5. 与本仓其他文档的关系

- 结构化 bundle 与 rawfile 落点：[palette-data-file-scheme.md](./palette-data-file-scheme.md)
- 实体与运行时数据结构：[data-model.md](./data-model.md)
- 迭代任务背景：[../product/tasks/iteration-05.md](../product/tasks/iteration-05.md)
