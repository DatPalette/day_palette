import { DesignTokens } from '../common/constants/DesignTokens';
import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { SmartMatchResultsView } from './SmartMatchResultsView';

@Component
export struct SmartMatchSheet {
  @ObjectLink vm: DayPaletteViewModel;
  @Prop bottomGestureInsetVp: number = 0;
  @State private visible: boolean = false;
  @State private closing: boolean = false;
  onRequestClose: () => void = () => {
  };

  private openAnimDuration(): number {
    return this.vm.reduceMotion ? 1 : 420;
  }

  private maskAnimDuration(): number {
    return this.vm.reduceMotion ? 1 : 220;
  }

  private closeWithAnimation(): void {
    if (this.closing) {
      return;
    }
    this.closing = true;
    this.visible = false;
    setTimeout((): void => {
      this.closing = false;
      this.onRequestClose();
    }, this.openAnimDuration());
  }

  build() {
    Stack({ alignContent: Alignment.Bottom }) {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.35)')
        .opacity(this.visible ? 1 : 0)
        .animation({ duration: this.maskAnimDuration(), curve: Curve.EaseInOut })
        .onClick(() => {
          this.closeWithAnimation();
        })

      Column({ space: 16 }) {
        Column({ space: 10 }) {
          Row()
            .width(44)
            .height(4)
            .borderRadius(2)
            .backgroundColor('rgba(0,0,0,0.12)')

          Text(this.vm.getUiStrings().smartMatchTitle)
            .fontSize(18)
            .fontWeight(FontWeight.Medium)
            .fontColor(DesignTokens.TEXT_MAIN)
            .width('100%')
            .textAlign(TextAlign.Start)

          Text(this.vm.getUiStrings().smartMatchHint)
            .fontSize(12)
            .fontColor(DesignTokens.TEXT_MUTED)
            .lineHeight(18)
            .width('100%')
            .textAlign(TextAlign.Start)
        }
        .width('100%')
        .alignItems(HorizontalAlign.Start)

        Scroll() {
          SmartMatchResultsView({ vm: this.vm, showHeader: false })
        }
        .width('100%')
        .layoutWeight(1)
        .scrollBar(BarState.Off)
      }
      .width('100%')
      .height('68%')
      .padding({ left: 20, right: 20, top: 14, bottom: 20 + this.bottomGestureInsetVp })
      .backgroundColor(DesignTokens.BG_PAGE)
      .borderRadius({ topLeft: 24, topRight: 24, bottomLeft: 0, bottomRight: 0 })
      .shadow({ radius: 20, color: 'rgba(0, 0, 0, 0.12)', offsetX: 0, offsetY: -4 })
      .translate({ x: 0, y: this.visible ? 0 : 56 })
      .scale({ x: this.visible ? 1 : 0.985, y: this.visible ? 1 : 0.985 })
      .opacity(this.visible ? 1 : 0.94)
      .animation({ duration: this.openAnimDuration(), curve: Curve.EaseInOut })
      .onClick(() => {
      })
      .onAppear(() => {
        this.visible = true;
      })
    }
    .width('100%')
    .height('100%')
  }
}