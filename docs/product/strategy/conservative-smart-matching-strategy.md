# 智能配保守版策略与运营维护（已迁出）

> 本文档已于 2026-04-20 提升到顶层共享文档仓：
>
> **新真相源：[`../../../../daypalette-docs/product/smart-matching-strategy.md`](../../../../daypalette-docs/product/smart-matching-strategy.md)**

原因：智能配的策略边界、规则体系、解释模板与候选池语义，会同时被 App（运行时消费 `strategy.v1.json`）和工作台（按规则给资产打标 / 校验）共同消费，属于跨仓合同。

## App 端运行时入口

App 当前消费的策略 JSON 文件仍位于本仓：

- [`entry/src/main/resources/rawfile/smartmatch/strategy.v1.json`](../../../entry/src/main/resources/rawfile/smartmatch/strategy.v1.json)

该文件的字段口径与可维护范围由共享层文档 §18–§23 定义，本仓不再重复说明。

## 后续更新

- 修改策略口径：编辑共享层文件。
- 修改 App 运行时配置：直接改上述 `strategy.v1.json`，并确保字段语义与共享层一致。
