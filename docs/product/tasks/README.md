# 产品任务管理（类 Jira · 按迭代）

本目录用**迭代（Sprint/Iteration）**承载已交付范围，用 **Backlog** 承载待办；新想法默认记入 [`Backlog.md`](./Backlog.md)，排期时从 Backlog **拖到**某一迭代文档（或新建 `iteration-NN.md`）。

## 文档约定

| 文件 | 用途 |
|------|------|
| `README.md` | 本说明 + 索引 |
| `iteration-01.md` | 迭代一（**已完成**）交付清单 |
| `iteration-02.md` | 迭代二（**已完成**）：体验与视觉 — BR-01/02/04/05/06 |
| `iteration-03.md` | 迭代三（**已完成**）：工程自检、实现收敛、文档回流 |
| `Backlog.md` | 统一待办池（PRD 缺口、头脑风暴、未来规划等） |

## Issue 字段（建议）

与 Jira 对齐的最低字段集，便于复制到真 Jira 或保持文档一致：

| 字段 | 说明 |
|------|------|
| **Key** | 如 `DP-101`，全库唯一（迭代内可再带子编号） |
| **Type** | Epic / Story / Task / Bug |
| **Summary** | 一句话标题 |
| **Status** | Backlog / Ready / In Progress / Done |
| **Priority** | P0～P3 或 Highest～Low |
| **Source** | PRD §x / Brainstorming T-xx / 自由输入 |
| **Acceptance** | 验收要点（可链接 PRD 验收项） |

## 与权威文档的关系

- 需求真相源仍以 [`../PRD.md`](../PRD.md) 为准；本目录为**执行与排期视图**。
- 头脑风暴与已拍板方向见 [`../Brainstorming.md`](../Brainstorming.md)；落地任务以 **Backlog 中的 Key** 为准（避免双处改状态）。

## 当前索引

- [迭代一（已完成）](./iteration-01.md)
- [迭代二（已完成）](./iteration-02.md)
- [迭代三（已完成）](./iteration-03.md)
- [Backlog](./Backlog.md)
