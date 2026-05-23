// 棋盘组件

import { NumberTile } from './NumberTile';
import {
  GRID_SIZE,
  TILE_GAP,
  BOARD_PADDING,
  BOARD_BG_COLOR
} from '../common/Constants';
import { GameState } from '../model/GameModel';

@Component
export struct GameBoard {
  @Prop board: number[][] = [];
  @Prop gameState: GameState = GameState.IDLE;
  onTileClick: (row: number, col: number) => void = () => {};
  isAdjacentToEmpty: (row: number, col: number) => boolean = () => false;

  build() {
    Column() {
      ForEach(Array(GRID_SIZE).fill(0).map((_: number, i: number) => i), (row: number) => {
        Row() {
          ForEach(Array(GRID_SIZE).fill(0).map((_: number, i: number) => i), (col: number) => {
            NumberTile({
              value: this.board[row][col],
              isMovable: this.gameState === GameState.PLAYING && this.isAdjacentToEmpty(row, col),
              onTileClick: () => {
                this.onTileClick(row, col);
              }
            })
          }, (col: number) => `col_${col}`)
        }
        .justifyContent(FlexAlign.Center)
        .margin({ top: row === 0 ? 0 : TILE_GAP })
      }, (row: number) => `row_${row}`)
    }
    .padding(BOARD_PADDING)
    .borderRadius(16)
    .backgroundColor(BOARD_BG_COLOR)
    .shadow({
      radius: 12,
      color: 'rgba(0,0,0,0.4)',
      offsetX: 0,
      offsetY: 6
    })
  }
}
