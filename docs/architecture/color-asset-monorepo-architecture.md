# 配色资产运营技术架构方案

> 本文当前作为技术细化参考保留。若需要统一查看产品、技术、迁移与 AI 分步执行方案，请优先阅读 [../product/strategy/color-asset-unified-master-plan.md](../product/strategy/color-asset-unified-master-plan.md)。

## 1. 文档目的

本文用于把 DayPalette 配色资产运营方案，从“产品与流程层”继续下钻到“工程结构、模块职责、数据状态、发布链路”层面。

本文重点回答以下问题：

1. DayPalette 是否适合演进为 monorepo。
2. 管理端、客户端、资产包、CLI、本地 bridge 分别应该放在哪里。
3. 前端编辑中的结果应该存在哪。
4. 点击“发布”时，前端如何安全地触发本地 CLI。
5. 在当前“仍以内置数据包随 App 发版”为前提下，整套技术链路应该如何设计。

本文描述的是**建议演进架构**，不是当前已全部落地实现。若与 [architecture.md](./architecture.md) 冲突，应以当前实现为准，并将后续真实落地结果回流本文。

---

## 2. 架构结论

对 DayPalette 当前阶段，推荐采用：

- **单仓库 monorepo**
- **Harmony 客户端与 Node 工具链隔离共存**
- **Web 管理端 + 资产包 package + schema package + CLI package**
- **可选本地 bridge 服务**，用于让管理端在本地开发态触发发布与同步

同时明确三条边界：

1. 客户端仍然只消费**导入后的内置 JSON 资源**。
2. 管理端编辑结果默认先落在**本地草稿库**，不是直接改仓库文件。
3. “发布”是一个**本地开发流程动作**，不是浏览器直接改文件，更不是运行时动态下发。

---

## 3. 为什么适合 monorepo

## 3.1 当前基础已经具备

当前 App 已经具备结构化配色资源和 catalog 加载链路：

- `entry/src/main/resources/rawfile/palette-data/`
- `entry/src/main/ets/model/catalog/`

说明 DayPalette 已经不是“所有内容都堆在 ArkTS 硬编码里”的状态，而是已经有了可被外部工具生成和替换的数据层。

## 3.2 需要一起演进的模块已经出现

如果要把“运营”真正落成工程，至少会同时出现四类内容：

- Harmony 客户端
- Web 管理端
- 结构化配色资产真相源
- 资产校验、导出、同步工具

这些内容彼此强相关，但又不适合混成一个单工程。因此 monorepo 是合理选择。

## 3.3 当前不适合上重型 monorepo 基建

DayPalette 当前仍是单人维护项目，不建议一开始引入：

- Nx
- Turborepo
- Lerna

当前更合适的是：

- `pnpm workspace`

理由：

- 足够支撑 apps / packages 分层。
- 成本低，心智负担小。
- 不会过早把时间花在基础设施而不是资产链路本身上。

---

## 4. 推荐仓库结构

建议仓库演进为：

```text
day_palette/
  apps/
    mobile/                 # 当前 Harmony 客户端工程
    admin/                  # React + Vite 管理端
  packages/
    color-assets/           # 配色资产 source / bundle / manifest
    color-schema/           # types + schema + validator
    color-cli/              # validate / build / publish / sync 命令
  tools/
    local-bridge/           # 可选，本地 Node API
  docs/
  package.json
  pnpm-workspace.yaml
```

### 4.1 apps/mobile

职责：

- 保留当前 Harmony 客户端工程。
- 继续消费导入后的 `rawfile/palette-data/*.json`。
- 不负责编辑配色资产。

建议迁移方式：

- 当前仓库根下的 Harmony 工程可逐步移动或映射到 `apps/mobile/`。
- 若短期不想动目录，也可以先逻辑上按 monorepo 设计，物理迁移后置。

### 4.2 apps/admin

职责：

- 管理端 UI
- 草稿编辑
- 本地预览
- 校验错误展示
- 调用本地 bridge 触发发布

技术栈：

- React
- Vite
- Tailwind CSS
- shadcn/ui

### 4.3 packages/color-assets

职责：

- 承载配色资产真相源
- 承载导出后的正式 bundle
- 承载 manifest 与 bundleVersion

建议结构：

```text
packages/color-assets/
  source/
    base-colors.json
    palettes.json
    collections.json
    locale/
      zh-CN.json
      en-US.json
  bundle/
    current/
      base-colors.v1.json
      palettes.v1.json
      collections.v1.json
      locale/
        zh-CN.v1.json
        en-US.v1.json
      manifest.local.json
```

说明：

- `source/` 是编辑与发布的主要真相源。
- `bundle/current/` 是供 App 导入的当前正式产物。
- 历史版本优先交给 Git 管理，不建议长期把大量旧版本目录堆在仓库里。

### 4.4 packages/color-schema

职责：

- 统一资产类型定义
- 统一 JSON schema 或 zod schema
- 提供校验规则
- 被 admin、CLI 共同复用

推荐内容：

- `types.ts`
- `schemas.ts`
- `validators/`
- `normalizers/`

### 4.5 packages/color-cli

职责：

- 提供命令行入口
- 负责 validate / build / publish / sync-mobile
- 不负责 UI

推荐命令：

- `color-cli validate`
- `color-cli build-bundle`
- `color-cli publish`
- `color-cli sync-mobile`

### 4.6 tools/local-bridge

职责：

- 在本地开发态提供一个轻量 Node API
- 供 admin 点击按钮时调用
- 内部再转调 `color-cli`

注意：

- 它不是线上服务。
- 它不是 App runtime 的一部分。
- 它只是“浏览器不能直接调本地 CLI”时的桥接层。

---

## 5. 两套工具链如何共存

## 5.1 Harmony 工具链

Harmony 客户端继续使用：

- `oh-package.json5`
- `ohpm`
- `hvigor`

这条链路不要被 pnpm 接管。

## 5.2 Node 工具链

管理端和工具包使用：

- `package.json`
- `pnpm workspace`
- Node.js

## 5.3 边界原则

必须避免两种依赖体系互相污染：

1. 不要让 Harmony 客户端依赖 Node workspace 包作为 runtime 模块。
2. 不要让 Node workspace 去接管 Harmony 构建。

正确做法是：

- Harmony 客户端只消费**导入后的 JSON 文件**。
- Node 工具链只负责**生成、校验、同步这些 JSON 文件**。

---

## 6. 三层数据状态设计

这是整套架构里最重要的边界。

### 6.1 会话态

位置：

- React 内存状态

作用：

- 当前页面正在编辑的临时值
- 表单输入、筛选状态、当前选中的 palette、未提交字段

特点：

- 仅当前页面会话有效
- 刷新页面会丢

### 6.2 草稿态

位置：

- 管理端本地 IndexedDB

作用：

- 保存“编辑中但未发布”的结果
- 支持刷新恢复
- 支持未发布草稿
- 支持脏状态提示

建议存储内容：

- `draftId`
- `assetType`
- `payload`
- `updatedAt`
- `validationErrors`
- `isDirty`

关键原则：

- 草稿态是**管理端自己的状态**。
- 它不是正式 bundle。
- 它也不是客户端的真相源。

### 6.3 发布态

位置：

- `packages/color-assets/source/`

作用：

- 经过校验和规范化后的资产真相源
- 用于生成正式 bundle

### 6.4 bundle 态

位置：

- `packages/color-assets/bundle/current/`
- 最终同步到 `apps/mobile` 或 Harmony 客户端资源目录

作用：

- 客户端运行时直接消费的正式资源包

### 6.5 为什么必须分层

如果不分这三层，会出现三类问题：

1. 编辑中的脏数据直接污染正式资源。
2. 管理端 UI 临时字段混进客户端 JSON。
3. 无法区分“正在改什么”和“已经发布什么”。

---

## 7. 发布链路设计

## 7.1 浏览器为什么不能直接发布

纯 React 页面不能直接：

- 执行本机 CLI
- 改本地仓库文件
- 做 git 写操作

因此“点击发布”不能是浏览器直接完成，而必须通过本地桥接层。

## 7.2 推荐调用链路

```text
Admin UI Button
  -> Local Bridge API
  -> child_process.spawn()
  -> color-cli publish
  -> 写入 color-assets/source 与 bundle/current
  -> 可选触发 sync-mobile
  -> 返回结果给 Admin UI
```

## 7.3 推荐 API 形态

建议本地 bridge 提供：

- `POST /publish`
- `POST /sync-mobile`
- `GET /jobs/:jobId`
- `GET /health`

### 7.3.1 `POST /publish`

输入：

- 当前草稿快照或指定 draftId
- 是否构建 bundle
- 是否自动 sync mobile

输出：

- `jobId`

### 7.3.2 `GET /jobs/:jobId`

返回：

- `queued | running | success | failed`
- stdout / stderr 摘要
- 生成的 `bundleVersion`
- 是否已同步 mobile

推荐采用任务制而不是一次请求直等，原因是：

- 发布可能包含校验、文件写入、同步多个步骤
- UI 更容易展示过程与日志

---

## 8. CLI 命令设计

推荐 CLI 保持“职责清楚、可单独调用”。

### 8.1 validate

```bash
pnpm color-cli validate
```

作用：

- 校验 source 数据
- 输出错误与警告

### 8.2 build-bundle

```bash
pnpm color-cli build-bundle
```

作用：

- 从 `source/` 生成 `bundle/current/`
- 生成或更新 `manifest.local.json`

### 8.3 publish

```bash
pnpm color-cli publish
```

作用：

- 先 validate
- 再 build-bundle
- 再写版本号
- 必要时生成发布摘要

### 8.4 sync-mobile

```bash
pnpm color-cli sync-mobile
```

作用：

- 将 `bundle/current/` 同步到 Harmony 客户端的 `rawfile/palette-data/`
- 输出 diff 摘要

## 8.5 不建议默认做的动作

CLI 不应默认：

- 自动 `git commit`
- 自动 `git push`
- 自动发布线上静态站点

这些动作要么手动执行，要么后续另行设计。

---

## 9. 管理端按钮语义

管理端建议至少区分三类按钮：

### 9.1 保存草稿

作用：

- 写入 IndexedDB 草稿库

### 9.2 发布资产包

作用：

- 调本地 bridge
- 调 CLI publish
- 生成新 bundleVersion

### 9.3 同步到客户端

作用：

- 调 CLI sync-mobile
- 将当前 bundle 导入 Harmony 客户端资源目录

### 9.4 是否做“一键发布并同步”

可以做，但不建议一开始只保留这一种动作。

更合理的是：

- 默认拆成两个按钮
- 后续再补一个组合按钮

这样问题定位更清楚，也更不容易误触。

---

## 10. 客户端同步策略

## 10.1 当前正确位置

“同步最新版本资产包”是：

- **开发流程 / 发版流程动作**

而不是：

- App runtime 能力

### 10.2 当前推荐链路

```text
Admin 发布 bundle
  -> CLI sync-mobile
  -> 覆盖 Harmony rawfile/palette-data/
  -> IDE 内真机验证
  -> 随 App 版本发布
```

### 10.3 为什么不建议现在做 runtime 更新

因为当前核心问题还不是线上更新频率，而是：

- 资产结构是否稳定
- 编辑体验是否顺手
- 导出链路是否可靠
- 客户端资源映射是否一致

在这些没有稳定之前，引入 runtime 更新只会增加变量。

---

## 11. 版本策略

## 11.1 bundleVersion

建议 bundle 使用独立版本号，例如：

- `2026.04.09.1`

## 11.2 manifest.local.json

建议至少包含：

- `schemaVersion`
- `bundleVersion`
- `exportedAt`
- `counts`

## 11.3 历史版本管理

前期不建议在 `packages/color-assets` 长期保存大量版本文件。

推荐方式：

- 当前版本放 `bundle/current/`
- 历史版本通过 Git commit / tag / release 追踪

这样可以避免仓库里积累大量冗余静态文件。

---

## 12. 风险与约束

### 12.1 最大风险不是技术，而是边界失控

需要重点避免：

1. Admin 直接修改客户端 bundle 文件。
2. 草稿态和正式态混在一起。
3. local bridge 越写越像长期服务端。
4. Node workspace 与 Harmony 工程依赖混杂。

### 12.2 当前不建议做的事

- 不建议前期上数据库草稿库。
- 不建议前期上 Electron，只为解决本地文件写入。
- 不建议前期上远端发布服务。
- 不建议前期让前端直接依赖 File System Access API 改正式资源文件。

---

## 13. V1 最小落地范围

建议第一版只做这些：

1. `pnpm workspace` monorepo 基础。
2. `apps/admin` 管理端基础骨架。
3. `packages/color-assets` 与 `packages/color-schema`。
4. `packages/color-cli` 的 `validate / build-bundle / sync-mobile`。
5. IndexedDB 草稿态。
6. 可选的本地 bridge，只提供 `publish / sync-mobile / job status`。

### 13.1 V1 可以暂缓的内容

- 多人协作权限
- 线上部署的管理后台
- 远端 JSON runtime 更新
- 自动 push / 自动 release
- 数据库存草稿

---

## 14. 演进路线

### 阶段 A：monorepo 基础与数据包真相源

- 建立 apps / packages 结构
- 把 color-assets / color-schema / color-cli 放进去

### 阶段 B：管理端本地草稿与预览

- IndexedDB 草稿
- Base Color / Palette 管理页
- 校验结果面板

### 阶段 C：发布与同步

- CLI publish
- CLI sync-mobile
- local bridge 打通前端发布按钮

### 阶段 D：首轮真实运营验证

- 用管理端完成一次真实 palette 修改
- 发布 bundle
- 同步客户端
- 真机验证

### 阶段 E：是否进入远端覆盖

- 只有当前四件事稳定后再评估：
  - 资产结构稳定
  - 编辑链路稳定
  - bundle 结构稳定
  - 客户端映射稳定

---

## 15. 暂定结论

DayPalette 适合演进为一套轻量 monorepo，但必须坚持以下前提：

- 用 monorepo 管理“客户端 + 管理端 + 资产包 + 工具链”。
- 不让 Harmony 构建链和 Node 工具链相互污染。
- 不让管理端直接碰正式 runtime 资源文件。
- 草稿态、发布态、bundle 态必须严格分层。
- “发布”通过本地 bridge 间接调用 CLI，而不是浏览器直接改文件。

在这个边界内，这套架构是可行的，而且非常适合 DayPalette 当前“单人维护、无服务器预算、仍以内置资源发版”的现实条件。