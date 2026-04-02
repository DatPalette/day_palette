/**
 * 服务卡片点击跳转：部分 SDK 未将 postCardAction 暴露在可解析的 ohos 模块中，
 * 运行时由系统注入，此处仅补充类型声明以便 ArkTS 编译通过。
 */
declare function postCardAction(component: Object, action: ESObject): void;
