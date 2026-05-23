// 数字块组件

import {
  TILE_SIZE,
  TILE_BORDER_RADIUS,
  TILE_FONT_SIZE,
  TILE_GRADIENT_COLORS,
  EMPTY_TILE
} from '../common/Constants';

@Component
export struct NumberTile {
  @Prop value: number = 0;
  @Prop isMovable: boolean = false;
  onTileClick: () => void = () => {};

  build() {
    if (this.value !== EMPTY_TILE) {
      Column() {
        Text(`${this.value}`)
          .fontSize(TILE_FONT_SIZE)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .textAlign(TextAlign.Center)
      }
      .width(TILE_SIZE)
      .height(TILE_SIZE)
      .borderRadius(TILE_BORDER_RADIUS)
      .linearGradient({
        direction: GradientDirection.Bottom,
        colors: this.getGradientColors()
      })
      .shadow({
        radius: this.isMovable ? 8 : 4,
        color: this.isMovable ? 'rgba(0,0,0,0.3)' : 'rgba(0,0,0,0.15)',
        offsetX: 0,
        offsetY: this.isMovable ? 4 : 2
      })
      .opacity(this.isMovable ? 1.0 : 0.85)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .onClick(() => {
        if (this.isMovable) {
          this.onTileClick();
        }
      })
      .animation({
        duration: 100,
        curve: Curve.EaseOut
      })
    } else {
      // 空格占位
      Column()
        .width(TILE_SIZE)
        .height(TILE_SIZE)
        .borderRadius(TILE_BORDER_RADIUS)
        .backgroundColor('rgba(255,255,255,0.05)')
    }
  }
  // 根据数字值获取渐变色
  private getGradientColors(): Array<[string, number]> {
    const colorGroup = TILE_GRADIENT_COLORS;
    const groupIndex = Math.floor((this.value - 1) / 4) % colorGroup.length;
    const colors = colorGroup[groupIndex];
    return [
      [colors[0], 0.0],
      [colors[1], 1.0]
    ];
  }
}
