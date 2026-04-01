# 技术架构概要 · DayPalette

> 轻量 TDD：个人开发用，随实现补链接到具体 Ability / 模块路径。

## 1. 技术栈

- **平台**：HarmonyOS（API 版本以 DevEco 工程为准）。  
- **UI**：ArkUI（声明式）。  
- **语言**：ArkTS。

## 2. 模块划分（建议）

```
今日域（核心）
  ├── state: TodayOutfitStore（读写的唯一真相源）
  ├── ui: TodayPage（预览 + 场合 + 套组 + 操作）
  ├── palette: 免费/付费套组加载、场合规则、随机/规则生成
  └── render: 预览与出图共用布局参数

桌面域
  └── form: FormExtensionAbility，订阅 Store 或读同一本地存储

商业化
  ├── iap: 查询 Pro、恢复购买、写本地 entitlement
  └── assets: 付费 palette 包、皮肤资源

基础设施
  ├── persistence: Preferences / RDB 封装
  └── share/save: Share Kit、保存相册
```

**原则**：Form 与 App **不各写一套颜色逻辑**，只读 **同一持久化或同一 Store**。

## 3. 鸿蒙 Kit 映射

| Kit | 用途 |
|-----|------|
| Form Kit | 桌面小卡/中卡 |
| Share Kit | 分享图片 |
| 媒体/文件 | 保存出图到相册（按当期 API 选具体模块） |
| IAP | Pro 解锁（华为应用内支付） |
| Intents（可选 V1） | 直达今日页 |

**不依赖（首版）**：Notification Kit（留给洗护后期）。

## 4. 关键数据流

1. 用户改场合/套组/微调 → 更新 **TodayOutfitStore** → 写本地。  
2. Form **onUpdate** / 定时刷新 → 读本地 → 渲染。  
3. 出图：读 Store + `templateId` + `skinId`（若出图也区分皮肤）→ 离屏渲染 → 分享或保存。

## 5. 配置与资源

- `rawfile` / `resources`：`palettes.json`（可分 `palettes_free.json` / `palettes_pro.json` 或同一文件内 `tier` 字段）。  
- `occasion-rules.json`：场合 → 默认套组 id 或默认三色。  
- 皮肤：`skin` 资源 id 与 Form 布局绑定。

## 6. 参考

- 规划文档：`应用规划-今日穿搭色卡.md` 第四、五、六、七、八、十一章。  
- PRD：[`../product/PRD.md`](../product/PRD.md)。
