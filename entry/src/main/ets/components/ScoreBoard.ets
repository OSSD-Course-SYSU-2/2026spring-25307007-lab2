// 计分板组件 - 自适应高度与字体

@Component
export struct ScoreBoard {
  @Prop moveCount: number = 0;
  @Prop formattedTime: string = '00:00';
  @Prop boardHeightPercent: string = '8%';
  @Prop labelFontSize: string = '3fp';
  @Prop valueFontSize: string = '5fp';

  build() {
    Row() {
      // 步数
      Column() {
        Text('步数')
          .fontSize(this.labelFontSize)
          .fontColor('rgba(255,255,255,0.6)')
          .margin({ bottom: '0.5%' })
        Text(`${this.moveCount}`)
          .fontSize(this.valueFontSize)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      // 分隔线
      Column()
        .width('0.2%')
        .height('60%')
        .backgroundColor('rgba(255,255,255,0.2)')

      // 时间
      Column() {
        Text('时间')
          .fontSize(this.labelFontSize)
          .fontColor('rgba(255,255,255,0.6)')
          .margin({ bottom: '0.5%' })
        Text(this.formattedTime)
          .fontSize(this.valueFontSize)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height(this.boardHeightPercent)
    .padding({ left: '3%', right: '3%' })
    .borderRadius('2.5%')
    .backgroundColor('rgba(255,255,255,0.08)')
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Center)
  }
}
