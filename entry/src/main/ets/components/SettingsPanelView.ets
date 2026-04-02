import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';
import { AppLanguage } from '../model/AppLanguage';
import { TEMPLATE_IDS } from '../export/PaletteImageExporter';

@Component
export struct SettingsPanelView {
  @ObjectLink vm: DayPaletteViewModel;
  @Prop isOpen: boolean = false;
  @Prop bottomGestureInsetVp: number = 0;
  onRequestClose: () => void = () => {
  };

  private templateOptionTitle(id: string): string {
    if (id === 'tpl_columns_v2') {
      return this.vm.getUiStrings().templateColumns;
    }
    if (id === 'tpl_thirds_v3') {
      return this.vm.getUiStrings().templateThirds;
    }
    if (id === 'tpl_bento_v4') {
      return this.vm.getUiStrings().templateBento;
    }
    if (id === 'tpl_stack_v5') {
      return this.vm.getUiStrings().templateStack;
    }
    return this.vm.getUiStrings().templateEditorial;
  }

  private themeLabelFromConfiguration(): string {
    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
    try {
      const cfg = ctx.config;
      if (cfg.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_LIGHT) {
        return this.vm.getUiStrings().themeLight;
      }
      if (cfg.colorMode === ConfigurationConstant.ColorMode.COLOR_MODE_DARK) {
        return this.vm.getUiStrings().themeDark;
      }
    } catch (_e) {
    }
    return this.vm.getUiStrings().themeFollowSystem;
  }

  build() {
    Column() {
      Row() {
        Button({ type: ButtonType.Circle, stateEffect: true }) {
          Text('‹')
            .fontSize(28)
            .fontColor(DesignTokens.TEXT_MAIN)
            .fontWeight(FontWeight.Lighter)
        }
        .width(36)
        .height(36)
        .backgroundColor(Color.Transparent)
        .onClick(() => {
          this.onRequestClose();
        })

        Text(this.vm.getUiStrings().settingsTitle)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor(DesignTokens.TEXT_MAIN)
          .letterSpacing(0.32)
          .layoutWeight(1)
          .textAlign(TextAlign.Center)
          .animation({ duration: 300, curve: Curve.EaseInOut })

        Row()
          .width(36)
          .height(36)
      }
      .width('100%')
      .padding({ top: 42, left: 8, right: 24, bottom: 16 })
      .alignItems(VerticalAlign.Center)
      .borderWidth({ bottom: 1 })
      .borderColor('rgba(0, 0, 0, 0.03)')

      Scroll() {
        Column() {
          Column() {
            Column() {
              Text(this.vm.getUiStrings().langLabel)
                .fontSize(15)
                .fontColor(DesignTokens.TEXT_MAIN)
                .width('100%')
                .textAlign(TextAlign.Start)
                .animation({ duration: 300, curve: Curve.EaseInOut })
              Row({ space: 0 }) {
                Text(this.vm.getUiStrings().langFollowSystem)
                  .fontSize(11)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.vm.isFollowingSystem() ? DesignTokens.TEXT_MAIN : DesignTokens.TEXT_MUTED)
                  .padding({
                    left: 6,
                    right: 6,
                    top: 6,
                    bottom: 6
                  })
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
                  .borderRadius(6)
                  .backgroundColor(this.vm.isFollowingSystem() ? Color.White : Color.Transparent)
                  .shadow({
                    radius: this.vm.isFollowingSystem() ? 8 : 0,
                    color: 'rgba(0, 0, 0, 0.06)',
                    offsetX: 0,
                    offsetY: 2
                  })
                  .onClick(() => {
                    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
                    this.vm.setFollowSystem(ctx);
                  })
                Text('EN')
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.vm.manualLanguage === AppLanguage.EN ? DesignTokens.TEXT_MAIN :
                  DesignTokens.TEXT_MUTED)
                  .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
                  .borderRadius(6)
                  .backgroundColor(this.vm.manualLanguage === AppLanguage.EN ? Color.White : Color.Transparent)
                  .shadow({
                    radius: this.vm.manualLanguage === AppLanguage.EN ? 8 : 0,
                    color: 'rgba(0, 0, 0, 0.06)',
                    offsetX: 0,
                    offsetY: 2
                  })
                  .onClick(() => {
                    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
                    this.vm.setManualLanguage(ctx, AppLanguage.EN);
                  })
                Text('中')
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.vm.manualLanguage === AppLanguage.ZH ? DesignTokens.TEXT_MAIN :
                  DesignTokens.TEXT_MUTED)
                  .padding({ left: 8, right: 8, top: 6, bottom: 6 })
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
                  .borderRadius(6)
                  .backgroundColor(this.vm.manualLanguage === AppLanguage.ZH ? Color.White : Color.Transparent)
                  .shadow({
                    radius: this.vm.manualLanguage === AppLanguage.ZH ? 8 : 0,
                    color: 'rgba(0, 0, 0, 0.06)',
                    offsetX: 0,
                    offsetY: 2
                  })
                  .onClick(() => {
                    const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
                    this.vm.setManualLanguage(ctx, AppLanguage.ZH);
                  })
              }
              .width('100%')
              .margin({ top: 12 })
              .padding(2)
              .backgroundColor('rgba(0, 0, 0, 0.04)')
              .borderRadius(8)
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 16, bottom: 16 })
            .alignItems(HorizontalAlign.Start)
            .borderWidth({ bottom: 1 })
            .borderColor(DesignTokens.BORDER_COLOR)

            Column() {
              Text(this.vm.getUiStrings().exportTemplateLabel)
                .fontSize(15)
                .fontColor(DesignTokens.TEXT_MAIN)
                .width('100%')
                .textAlign(TextAlign.Start)
                .animation({ duration: this.vm.reduceMotion ? 1 : 300, curve: Curve.EaseInOut })
              Flex({ wrap: FlexWrap.Wrap }) {
                ForEach(TEMPLATE_IDS, (tid: string) => {
                  Text(this.templateOptionTitle(tid))
                    .fontSize(12)
                    .fontWeight(FontWeight.Medium)
                    .fontColor(this.vm.templateId === tid ? DesignTokens.TEXT_ON_INVERSE : DesignTokens.TEXT_MAIN)
                    .padding({
                      left: 10,
                      right: 10,
                      top: 8,
                      bottom: 8
                    })
                    .margin({ right: 8, bottom: 8 })
                    .borderRadius(6)
                    .backgroundColor(this.vm.templateId === tid ? DesignTokens.TEXT_MAIN : Color.Transparent)
                    .border({
                      width: 1,
                      color: this.vm.templateId === tid ? DesignTokens.TEXT_MAIN : DesignTokens.BORDER_COLOR
                    })
                    .onClick(() => {
                      this.vm.setTemplateId(tid);
                    })
                }, (tid: string) => tid)
              }
              .width('100%')
              .margin({ top: 12 })
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 16, bottom: 16 })
            .alignItems(HorizontalAlign.Start)
            .borderWidth({ bottom: 1 })
            .borderColor(DesignTokens.BORDER_COLOR)

            Row() {
              Text(this.vm.getUiStrings().reduceMotionLabel)
                .fontSize(15)
                .fontColor(DesignTokens.TEXT_MAIN)
                .animation({ duration: this.vm.reduceMotion ? 1 : 300, curve: Curve.EaseInOut })
              Toggle({ type: ToggleType.Switch, isOn: this.vm.reduceMotion })
                .selectedColor(DesignTokens.TEXT_MAIN)
                .onChange((on: boolean) => {
                  const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
                  this.vm.setReduceMotion(ctx, on);
                })
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 16, bottom: 16 })
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .borderWidth({ bottom: 1 })
            .borderColor(DesignTokens.BORDER_COLOR)

            Row() {
              Text(this.vm.getUiStrings().noiseLabel)
                .fontSize(15)
                .fontColor(DesignTokens.TEXT_MAIN)
                .animation({ duration: this.vm.reduceMotion ? 1 : 300, curve: Curve.EaseInOut })
              Toggle({ type: ToggleType.Switch, isOn: this.vm.noiseOverlay })
                .selectedColor(DesignTokens.TEXT_MAIN)
                .onChange((on: boolean) => {
                  const ctx = this.getUIContext().getHostContext() as common.UIAbilityContext;
                  this.vm.setNoiseOverlay(ctx, on);
                })
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 16, bottom: 16 })
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .borderWidth({ bottom: 1 })
            .borderColor(DesignTokens.BORDER_COLOR)

            Row() {
              Text(this.vm.getUiStrings().themeLabel)
                .fontSize(15)
                .fontColor(DesignTokens.TEXT_MAIN)
                .animation({ duration: this.vm.reduceMotion ? 1 : 300, curve: Curve.EaseInOut })
              Text(this.themeLabelFromConfiguration())
                .fontSize(14)
                .fontColor(DesignTokens.TEXT_MUTED)
                .animation({ duration: this.vm.reduceMotion ? 1 : 300, curve: Curve.EaseInOut })
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 16, bottom: 16 })
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
            .borderWidth({ bottom: 1 })
            .borderColor(DesignTokens.BORDER_COLOR)

            Row() {
              Text(this.vm.getUiStrings().aboutLabel)
                .fontSize(15)
                .fontColor(DesignTokens.TEXT_MAIN)
                .animation({ duration: 300, curve: Curve.EaseInOut })
              Text('v1.0.0')
                .fontSize(14)
                .fontColor(DesignTokens.TEXT_MUTED)
            }
            .width('100%')
            .padding({ left: 20, right: 20, top: 16, bottom: 16 })
            .justifyContent(FlexAlign.SpaceBetween)
            .alignItems(VerticalAlign.Center)
          }
          .width('100%')
          .borderRadius(16)
          .border({ width: 1, color: DesignTokens.BORDER_COLOR })
          .backgroundColor(DesignTokens.SURFACE_CARD)
          .clip(true)
          .shadow({
            radius: 12,
            color: 'rgba(0, 0, 0, 0.02)',
            offsetX: 0,
            offsetY: 4
          })
        }
        .width('100%')
        .padding(24)
      }
      .layoutWeight(1)
      .scrollBar(BarState.Off)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding({ bottom: this.bottomGestureInsetVp })
    .backgroundColor(DesignTokens.BG_PAGE)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}
