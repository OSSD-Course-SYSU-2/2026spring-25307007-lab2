// 数字华容道 - 游戏主页面

import { GameViewModel, MoveDirection, GameViewState } from '../viewmodel/GameViewModel';
import { GameBoard } from '../components/GameBoard';
import { ScoreBoard } from '../components/ScoreBoard';
import { VictoryDialog } from '../components/VictoryDialog';
import { GameState } from '../model/GameModel';
import {
  BG_COLOR_START,
  BG_COLOR_END,
  TITLE_TEXT,
  TITLE_FONT_SIZE,
  BTN_NEW_GAME
} from '../common/Constants';

@Entry
@Component
struct Index {
  // 游戏视图状态
  @State viewState: GameViewState = new GameViewState();
  @State showVictory: boolean = false;

  // ViewModel（非响应式，通过回调更新状态）
  private viewModel: GameViewModel = new GameViewModel((state: GameViewState) => {
    this.viewState = state;
  });

  // 滑动相关
  private touchStartX: number = 0;
  private touchStartY: number = 0;
  private readonly SWIPE_THRESHOLD: number = 30;

  aboutToAppear(): void {
    this.viewModel.startNewGame();
  }

  aboutToDisappear(): void {
    this.viewModel.stopTimer();
  }

  build() {
    Stack() {
      // 背景渐变
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [
            [BG_COLOR_START, 0.0],
            [BG_COLOR_END, 1.0]
          ]
        })

      // 主内容
      Column() {
        // 标题
        Text(TITLE_TEXT)
          .fontSize(TITLE_FONT_SIZE)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 40, bottom: 20 })
          .textShadow({
            radius: 4,
            color: 'rgba(78,205,196,0.3)',
            offsetX: 0,
            offsetY: 2
          })

        // 计分板
        ScoreBoard({
          moveCount: this.viewState.moveCount,
          formattedTime: this.viewState.formattedTime
        })
          .margin({ bottom: 20 })

        // 棋盘
        GameBoard({
          board: this.viewState.board,
          gameState: this.viewState.gameState,
          onTileClick: (row: number, col: number) => {
            this.handleTileClick(row, col);
          },
          isAdjacentToEmpty: (row: number, col: number) => {
            return this.viewModel.isAdjacentToEmpty(row, col);
          }
        })
          .margin({ bottom: 24 })

        // 新游戏按钮
        Button(BTN_NEW_GAME)
          .width(140)
          .height(44)
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .backgroundColor('rgba(255,255,255,0.15)')
          .borderRadius(22)
          .border({ width: 1, color: 'rgba(255,255,255,0.2)' })
          .onClick(() => {
            this.showVictory = false;
            this.viewModel.startNewGame();
          })
      }
      .width('100%')
      .height('100%')
      .justifyContent(FlexAlign.Start)
      .alignItems(HorizontalAlign.Center)
      .onTouch((event: TouchEvent) => {
        this.handleTouch(event);
      })

      // 胜利弹窗
      if (this.showVictory) {
        VictoryDialog({
          moveCount: this.viewState.moveCount,
          formattedTime: this.viewState.formattedTime,
          onRestart: () => {
            this.showVictory = false;
            this.viewModel.startNewGame();
          },
          onClose: () => {
            this.showVictory = false;
          }
        })
      }
    }
    .width('100%')
    .height('100%')
  }

  // 处理数字块点击
  private handleTileClick(row: number, col: number): void {
    const result = this.viewModel.moveTile(row, col);
    if (result.moved && result.won) {
      setTimeout(() => {
        this.showVictory = true;
      }, 300);
    }
  }

  // 处理触摸事件（滑动交互）
  private handleTouch(event: TouchEvent): void {
    const touch = event.touches[0];
    if (event.type === TouchType.Down) {
      this.touchStartX = touch.x;
      this.touchStartY = touch.y;
    } else if (event.type === TouchType.Up) {
      const dx = touch.x - this.touchStartX;
      const dy = touch.y - this.touchStartY;
      const absDx = Math.abs(dx);
      const absDy = Math.abs(dy);

      if (absDx < this.SWIPE_THRESHOLD && absDy < this.SWIPE_THRESHOLD) {
        return;
      }

      let direction: MoveDirection;
      if (absDx > absDy) {
        direction = dx > 0 ? MoveDirection.RIGHT : MoveDirection.LEFT;
      } else {
        direction = dy > 0 ? MoveDirection.DOWN : MoveDirection.UP;
      }

      const result = this.viewModel.swipeMove(direction);
      if (result.moved && result.won) {
        setTimeout(() => {
          this.showVictory = true;
        }, 300);
      }
    }
  }
}
