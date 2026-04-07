import { DayPaletteViewModel } from '../viewmodel/DayPaletteViewModel';
import { DesignTokens } from '../common/constants/DesignTokens';
import { hexToRgb888 } from '../export/HexColor';

@Component
export struct FineTuneSheet {
  @ObjectLink vm: DayPaletteViewModel;
  @Watch('onSyncTokenChanged') @Prop syncToken: string = '';
  @Prop bottomGestureInsetVp: number = 0;
  onRequestClose: () => void = () => {
  };
  @State private mainHex: string = '';
  @State private secHex: string = '';
  @State private accHex: string = '';
  @State private activeRoleIndex: number = 0;
  @State private history: string[] = [];

  private syncFromVm(): void {
    const colors: string[] = this.vm.getHeroColorStrings();
    this.mainHex = colors[0];
    this.secHex = colors[1];
    this.accHex = colors[2];
    this.history = [];
  }

  private onSyncTokenChanged(): void {
    this.syncFromVm();
  }

  private roleLabel(index: number): string {
    if (index === 0) {
      return this.vm.getUiStrings().main;
    }
    if (index === 1) {
      return this.vm.getUiStrings().sec;
    }
    return this.vm.getUiStrings().acc;
  }

  private currentColors(): string[] {
    return [this.mainHex, this.secHex, this.accHex];
  }

  private serializeColors(colors: string[]): string {
    return colors.join('|');
  }

  private pushHistory(): void {
    const serialized: string = this.serializeColors(this.currentColors());
    if (this.history.length > 0 && this.history[this.history.length - 1] === serialized) {
      return;
    }
    this.history.push(serialized);
    if (this.history.length > 12) {
      this.history.shift();
    }
  }

  private restoreFromSerialized(serialized: string): void {
    const parts: string[] = serialized.split('|');
    if (parts.length !== 3) {
      return;
    }
    this.mainHex = parts[0];
    this.secHex = parts[1];
    this.accHex = parts[2];
  }

  private undoLastStep(): void {
    if (this.history.length === 0) {
      return;
    }
    const serialized: string | undefined = this.history.pop();
    if (serialized !== undefined) {
      this.restoreFromSerialized(serialized);
    }
  }

  private setRoleHex(roleIndex: number, hex: string): void {
    this.pushHistory();
    if (roleIndex === 0) {
      this.mainHex = hex;
      return;
    }
    if (roleIndex === 1) {
      this.secHex = hex;
      return;
    }
    this.accHex = hex;
  }

  private activeRoleHex(): string {
    return this.currentColors()[this.activeRoleIndex];
  }

  private updateActiveRoleHex(value: string): void {
    if (this.activeRoleIndex === 0) {
      this.mainHex = value;
      return;
    }
    if (this.activeRoleIndex === 1) {
      this.secHex = value;
      return;
    }
    this.accHex = value;
  }

  private displayHex(hex: string, fallback: string): string {
    return hexToRgb888(hex) !== null ? hex : fallback;
  }

  private basePaletteColors(): string[] {
    return this.vm.getActivePaletteBaseColors();
  }

  private candidateHexes(): string[] {
    return this.vm.getFineTuneCandidateHexes(this.activeRoleIndex);
  }

  private isSelectedCandidate(hex: string): boolean {
    return this.activeRoleHex().trim().toLowerCase() === hex.trim().toLowerCase();
  }

  private resetToPalette(): void {
    const base: string[] = this.basePaletteColors();
    this.pushHistory();
    this.mainHex = base[0];
    this.secHex = base[1];
    this.accHex = base[2];
  }

  build() {
    Column({ space: 18 }) {
      Text(this.vm.getUiStrings().fineTuneTitle)
        .fontSize(20)
        .fontWeight(FontWeight.Medium)
        .fontColor(DesignTokens.TEXT_MAIN)
        .width('100%')

      Row({ space: 10 }) {
        ForEach([0, 1, 2], (index: number) => {
          Column({ space: 8 }) {
            Text(this.roleLabel(index))
              .fontSize(11)
              .fontWeight(FontWeight.Medium)
              .fontColor(index === this.activeRoleIndex ? DesignTokens.TEXT_MAIN : DesignTokens.TEXT_MUTED)

            Row()
              .width('100%')
              .height(12)
              .backgroundColor(this.displayHex(this.currentColors()[index], this.basePaletteColors()[index]))
              .borderRadius(6)
          }
          .layoutWeight(1)
          .padding({ left: 12, right: 12, top: 12, bottom: 12 })
          .backgroundColor(index === this.activeRoleIndex ? DesignTokens.SURFACE_CARD : DesignTokens.SURFACE_SUBTLE)
          .borderRadius(12)
          .border({ width: 1, color: index === this.activeRoleIndex ? DesignTokens.TEXT_MAIN : DesignTokens.BORDER_COLOR })
          .onClick(() => {
            this.activeRoleIndex = index;
          })
        })
      }
      .width('100%')

      Column({ space: 10 }) {
        Text(this.vm.getUiStrings().fineTuneSuggested)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(DesignTokens.TEXT_MAIN)
          .width('100%')

        Scroll() {
          Row({ space: 10 }) {
            ForEach(this.candidateHexes(), (hex: string) => {
              Column({ space: 6 }) {
                Row()
                  .width(44)
                  .height(44)
                  .backgroundColor(hex)
                  .borderRadius(22)
                  .border({ width: this.isSelectedCandidate(hex) ? 2 : 1, color: this.isSelectedCandidate(hex) ? DesignTokens.TEXT_MAIN : DesignTokens.BORDER_COLOR })
                  .shadow({ radius: this.isSelectedCandidate(hex) ? 10 : 0, color: DesignTokens.SHADOW_SOFT, offsetY: 3 })

                Text(hex.toUpperCase())
                  .fontSize(9)
                  .fontColor(this.isSelectedCandidate(hex) ? DesignTokens.TEXT_MAIN : DesignTokens.TEXT_MUTED)
                  .maxLines(1)
              }
              .width(52)
              .onClick(() => {
                this.setRoleHex(this.activeRoleIndex, hex);
              })
            }, (hex: string) => `${this.activeRoleIndex}_${hex}`)
          }
        }
        .scrollable(ScrollDirection.Horizontal)
        .scrollBar(BarState.Off)
        .width('100%')
      }
      .width('100%')

      Column({ space: 8 }) {
        Text(`${this.vm.getUiStrings().fineTuneManual} · ${this.roleLabel(this.activeRoleIndex)}`)
          .fontSize(12)
          .fontWeight(FontWeight.Medium)
          .fontColor(DesignTokens.TEXT_MAIN)
          .width('100%')

        TextInput({ text: this.activeRoleHex(), placeholder: '#RRGGBB' })
          .onChange((value: string) => {
            this.updateActiveRoleHex(value);
          })
          .fontColor(DesignTokens.TEXT_MAIN)
          .placeholderColor(DesignTokens.TEXT_MUTED)
          .backgroundColor(DesignTokens.SURFACE_SUBTLE)
          .borderRadius(10)
          .padding({ left: 14, right: 14, top: 12, bottom: 12 })
      }
      .width('100%')

      Row({ space: 10 }) {
        Button(this.vm.getUiStrings().fineTuneUndo)
          .enabled(this.history.length > 0)
          .opacity(this.history.length > 0 ? 1 : 0.45)
          .height(40)
          .padding({ left: 16, right: 16 })
          .backgroundColor(DesignTokens.SURFACE_SUBTLE)
          .fontColor(DesignTokens.TEXT_MAIN)
          .borderRadius(20)
          .onClick(() => {
            this.undoLastStep();
          })

        Button(this.vm.getUiStrings().fineTuneReset)
          .height(40)
          .padding({ left: 16, right: 16 })
          .backgroundColor(DesignTokens.SURFACE_SUBTLE)
          .fontColor(DesignTokens.TEXT_MAIN)
          .borderRadius(20)
          .onClick(() => {
            this.resetToPalette();
          })
      }
      .width('100%')
      .justifyContent(FlexAlign.End)

      Button(this.vm.getUiStrings().fineTuneApply)
        .width('100%')
        .height(52)
        .backgroundColor(DesignTokens.TEXT_MAIN)
        .fontColor(DesignTokens.TEXT_ON_INVERSE)
        .borderRadius(26)
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
    .padding({ left: 20, right: 20, top: 12, bottom: 24 + this.bottomGestureInsetVp })
    .backgroundColor(DesignTokens.SURFACE_CARD)
    .onAppear(() => {
      this.syncFromVm();
    })
  }
}