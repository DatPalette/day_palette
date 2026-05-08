import { common } from '@kit.AbilityKit';
import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';
import { LayoutConstants } from '../common/constants/LayoutConstants';
import { hexToRgb888 } from '../export/HexColor';
import type { WallpaperSnapshot } from '../export/WallpaperActions';
import { AppLanguage } from '../model/AppLanguage';
import {
  getPreparedWallpaperPreviewUri,
  releasePreparedWallpaperExport,
  wallpaperSnapshotFromVm
} from '../export/WallpaperActions';
import {
  WALLPAPER_STYLE_BLOCKS_ID,
  WALLPAPER_STYLE_COLLAGE_ID,
  WALLPAPER_STYLE_GRADIENT_ID,
  WALLPAPER_STYLE_IDS,
  WALLPAPER_STYLE_MIST_ID,
  WALLPAPER_VARIANT_IDS
} from '../export/WallpaperImageExporter';

type WallpaperPreviewMode = 'clean' | 'lockscreen';

interface PreviewStripe {
  id: string;
  color: string;
}

@Component
export struct WallpaperStudioView {
  @ObjectLink vm: DayPaletteViewModel;
  @Prop deviceWidthPx: number = 1080;
  @Prop deviceHeightPx: number = 2340;
  @Prop bottomGestureInsetVp: number = 0;
  onRequestClose: () => void = () => {
  };
  onTapSave: (snap: WallpaperSnapshot) => void = (_snap: WallpaperSnapshot) => {
  };
  @State private selectedStyleId: string = WALLPAPER_STYLE_BLOCKS_ID;
  @State private previewMode: WallpaperPreviewMode = 'clean';
  @State private heroPreviewUri: string = '';
  @State private previewLoading: boolean = false;
  private pendingPreviewRequestKey: string = '';

  private colors(): string[] {
    return this.vm.getHeroColorStrings();
  }

  private previewColor(index: number): string {
    const palette: string[] = this.colors();
    return palette[index] ?? palette[palette.length - 1] ?? '#000000';
  }

  private wallpaperAspectRatio(): number {
    const safeWidth: number = this.deviceWidthPx > 0 ? this.deviceWidthPx : 1080;
    const safeHeight: number = this.deviceHeightPx > 0 ? this.deviceHeightPx : 2340;
    return safeHeight / safeWidth;
  }

  private previewWidthVp(): number {
    return this.deviceWidthPx >= 1200 ? 224 : 206;
  }

  private previewHeightVp(): number {
    const desiredHeight: number = Math.round(this.previewWidthVp() * this.wallpaperAspectRatio());
    return Math.min(476, Math.max(396, desiredHeight));
  }

  private currentVariantId(): string {
    return WALLPAPER_VARIANT_IDS[0];
  }

  private currentStyleIndex(): number {
    const index: number = WALLPAPER_STYLE_IDS.findIndex((styleId: string) => styleId === this.selectedStyleId);
    return index >= 0 ? index : 0;
  }

  private shiftStyle(step: number): void {
    const count: number = WALLPAPER_STYLE_IDS.length;
    const nextIndex: number = (this.currentStyleIndex() + step + count) % count;
    this.selectedStyleId = WALLPAPER_STYLE_IDS[nextIndex];
    this.refreshHeroPreview();
  }

  private styleTitle(styleId: string): string {
    if (styleId === WALLPAPER_STYLE_COLLAGE_ID) {
      return this.vm.getUiStrings().wallpaperStyleCollage;
    }
    if (styleId === WALLPAPER_STYLE_GRADIENT_ID) {
      return this.vm.getUiStrings().wallpaperStyleGradient;
    }
    if (styleId === WALLPAPER_STYLE_MIST_ID) {
      return this.vm.getUiStrings().wallpaperStyleMist;
    }
    return this.vm.getUiStrings().wallpaperStyleBlocks;
  }

  private styleMood(styleId: string): string {
    if (styleId === WALLPAPER_STYLE_COLLAGE_ID) {
      return this.vm.getUiStrings().wallpaperStyleCollageMood;
    }
    if (styleId === WALLPAPER_STYLE_GRADIENT_ID) {
      return this.vm.getUiStrings().wallpaperStyleGradientMood;
    }
    if (styleId === WALLPAPER_STYLE_MIST_ID) {
      return this.vm.getUiStrings().wallpaperStyleMistMood;
    }
    return this.vm.getUiStrings().wallpaperStyleBlocksMood;
  }

  private previewLoadingLabel(): string {
    return this.vm.currentLang === AppLanguage.ZH ? '生成中' : 'Rendering';
  }

  private toHexChannel(value: number): string {
    return Math.max(0, Math.min(255, Math.round(value))).toString(16).padStart(2, '0');
  }

  private rgbToHex(r: number, g: number, b: number): string {
    return `#${this.toHexChannel(r)}${this.toHexChannel(g)}${this.toHexChannel(b)}`.toUpperCase();
  }

  private lightenHex(hex: string, amount: number): string {
    return this.lerpHex(hex, '#FFFFFF', amount);
  }

  private darkenHex(hex: string, amount: number): string {
    return this.lerpHex(hex, '#000000', amount);
  }

  private lerpHex(startHex: string, endHex: string, t: number): string {
    const start: number[] = hexToRgb888(startHex) ?? [232, 216, 211];
    const end: number[] = hexToRgb888(endHex) ?? [197, 185, 182];
    return this.rgbToHex(
      start[0] + (end[0] - start[0]) * t,
      start[1] + (end[1] - start[1]) * t,
      start[2] + (end[2] - start[2]) * t
    );
  }

  private buildGradientStripes(startHex: string, midHex: string, endHex: string): PreviewStripe[] {
    const stripes: PreviewStripe[] = [];
    for (let i: number = 0; i < 18; i++) {
      const ratio: number = i / 17;
      const color: string = ratio <= 0.5
        ? this.lerpHex(startHex, midHex, ratio / 0.5)
        : this.lerpHex(midHex, endHex, (ratio - 0.5) / 0.5);
      stripes.push({ id: `stripe_${i}`, color: color });
    }
    return stripes;
  }

  private gradientStripes(): PreviewStripe[] {
    return this.buildGradientStripes(
      this.darkenHex(this.previewColor(1), 0.56),
      this.darkenHex(this.previewColor(0), 0.44),
      this.darkenHex(this.previewColor(2), 0.76)
    );
  }

  private contentTopInsetVp(): number {
    return 42 + LayoutConstants.CHROME_ICON_BUTTON_SIZE_VP + 4;
  }

  private contentBottomInsetVp(): number {
    return 16 + this.bottomGestureInsetVp;
  }

  private previewRenderWidthPx(): number {
    return 360;
  }

  private previewRenderHeightPx(): number {
    return Math.max(720, Math.round(this.previewRenderWidthPx() * this.wallpaperAspectRatio()));
  }

  private wallpaperSnapshot(widthPx: number, heightPx: number): WallpaperSnapshot {
    return wallpaperSnapshotFromVm(
      this.vm,
      this.selectedStyleId,
      this.currentVariantId(),
      widthPx,
      heightPx
    );
  }

  private currentWallpaperSnapshot(): WallpaperSnapshot {
    return this.wallpaperSnapshot(this.deviceWidthPx, this.deviceHeightPx);
  }

  private currentWallpaperPreviewSnapshot(): WallpaperSnapshot {
    return this.wallpaperSnapshot(this.previewRenderWidthPx(), this.previewRenderHeightPx());
  }

  private getHostContext(): common.UIAbilityContext | null {
    try {
      return this.getUIContext().getHostContext() as common.UIAbilityContext;
    } catch {
      return null;
    }
  }

  private wallpaperPreviewRequestKey(snapshot: WallpaperSnapshot): string {
    return `${snapshot.mainHex}|${snapshot.secHex}|${snapshot.accHex}|${snapshot.styleId}|${snapshot.variantId}|${snapshot.widthPx}|${snapshot.heightPx}`;
  }

  private refreshHeroPreview(): void {
    const context: common.UIAbilityContext | null = this.getHostContext();
    if (context === null) {
      this.heroPreviewUri = '';
      this.previewLoading = false;
      return;
    }
    const snapshot: WallpaperSnapshot = this.currentWallpaperPreviewSnapshot();
    const requestKey: string = this.wallpaperPreviewRequestKey(snapshot);
    this.pendingPreviewRequestKey = requestKey;
    this.previewLoading = true;
    this.heroPreviewUri = '';
    setTimeout((): void => {
      if (this.pendingPreviewRequestKey !== requestKey) {
        return;
      }
      void getPreparedWallpaperPreviewUri(context, snapshot)
        .then((uri: string | null) => {
          if (this.pendingPreviewRequestKey !== requestKey) {
            return;
          }
          this.heroPreviewUri = uri ?? '';
          this.previewLoading = false;
        })
        .catch(() => {
          if (this.pendingPreviewRequestKey !== requestKey) {
            return;
          }
          this.heroPreviewUri = '';
          this.previewLoading = false;
        });
    }, 16);
  }

  private handleSave(): void {
    const snapshot: WallpaperSnapshot = this.currentWallpaperSnapshot();
    this.onTapSave(snapshot);
  }

  @Builder
  private lockscreenOverlay() {
    Column({ space: 2 }) {
      Text('09:41')
        .fontSize(28)
        .fontWeight(FontWeight.Medium)
        .fontColor('rgba(255, 255, 255, 0.92)')

      Text(this.vm.getTopBarDateLabel())
        .fontSize(11)
        .fontColor('rgba(255, 255, 255, 0.76)')
    }
    .alignItems(HorizontalAlign.Start)
  }

  @Builder
  private blocksPreview(widthVp: number, heightVp: number, variantId: string) {
    Stack() {
      Column()
        .width(widthVp)
        .height(heightVp)
        .backgroundColor(this.lightenHex(this.previewColor(0), 0.82))
        .borderRadius(18)

      Column()
        .width(widthVp * 0.76)
        .height(widthVp * 0.76)
        .backgroundColor(this.lightenHex(this.previewColor(0), 0.22))
        .borderRadius(widthVp)
        .opacity(0.78)
        .position({ top: variantId === 'variant_b' ? heightVp * 0.06 : heightVp * 0.12, left: variantId === 'variant_c' ? widthVp * 0.34 : widthVp * 0.08 })

      Column()
        .width(widthVp * 0.96)
        .height(widthVp * 0.96)
        .backgroundColor(this.lightenHex(this.previewColor(1), 0.16))
        .borderRadius(widthVp)
        .opacity(0.52)
        .position({ top: variantId === 'variant_b' ? heightVp * 0.24 : heightVp * 0.38, left: variantId === 'variant_c' ? -widthVp * 0.12 : widthVp * 0.14 })

      Column()
        .width(widthVp * 1.04)
        .height(widthVp * 1.04)
        .backgroundColor(this.lightenHex(this.previewColor(2), 0.26))
        .borderRadius(widthVp)
        .opacity(0.44)
        .position({ top: variantId === 'variant_c' ? heightVp * 0.56 : heightVp * 0.62, left: variantId === 'variant_b' ? widthVp * 0.02 : -widthVp * 0.14 })
    }
    .width(widthVp)
    .height(heightVp)
  }

  @Builder
  private collagePreview(widthVp: number, heightVp: number) {
    Stack() {
      Column()
        .width(widthVp)
        .height(heightVp)
        .backgroundColor(this.lightenHex(this.previewColor(0), 0.82))
        .borderRadius(18)

      Column()
        .width(widthVp * 0.82)
        .height(widthVp * 0.82)
        .backgroundColor(this.lightenHex(this.previewColor(0), 0.06))
        .borderRadius(widthVp)
        .opacity(0.74)
        .position({ top: heightVp * 0.16, left: widthVp * 0.06 })

      Column()
        .width(widthVp * 0.92)
        .height(widthVp * 0.92)
        .backgroundColor(this.lightenHex(this.previewColor(1), 0.08))
        .borderRadius(widthVp)
        .opacity(0.58)
        .position({ top: heightVp * 0.44, left: widthVp * 0.18 })

      Column()
        .width(widthVp * 0.42)
        .height(widthVp * 0.42)
        .backgroundColor(this.lightenHex(this.previewColor(2), 0.16))
        .borderRadius(widthVp)
        .opacity(0.38)
        .position({ top: heightVp * 0.1, left: widthVp * 0.54 })
    }
    .width(widthVp)
    .height(heightVp)
  }

  @Builder
  private gradientPreview(widthVp: number, heightVp: number, variantId: string) {
    Stack() {
      Column({ space: 0 }) {
        ForEach(this.gradientStripes(), (stripe: PreviewStripe) => {
          Row()
            .width(widthVp)
            .height(heightVp / 18)
            .backgroundColor(stripe.color)
            .translate({ x: variantId === 'variant_c' ? 5 : 0, y: 0 })
        }, (stripe: PreviewStripe) => stripe.id)
      }
      .width(widthVp)
      .height(heightVp)
      .borderRadius(18)
      .clip(true)

      Column()
        .width(widthVp * 0.7)
        .height(widthVp * 0.7)
        .backgroundColor(this.lightenHex(this.previewColor(0), 0.08))
        .borderRadius(widthVp)
        .opacity(0.52)
        .position({ top: variantId === 'variant_b' ? heightVp * 0.14 : heightVp * 0.2, left: widthVp * 0.08 })

      Column()
        .width(widthVp * 0.84)
        .height(widthVp * 0.84)
        .backgroundColor(this.lightenHex(this.previewColor(1), 0.06))
        .borderRadius(widthVp)
        .opacity(0.34)
        .position({ top: variantId === 'variant_c' ? heightVp * 0.48 : heightVp * 0.4, left: widthVp * 0.2 })

      Column()
        .width(widthVp * 0.32)
        .height(widthVp * 0.32)
        .backgroundColor(this.lightenHex(this.previewColor(2), 0.12))
        .borderRadius(widthVp)
        .opacity(0.42)
        .position({ top: heightVp * 0.12, left: widthVp * 0.66 })
    }
    .width(widthVp)
    .height(heightVp)
  }

  @Builder
  private mistPreview(widthVp: number, heightVp: number, variantId: string) {
    Stack() {
      Column()
        .width(widthVp)
        .height(heightVp)
        .backgroundColor(this.lightenHex(this.previewColor(0), 0.86))
        .borderRadius(18)

      Column()
        .width(widthVp * 1.22)
        .height(widthVp * 1.22)
        .backgroundColor(this.lightenHex(this.previewColor(1), 0.14))
        .borderRadius(widthVp)
        .opacity(0.52)
        .position({ top: variantId === 'variant_b' ? -heightVp * 0.06 : heightVp * 0.1, left: variantId === 'variant_c' ? -widthVp * 0.26 : -widthVp * 0.34 })

      Column()
        .width(widthVp * 1.18)
        .height(widthVp * 1.18)
        .backgroundColor(this.lightenHex(this.previewColor(2), 0.16))
        .borderRadius(widthVp)
        .opacity(0.46)
        .position({ top: variantId === 'variant_c' ? heightVp * 0.26 : heightVp * 0.52, left: variantId === 'variant_b' ? widthVp * 0.12 : widthVp * 0.28 })

      Column()
        .width(widthVp * 1.04)
        .height(widthVp * 1.04)
        .backgroundColor(this.lightenHex(this.previewColor(0), 0.2))
        .borderRadius(widthVp)
        .opacity(0.22)
        .position({ top: -heightVp * 0.12, left: widthVp * 0.32 })
    }
    .width(widthVp)
    .height(heightVp)
  }

  @Builder
  private stylePreview(widthVp: number, heightVp: number, styleId: string, variantId: string, showLockscreenOverlay: boolean) {
    Stack() {
      if (styleId === WALLPAPER_STYLE_COLLAGE_ID) {
        this.collagePreview(widthVp, heightVp)
      } else if (styleId === WALLPAPER_STYLE_GRADIENT_ID) {
        this.gradientPreview(widthVp, heightVp, variantId)
      } else if (styleId === WALLPAPER_STYLE_MIST_ID) {
        this.mistPreview(widthVp, heightVp, variantId)
      } else {
        this.blocksPreview(widthVp, heightVp, variantId)
      }

      if (showLockscreenOverlay) {
        Column() {
          this.lockscreenOverlay()
        }
        .position({ top: 20, left: 18 })
      }
    }
    .width(widthVp)
    .height(heightVp)
  }

  @Builder
  private heroPreview() {
    Stack() {
      if (this.previewLoading) {
        Column()
          .width(this.previewWidthVp())
          .height(this.previewHeightVp())
          .backgroundColor('#f2efe9')
          .borderRadius(18)

        Column({ space: 6 }) {
          Text(this.previewLoadingLabel())
            .fontSize(12)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_MUTED)
          Text('...')
            .fontSize(18)
            .fontColor(DesignTokens.TEXT_MUTED)
        }
        .width(this.previewWidthVp())
        .height(this.previewHeightVp())
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      } else if (this.heroPreviewUri.length > 0) {
        Image(this.heroPreviewUri)
          .width(this.previewWidthVp())
          .height(this.previewHeightVp())
          .objectFit(ImageFit.Cover)
          .borderRadius(18)
      } else {
        this.stylePreview(
          this.previewWidthVp(),
          this.previewHeightVp(),
          this.selectedStyleId,
          this.currentVariantId(),
          false
        )
      }

      if (this.previewMode === 'lockscreen' && !this.previewLoading) {
        Column() {
          this.lockscreenOverlay()
        }
        .position({ top: 20, left: 18 })
      }
    }
    .width(this.previewWidthVp())
    .height(this.previewHeightVp())
  }

  @Builder
  private styleArrowButton(symbol: string, step: number) {
    Button({ type: ButtonType.Circle, stateEffect: true }) {
      Text(symbol)
        .fontSize(24)
        .fontColor(DesignTokens.TEXT_MAIN)
        .fontWeight(FontWeight.Medium)
    }
    .width(44)
    .height(44)
    .backgroundColor('rgba(255, 255, 255, 0.92)')
    .border({ width: 1, color: DesignTokens.BORDER_COLOR })
    .shadow({ radius: 10, color: 'rgba(0, 0, 0, 0.03)', offsetY: 4 })
    .onClick(() => {
      this.shiftStyle(step);
    })
  }

  @Builder
  private styleIndicatorDots() {
    Row({ space: 8 }) {
      ForEach(WALLPAPER_STYLE_IDS, (styleId: string) => {
        Blank()
          .width(this.selectedStyleId === styleId ? 18 : 6)
          .height(6)
          .borderRadius(999)
          .backgroundColor(this.selectedStyleId === styleId ? DesignTokens.TEXT_MAIN : 'rgba(28, 28, 28, 0.16)')
      }, (styleId: string) => styleId)
    }
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
  }

  build() {
    Stack({ alignContent: Alignment.TopStart }) {
      Column() {
        Blank()
          .height(this.contentTopInsetVp())

        Column() {
          Column({ space: 6 }) {
            Text(this.styleTitle(this.selectedStyleId))
              .fontSize(24)
              .fontWeight(FontWeight.Medium)
              .fontColor(DesignTokens.TEXT_MAIN)
              .width('100%')

            Text(this.styleMood(this.selectedStyleId))
              .fontSize(13)
              .fontColor(DesignTokens.TEXT_MUTED)
              .lineHeight(20)
              .width('100%')
          }
          .width('100%')
          .alignItems(HorizontalAlign.Start)
          .padding({ left: LayoutConstants.PAGE_HORIZONTAL_VP, right: LayoutConstants.PAGE_HORIZONTAL_VP })

          Row() {
            Stack({ alignContent: Alignment.Center }) {
              this.heroPreview()

              Row() {
                this.styleArrowButton('‹', -1)

                Blank()
                  .layoutWeight(1)

                this.styleArrowButton('›', 1)
              }
              .width('100%')
              .alignItems(VerticalAlign.Center)
            }
            .width('100%')
            .padding({ left: 14, right: 14 })
          }
          .width('100%')
          .layoutWeight(1)
          .justifyContent(FlexAlign.Center)
          .alignItems(VerticalAlign.Center)

          Row() {
            this.styleIndicatorDots()
          }
          .width('100%')
          .justifyContent(FlexAlign.Center)
          .padding({ top: 6, bottom: 18 })

          Row({ space: 12 }) {
            Button(this.vm.getUiStrings().wallpaperPreviewClean)
              .layoutWeight(1)
              .height(42)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.previewMode === 'clean' ? DesignTokens.TEXT_ON_INVERSE : DesignTokens.TEXT_MAIN)
              .backgroundColor(this.previewMode === 'clean' ? DesignTokens.TEXT_MAIN : Color.White)
              .borderRadius(999)
              .border({ width: 1, color: this.previewMode === 'clean' ? DesignTokens.TEXT_MAIN : DesignTokens.BORDER_COLOR })
              .onClick(() => {
                this.previewMode = 'clean';
              })

            Button(this.vm.getUiStrings().wallpaperPreviewLockscreen)
              .layoutWeight(1)
              .height(42)
              .fontSize(13)
              .fontWeight(FontWeight.Medium)
              .fontColor(this.previewMode === 'lockscreen' ? DesignTokens.TEXT_ON_INVERSE : DesignTokens.TEXT_MAIN)
              .backgroundColor(this.previewMode === 'lockscreen' ? DesignTokens.TEXT_MAIN : Color.White)
              .borderRadius(999)
              .border({ width: 1, color: this.previewMode === 'lockscreen' ? DesignTokens.TEXT_MAIN : DesignTokens.BORDER_COLOR })
              .onClick(() => {
                this.previewMode = 'lockscreen';
              })
          }
          .width('100%')
          .padding({ left: LayoutConstants.PAGE_HORIZONTAL_VP, right: LayoutConstants.PAGE_HORIZONTAL_VP })
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.Start)
        .alignItems(HorizontalAlign.Start)
        .padding({
          top: 6,
          bottom: this.contentBottomInsetVp()
        })
      }
      .width('100%')
      .height('100%')
      .alignItems(HorizontalAlign.Start)

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

        Blank()
          .layoutWeight(1)

        Button(this.vm.getUiStrings().wallpaperSave)
          .height(LayoutConstants.CHROME_ICON_BUTTON_SIZE_VP)
          .padding({ left: 12, right: 12 })
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(DesignTokens.TEXT_ON_INVERSE)
          .backgroundColor(DesignTokens.TEXT_MAIN)
          .borderRadius(999)
          .border({ width: 1, color: DesignTokens.TEXT_MAIN })
          .onClick(() => {
            this.handleSave();
          })
      }
      .width('100%')
      .padding({ top: 42, left: 8, right: LayoutConstants.PAGE_HORIZONTAL_VP, bottom: 16 })
      .alignItems(VerticalAlign.Center)
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP])
      .position({ top: 0, left: 0 })
      .zIndex(10)
    }
    .width('100%')
    .height('100%')
    .backgroundColor(DesignTokens.BG_PAGE)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.BOTTOM])
    .onAppear(() => {
      this.refreshHeroPreview();
    })
    .onDisAppear(() => {
      releasePreparedWallpaperExport();
    })
  }
}