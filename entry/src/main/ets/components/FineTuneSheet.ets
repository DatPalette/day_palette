import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';

@Component
export struct FineTuneSheet {
  @ObjectLink vm: DayPaletteViewModel;
  @Prop bottomGestureInsetVp: number = 0;
  onRequestClose: () => void = () => {
  };
  @State private mainHex: string = '';
  @State private secHex: string = '';
  @State private accHex: string = '';

  private syncFromVm(): void {
    const c: string[] = this.vm.getHeroColorStrings();
    this.mainHex = c[0];
    this.secHex = c[1];
    this.accHex = c[2];
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.35)')
        .onClick(() => {
          this.onRequestClose();
        })

      Column({ space: 16 }) {
        Text(this.vm.getUiStrings().fineTuneTitle)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .fontColor(DesignTokens.TEXT_MAIN)
          .width('100%')

        TextInput({ text: this.mainHex, placeholder: '#RRGGBB' })
          .onChange((v: string) => {
            this.mainHex = v;
          })
          .fontColor(DesignTokens.TEXT_MAIN)
        TextInput({ text: this.secHex, placeholder: '#RRGGBB' })
          .onChange((v: string) => {
            this.secHex = v;
          })
          .fontColor(DesignTokens.TEXT_MAIN)
        TextInput({ text: this.accHex, placeholder: '#RRGGBB' })
          .onChange((v: string) => {
            this.accHex = v;
          })
          .fontColor(DesignTokens.TEXT_MAIN)

        Row({ space: 12 }) {
          Button(this.vm.getUiStrings().fineTuneReset)
            .layoutWeight(1)
            .onClick(() => {
              this.vm.clearFineTune();
              this.syncFromVm();
            })
          Button(this.vm.getUiStrings().fineTuneApply)
            .layoutWeight(1)
            .onClick(() => {
              const ok: boolean = this.vm.setFineTuneHex(this.mainHex, this.secHex, this.accHex);
              if (!ok) {
                this.getUIContext().getPromptAction().showToast({
                  message: this.vm.getUiStrings().fineTuneInvalid
                });
                return;
              }
              this.onRequestClose();
            })
        }
        .width('100%')
      }
      .width('90%')
      .padding(24)
      .backgroundColor(DesignTokens.SURFACE_CARD)
      .borderRadius(12)
      .alignSelf(ItemAlign.Center)
      .margin({ bottom: 80 + this.bottomGestureInsetVp })
      .onClick(() => {
      })
      .onAppear(() => {
        this.syncFromVm();
      })
    }
    .width('100%')
    .height('100%')
  }
}
