/// <reference path="../form/FormCardRuntime.d.ts" />

let formLocalStorage: LocalStorage = new LocalStorage();

@Entry(formLocalStorage)
@Component
struct TodayOutfitFormCard {
  @LocalStorageProp('primaryColor') primaryColor: string = '#E8D8D3';
  @LocalStorageProp('secondaryColor') secondaryColor: string = '#C5B9B6';
  @LocalStorageProp('accentColor') accentColor: string = '#5D637A';
  @LocalStorageProp('occasionLabel') occasionLabel: string = '';
  @LocalStorageProp('shortNote') shortNote: string = '';

  build() {
    Column({ space: 8 }) {
      Text('DayPalette')
        .fontSize(11)
        .fontColor('#666666')
        .width('100%')
      Row() {
        Row()
          .layoutWeight(1)
          .height(40)
          .backgroundColor(this.primaryColor)
        Row()
          .layoutWeight(1)
          .height(40)
          .backgroundColor(this.secondaryColor)
        Row()
          .layoutWeight(1)
          .height(40)
          .backgroundColor(this.accentColor)
      }
      .width('100%')
      .borderRadius(4)
      .clip(true)

      Text(this.occasionLabel)
        .fontSize(14)
        .fontWeight(FontWeight.Medium)
        .fontColor('#1a1a1a')
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
        .width('100%')

      if (this.shortNote.length > 0) {
        Text(this.shortNote)
          .fontSize(12)
          .fontColor('#8c8c8c')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
          .width('100%')
      }

      Button({ type: ButtonType.Capsule }) {
        Text('Open app')
          .fontSize(12)
          .fontColor(Color.White)
      }
      .width('100%')
      .height(32)
      .backgroundColor('#1a1a1a')
      .onClick(() => {
        postCardAction(this, {
          bundleName: 'com.wuxinbo.day_palette',
          abilityName: 'EntryAbility',
          moduleName: 'entry',
          action: 'router',
          params: {
            uri: 'pages/Index'
          }
        });
      })
    }
    .width('100%')
    .height('100%')
    .padding(12)
    .alignItems(HorizontalAlign.Start)
  }
}
