// 计分板组件

import {
  SCORE_LABEL_FONT_SIZE,
  SCORE_VALUE_FONT_SIZE
} from '../common/Constants';

@Component
export struct ScoreBoard {
  @Prop moveCount: number = 0;
  @Prop formattedTime: string = '00:00';

  build() {
    Row() {
      // 步数
      Column() {
        Text('步数')
          .fontSize(SCORE_LABEL_FONT_SIZE)
          .fontColor('rgba(255,255,255,0.6)')
          .margin({ bottom: 4 })
        Text(`${this.moveCount}`)
          .fontSize(SCORE_VALUE_FONT_SIZE)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)

      // 分隔线
      Column()
        .width(1)
        .height(40)
        .backgroundColor('rgba(255,255,255,0.2)')

      // 时间
      Column() {
        Text('时间')
          .fontSize(SCORE_LABEL_FONT_SIZE)
          .fontColor('rgba(255,255,255,0.6)')
          .margin({ bottom: 4 })
        Text(this.formattedTime)
          .fontSize(SCORE_VALUE_FONT_SIZE)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Center)
    }
    .width('100%')
    .height(70)
    .padding({ left: 16, right: 16 })
    .borderRadius(12)
    .backgroundColor('rgba(255,255,255,0.08)')
    .justifyContent(FlexAlign.SpaceEvenly)
    .alignItems(VerticalAlign.Center)
  }
}
