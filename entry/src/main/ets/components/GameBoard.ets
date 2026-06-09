// 棋盘组件 - Column+Row弹性布局，4x4格局，全设备自适应

import { NumberTile } from './NumberTile';
import {
  GRID_SIZE,
  BOARD_BG_COLOR
} from '../common/Constants';
import { GameState } from '../model/GameModel';

@Component
export struct GameBoard {
  @Prop board: number[][] = [];
  @Prop gameState: GameState = GameState.IDLE;
  @Prop tileFontSize: string = '6fp';
  @Prop boardPadding: string = '3%';
  onTileClick: (row: number, col: number) => void = () => {};
  isAdjacentToEmpty: (row: number, col: number) => boolean = () => false;

  build() {
    Column({ space: 0 }) {
      ForEach(Array(GRID_SIZE).fill(0).map((_: number, i: number) => i), (row: number) => {
        Row({ space: 0 }) {
          ForEach(Array(GRID_SIZE).fill(0).map((_: number, i: number) => i), (col: number) => {
            NumberTile({
              value: this.board[row][col],
              isMovable: this.gameState === GameState.PLAYING && this.isAdjacentToEmpty(row, col),
              tileFontSize: this.tileFontSize,
              onTileClick: () => {
                this.onTileClick(row, col);
              }
            })
          }, (col: number) => `col_${col}`)
        }
        .width('100%')
        .layoutWeight(1)
        .justifyContent(FlexAlign.SpaceEvenly)
        .alignItems(VerticalAlign.Center)
      }, (row: number) => `row_${row}`)
    }
    .width('100%')
    .aspectRatio(1)
    .padding(this.boardPadding)
    .borderRadius('2%')
    .backgroundColor(BOARD_BG_COLOR)
    .shadow({
      radius: 12,
      color: 'rgba(0,0,0,0.4)',
      offsetX: 0,
      offsetY: 6
    })
  }
}
