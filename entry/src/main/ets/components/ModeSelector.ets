// 模式选择组件

import {
  GameMode,
  MODE_SELECTOR_WIDTH,
  MODE_SELECTOR_HEIGHT,
  MODE_SELECTOR_FONT_SIZE,
  MODE_NORMAL_TEXT,
  MODE_HARD_TEXT
} from '../common/Constants';

@Component
export struct ModeSelector {
  @Prop currentMode: GameMode = GameMode.NORMAL;
  @Prop selectorWidth: string = MODE_SELECTOR_WIDTH;
  @Prop selectorHeight: string = MODE_SELECTOR_HEIGHT;
  @Prop fontSize: string = MODE_SELECTOR_FONT_SIZE;
  onModeChange: (mode: GameMode) => void = () => {};

  build() {
    Row() {
      // 普通模式按钮
      Text(MODE_NORMAL_TEXT)
        .fontSize(this.fontSize)
        .fontColor(this.currentMode === GameMode.NORMAL ? Color.White : '#AAAAAA')
        .fontWeight(this.currentMode === GameMode.NORMAL ? FontWeight.Bold : FontWeight.Normal)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .padding({ left: '2vp', right: '2vp', top: '1vp', bottom: '1vp' })
        .borderRadius('4vp')
        .backgroundColor(this.currentMode === GameMode.NORMAL ? '#4facfe' : 'rgba(255,255,255,0.1)')
        .onClick(() => {
          if (this.currentMode !== GameMode.NORMAL) {
            this.onModeChange(GameMode.NORMAL);
          }
        })

      // 分隔符
      Text('|')
        .fontSize(this.fontSize)
        .fontColor('#666666')
        .margin({ left: '1vp', right: '1vp' })

      // 困难模式按钮
      Text(MODE_HARD_TEXT)
        .fontSize(this.fontSize)
        .fontColor(this.currentMode === GameMode.HARD ? Color.White : '#AAAAAA')
        .fontWeight(this.currentMode === GameMode.HARD ? FontWeight.Bold : FontWeight.Normal)
        .layoutWeight(1)
        .textAlign(TextAlign.Center)
        .padding({ left: '2vp', right: '2vp', top: '1vp', bottom: '1vp' })
        .borderRadius('4vp')
        .backgroundColor(this.currentMode === GameMode.HARD ? '#fa709a' : 'rgba(255,255,255,0.1)')
        .onClick(() => {
          if (this.currentMode !== GameMode.HARD) {
            this.onModeChange(GameMode.HARD);
          }
        })
    }
    .width(this.selectorWidth)
    .height(this.selectorHeight)
    .justifyContent(FlexAlign.Center)
    .alignItems(VerticalAlign.Center)
    .borderRadius('4vp')
    .backgroundColor('rgba(255,255,255,0.05)')
    .padding({ left: '2vp', right: '2vp' })
  }
}
