import { common, ConfigurationConstant } from '@kit.AbilityKit';
import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';
import { LayoutConstants } from '../common/constants/LayoutConstants';
import { AppLanguage } from '../model/AppLanguage';
import { MiniPreviewStyle } from '../model/MiniPreviewStyle';
import {
  SETTINGS_MINI_PREVIEW_HEIGHT,
  SETTINGS_MINI_PREVIEW_WIDTH
} from '../common/constants/MiniPreviewLayout';
import { MiniPalettePreviewView } from './MiniPalettePreviewView';
import {
  TEMPLATE_BENTO_ID,
  TEMPLATE_COLUMNS_ID,
  TEMPLATE_IDS,
  TEMPLATE_STACK_ID,
  TEMPLATE_THIRDS_ID
} from '../export/PaletteImageExporter';

@Component
export struct SettingsPanelView {
  @ObjectLink vm: DayPaletteViewModel;
  @Prop isOpen: boolean = false;
  @Prop bottomGestureInsetVp: number = 0;
  onRequestClose: () => void = () => {
  };

  private hostContext(): common.UIAbilityContext {
    return this.getUIContext().getHostContext() as common.UIAbilityContext;
  }

  private selectedShadowRadius(selected: boolean): number {
    return selected ? LayoutConstants.SETTINGS_SELECTED_SHADOW_RADIUS_VP : 0;
  }

  private templateOptionTitle(id: string): string {
    if (id === TEMPLATE_COLUMNS_ID) {
      return this.vm.getUiStrings().templateColumns;
    }
    if (id === TEMPLATE_THIRDS_ID) {
      return this.vm.getUiStrings().templateThirds;
    }
    if (id === TEMPLATE_BENTO_ID) {
      return this.vm.getUiStrings().templateBento;
    }
    if (id === TEMPLATE_STACK_ID) {
      return this.vm.getUiStrings().templateStack;
    }
    return this.vm.getUiStrings().templateEditorial;
  }

  private themeLabelFromConfiguration(): string {
    const ctx = this.hostContext();
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

  private miniPreviewLabel(style: MiniPreviewStyle): string {
    return style === MiniPreviewStyle.Hero ?
      this.vm.getUiStrings().miniPreviewStyleHero : this.vm.getUiStrings().miniPreviewStyleCapsule;
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
        .width(LayoutConstants.CHROME_ICON_BUTTON_SIZE_VP)
        .height(LayoutConstants.CHROME_ICON_BUTTON_SIZE_VP)
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
          .width(LayoutConstants.CHROME_ICON_BUTTON_SIZE_VP)
          .height(LayoutConstants.CHROME_ICON_BUTTON_SIZE_VP)
      }
      .width('100%')
      .padding({ top: 42, left: 8, right: LayoutConstants.PAGE_HORIZONTAL_VP, bottom: 16 })
      .alignItems(VerticalAlign.Center)
      .borderWidth({ bottom: 1 })
      .borderColor(DesignTokens.BORDER_SUBTLE)

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
                    left: LayoutConstants.SETTINGS_SYSTEM_CHIP_PADDING_HORIZONTAL_VP,
                    right: LayoutConstants.SETTINGS_SYSTEM_CHIP_PADDING_HORIZONTAL_VP,
                    top: LayoutConstants.SETTINGS_CHIP_PADDING_VERTICAL_VP,
                    bottom: LayoutConstants.SETTINGS_CHIP_PADDING_VERTICAL_VP
                  })
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
                  .borderRadius(LayoutConstants.SETTINGS_CHIP_RADIUS_VP)
                  .backgroundColor(this.vm.isFollowingSystem() ? Color.White : Color.Transparent)
                  .shadow({
                    radius: this.selectedShadowRadius(this.vm.isFollowingSystem()),
                    color: DesignTokens.SHADOW_SOFT,
                    offsetX: 0,
                    offsetY: 2
                  })
                  .onClick(() => {
                    this.vm.setFollowSystem(this.hostContext());
                  })
                Text('EN')
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.vm.manualLanguage === AppLanguage.EN ? DesignTokens.TEXT_MAIN :
                  DesignTokens.TEXT_MUTED)
                  .padding({
                    left: LayoutConstants.SETTINGS_CHIP_PADDING_HORIZONTAL_VP,
                    right: LayoutConstants.SETTINGS_CHIP_PADDING_HORIZONTAL_VP,
                    top: LayoutConstants.SETTINGS_CHIP_PADDING_VERTICAL_VP,
                    bottom: LayoutConstants.SETTINGS_CHIP_PADDING_VERTICAL_VP
                  })
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
                  .borderRadius(LayoutConstants.SETTINGS_CHIP_RADIUS_VP)
                  .backgroundColor(this.vm.manualLanguage === AppLanguage.EN ? Color.White : Color.Transparent)
                  .shadow({
                    radius: this.selectedShadowRadius(this.vm.manualLanguage === AppLanguage.EN),
                    color: DesignTokens.SHADOW_SOFT,
                    offsetX: 0,
                    offsetY: 2
                  })
                  .onClick(() => {
                    this.vm.setManualLanguage(this.hostContext(), AppLanguage.EN);
                  })
                Text('中')
                  .fontSize(13)
                  .fontWeight(FontWeight.Medium)
                  .fontColor(this.vm.manualLanguage === AppLanguage.ZH ? DesignTokens.TEXT_MAIN :
                  DesignTokens.TEXT_MUTED)
                  .padding({
                    left: LayoutConstants.SETTINGS_CHIP_PADDING_HORIZONTAL_VP,
                    right: LayoutConstants.SETTINGS_CHIP_PADDING_HORIZONTAL_VP,
                    top: LayoutConstants.SETTINGS_CHIP_PADDING_VERTICAL_VP,
                    bottom: LayoutConstants.SETTINGS_CHIP_PADDING_VERTICAL_VP
                  })
                  .layoutWeight(1)
                  .textAlign(TextAlign.Center)
                  .borderRadius(LayoutConstants.SETTINGS_CHIP_RADIUS_VP)
                  .backgroundColor(this.vm.manualLanguage === AppLanguage.ZH ? Color.White : Color.Transparent)
                  .shadow({
                    radius: this.selectedShadowRadius(this.vm.manualLanguage === AppLanguage.ZH),
                    color: DesignTokens.SHADOW_SOFT,
                    offsetX: 0,
                    offsetY: 2
                  })
                  .onClick(() => {
                    this.vm.setManualLanguage(this.hostContext(), AppLanguage.ZH);
                  })
              }
              .width('100%')
              .margin({ top: LayoutConstants.SETTINGS_BLOCK_MARGIN_TOP_VP })
              .padding(LayoutConstants.SETTINGS_SEGMENT_INSET_VP)
              .backgroundColor(DesignTokens.SURFACE_TINTED)
              .borderRadius(LayoutConstants.SETTINGS_CARD_RADIUS_VP)
            }
            .width('100%')
            .padding({
              left: LayoutConstants.SETTINGS_SECTION_HORIZONTAL_VP,
              right: LayoutConstants.SETTINGS_SECTION_HORIZONTAL_VP,
              top: LayoutConstants.SETTINGS_SECTION_VERTICAL_VP,
              bottom: LayoutConstants.SETTINGS_SECTION_VERTICAL_VP
            })
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
                    .borderRadius(LayoutConstants.SETTINGS_CHIP_RADIUS_VP)
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
              .margin({ top: LayoutConstants.SETTINGS_BLOCK_MARGIN_TOP_VP })
            }
            .width('100%')
            .padding({
              left: LayoutConstants.SETTINGS_SECTION_HORIZONTAL_VP,
              right: LayoutConstants.SETTINGS_SECTION_HORIZONTAL_VP,
              top: LayoutConstants.SETTINGS_SECTION_VERTICAL_VP,
              bottom: LayoutConstants.SETTINGS_SECTION_VERTICAL_VP
            })
            .alignItems(HorizontalAlign.Start)
            .borderWidth({ bottom: 1 })
            .borderColor(DesignTokens.BORDER_COLOR)

            Column() {
              Text(this.vm.getUiStrings().miniPreviewStyleLabel)
                .fontSize(15)
                .fontColor(DesignTokens.TEXT_MAIN)
                .width('100%')
                .textAlign(TextAlign.Start)
                .animation({ duration: this.vm.reduceMotion ? 1 : 300, curve: Curve.EaseInOut })
              Row({ space: 12 }) {
                ForEach([MiniPreviewStyle.Capsule, MiniPreviewStyle.Hero], (style: MiniPreviewStyle) => {
                  Column({ space: 10 }) {
                    MiniPalettePreviewView({
                      colors: this.vm.getHeroColorStrings(),
                      style,
                      previewWidth: SETTINGS_MINI_PREVIEW_WIDTH,
                      previewHeight: SETTINGS_MINI_PREVIEW_HEIGHT,
                      reduceMotion: this.vm.reduceMotion
                    })

                    Text(this.miniPreviewLabel(style))
                      .fontSize(12)
                      .fontWeight(FontWeight.Medium)
                      .fontColor(this.vm.miniPreviewStyle === style ? DesignTokens.TEXT_MAIN : DesignTokens.TEXT_MUTED)
                  }
                  .layoutWeight(1)
                  .padding(LayoutConstants.SETTINGS_OPTION_CARD_PADDING_VP)
                  .alignItems(HorizontalAlign.Center)
                  .backgroundColor(this.vm.miniPreviewStyle === style ? DesignTokens.SURFACE_SUBTLE : Color.Transparent)
                  .borderRadius(LayoutConstants.SETTINGS_CARD_RADIUS_VP)
                  .border({
                    width: 1,
                    color: this.vm.miniPreviewStyle === style ? DesignTokens.TEXT_MAIN : DesignTokens.BORDER_COLOR
                  })
                  .onClick(() => {
                    this.vm.setMiniPreviewStyle(this.hostContext(), style);
                  })
                }, (style: MiniPreviewStyle) => style)
              }
              .width('100%')
              .margin({ top: LayoutConstants.SETTINGS_BLOCK_MARGIN_TOP_VP })
            }
            .width('100%')
            .padding({
              left: LayoutConstants.SETTINGS_SECTION_HORIZONTAL_VP,
              right: LayoutConstants.SETTINGS_SECTION_HORIZONTAL_VP,
              top: LayoutConstants.SETTINGS_SECTION_VERTICAL_VP,
              bottom: LayoutConstants.SETTINGS_SECTION_VERTICAL_VP
            })
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
                  this.vm.setReduceMotion(this.hostContext(), on);
                })
            }
            .width('100%')
            .padding({
              left: LayoutConstants.SETTINGS_SECTION_HORIZONTAL_VP,
              right: LayoutConstants.SETTINGS_SECTION_HORIZONTAL_VP,
              top: LayoutConstants.SETTINGS_SECTION_VERTICAL_VP,
              bottom: LayoutConstants.SETTINGS_SECTION_VERTICAL_VP
            })
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
                  this.vm.setNoiseOverlay(this.hostContext(), on);
                })
            }
            .width('100%')
            .padding({
              left: LayoutConstants.SETTINGS_SECTION_HORIZONTAL_VP,
              right: LayoutConstants.SETTINGS_SECTION_HORIZONTAL_VP,
              top: LayoutConstants.SETTINGS_SECTION_VERTICAL_VP,
              bottom: LayoutConstants.SETTINGS_SECTION_VERTICAL_VP
            })
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
            .padding({
              left: LayoutConstants.SETTINGS_SECTION_HORIZONTAL_VP,
              right: LayoutConstants.SETTINGS_SECTION_HORIZONTAL_VP,
              top: LayoutConstants.SETTINGS_SECTION_VERTICAL_VP,
              bottom: LayoutConstants.SETTINGS_SECTION_VERTICAL_VP
            })
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
            .padding({
              left: LayoutConstants.SETTINGS_SECTION_HORIZONTAL_VP,
              right: LayoutConstants.SETTINGS_SECTION_HORIZONTAL_VP,
              top: LayoutConstants.SETTINGS_SECTION_VERTICAL_VP,
              bottom: LayoutConstants.SETTINGS_SECTION_VERTICAL_VP
            })
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
        .padding(LayoutConstants.SETTINGS_PANEL_OUTER_PADDING_VP)
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
