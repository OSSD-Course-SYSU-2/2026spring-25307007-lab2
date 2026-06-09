// 数字华容道 - 游戏主页面（全设备自适应）

import { GameViewModel, MoveDirection, GameViewState } from '../viewmodel/GameViewModel';
import { GameBoard } from '../components/GameBoard';
import { ScoreBoard } from '../components/ScoreBoard';
import { VictoryDialog } from '../components/VictoryDialog';
import { GameState } from '../model/GameModel';
import {
  BG_COLOR_START,
  BG_COLOR_END,
  TITLE_TEXT,
  BTN_NEW_GAME
} from '../common/Constants';
import { ConfigurationConstant, Configuration } from '@kit.AbilityKit';

// 设备信息接口定义
interface DeviceInfo {
  deviceType?: string;
}

@Entry
@Component
struct Index {
  // 游戏视图状态
  @State viewState: GameViewState = new GameViewState();
  @State showVictory: boolean = false;

  // 设备类型与横竖屏状态
  @State deviceCategory: string = 'phone';
  @State isLandscape: boolean = false;

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
    this.detectDeviceType();
  }

  aboutToDisappear(): void {
    this.viewModel.stopTimer();
  }

  // 配置变化回调（横竖屏切换、设备类型变化时系统触发）
  onConfigurationUpdate(newConfig: Configuration): void {
    if (newConfig.direction !== undefined) {
      this.isLandscape = newConfig.direction === ConfigurationConstant.Direction.DIRECTION_HORIZONTAL;
    }
  }

  // 检测设备类型
  private detectDeviceType(): void {
    try {
      // 动态访问 deviceInfo，避免 import 预览器不支持的 Kit
      const devInfo = globalThis.deviceInfo as DeviceInfo;
      if (devInfo && devInfo.deviceType) {
        this.deviceCategory = devInfo.deviceType;
      }
    } catch (e) {
      this.deviceCategory = 'phone';
    }
  }

  // ========== 各设备布局参数计算 ==========

  private getBoardWidthPercent(): string {
    if (this.deviceCategory === 'wearable') return '90%';
    if (this.deviceCategory === 'tv') return this.isLandscape ? '50%' : '70%';
    if (this.deviceCategory === 'tablet') return this.isLandscape ? '55%' : '80%';
    return '90%';
  }

  private getTitleFontSize(): string {
    if (this.deviceCategory === 'wearable') return '4fp';
    if (this.deviceCategory === 'tv') return '8fp';
    if (this.deviceCategory === 'tablet') return '7fp';
    return '7fp';
  }

  private getScoreBoardHeight(): string {
    if (this.deviceCategory === 'wearable') return '6%';
    if (this.deviceCategory === 'tv') return '6%';
    return '8%';
  }

  private getBtnWidth(): string {
    if (this.deviceCategory === 'wearable') return '50%';
    if (this.deviceCategory === 'tv') return '25%';
    if (this.deviceCategory === 'tablet') return '30%';
    return '35%';
  }

  private getBtnHeight(): string {
    if (this.deviceCategory === 'wearable') return '8%';
    return '6%';
  }

  private getBtnFontSize(): string {
    if (this.deviceCategory === 'wearable') return '3fp';
    if (this.deviceCategory === 'tv') return '4fp';
    return '3.5fp';
  }

  private getTileFontSize(): string {
    if (this.deviceCategory === 'wearable') return '4fp';
    if (this.deviceCategory === 'tv') return '7fp';
    if (this.deviceCategory === 'tablet') return '6fp';
    return '6fp';
  }

  private getScoreLabelFontSize(): string {
    if (this.deviceCategory === 'wearable') return '2fp';
    return '3fp';
  }

  private getScoreValueFontSize(): string {
    if (this.deviceCategory === 'wearable') return '3.5fp';
    return '5fp';
  }

  private getBoardPadding(): string {
    if (this.deviceCategory === 'wearable') return '2%';
    if (this.deviceCategory === 'tv') return '2%';
    return '3%';
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

      if (this.deviceCategory === 'wearable') {
        this.buildWearableLayout()
      } else if (this.deviceCategory === 'tv') {
        this.buildTvLayout()
      } else if (this.deviceCategory === 'tablet') {
        this.buildTabletLayout()
      } else {
        this.buildPhoneLayout()
      }

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

  // ========== wearable 精简布局 ==========
  @Builder
  buildWearableLayout() {
    Column() {
      Text(`步数: ${this.viewState.moveCount}`)
        .fontSize(this.getScoreValueFontSize())
        .fontColor('rgba(255,255,255,0.8)')
        .fontWeight(FontWeight.Bold)
        .margin({ top: '5%', bottom: '2%' })

      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        GameBoard({
          board: this.viewState.board,
          gameState: this.viewState.gameState,
          tileFontSize: this.getTileFontSize(),
          boardPadding: this.getBoardPadding(),
          onTileClick: (row: number, col: number) => {
            this.handleTileClick(row, col);
          },
          isAdjacentToEmpty: (row: number, col: number) => {
            return this.viewModel.isAdjacentToEmpty(row, col);
          }
        })
      }
      .width(this.getBoardWidthPercent())
      .margin({ bottom: '2%' })

      Button(BTN_NEW_GAME)
        .width(this.getBtnWidth())
        .height(this.getBtnHeight())
        .fontSize(this.getBtnFontSize())
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('rgba(255,255,255,0.15)')
        .borderRadius('4vp')
        .onClick(() => {
          this.showVictory = false;
          this.viewModel.startNewGame();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onTouch((event: TouchEvent) => {
      this.handleTouch(event);
    })
  }

  // ========== TV 宽屏布局 ==========
  @Builder
  buildTvLayout() {
    Column() {
      Text(TITLE_TEXT)
        .fontSize(this.getTitleFontSize())
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .margin({ top: '3%', bottom: '1.5%' })
        .textShadow({
          radius: 4,
          color: 'rgba(78,205,196,0.3)',
          offsetX: 0,
          offsetY: 2
        })
        .maxLines(1)

      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        ScoreBoard({
          moveCount: this.viewState.moveCount,
          formattedTime: this.viewState.formattedTime,
          boardHeightPercent: this.getScoreBoardHeight(),
          labelFontSize: this.getScoreLabelFontSize(),
          valueFontSize: this.getScoreValueFontSize()
        })
      }
      .width('60%')
      .margin({ bottom: '1.5%' })

      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        GameBoard({
          board: this.viewState.board,
          gameState: this.viewState.gameState,
          tileFontSize: this.getTileFontSize(),
          boardPadding: this.getBoardPadding(),
          onTileClick: (row: number, col: number) => {
            this.handleTileClick(row, col);
          },
          isAdjacentToEmpty: (row: number, col: number) => {
            return this.viewModel.isAdjacentToEmpty(row, col);
          }
        })
      }
      .width(this.getBoardWidthPercent())
      .margin({ bottom: '2%' })

      Button(BTN_NEW_GAME)
        .width(this.getBtnWidth())
        .height(this.getBtnHeight())
        .fontSize(this.getBtnFontSize())
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('rgba(255,255,255,0.15)')
        .borderRadius('5vp')
        .border({ width: 1, color: 'rgba(255,255,255,0.2)' })
        .onClick(() => {
          this.showVictory = false;
          this.viewModel.startNewGame();
        })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .onTouch((event: TouchEvent) => {
      this.handleTouch(event);
    })
  }

  // ========== 平板布局（横竖屏自适应）==========
  @Builder
  buildTabletLayout() {
    if (this.isLandscape) {
      Row() {
        Column() {
          GameBoard({
            board: this.viewState.board,
            gameState: this.viewState.gameState,
            tileFontSize: this.getTileFontSize(),
            boardPadding: this.getBoardPadding(),
            onTileClick: (row: number, col: number) => {
              this.handleTileClick(row, col);
            },
            isAdjacentToEmpty: (row: number, col: number) => {
              return this.viewModel.isAdjacentToEmpty(row, col);
            }
          })
        }
        .width('55%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)

        Column() {
          Text(TITLE_TEXT)
            .fontSize(this.getTitleFontSize())
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .margin({ bottom: '3%' })
            .textShadow({
              radius: 4,
              color: 'rgba(78,205,196,0.3)',
              offsetX: 0,
              offsetY: 2
            })

          ScoreBoard({
            moveCount: this.viewState.moveCount,
            formattedTime: this.viewState.formattedTime,
            boardHeightPercent: this.getScoreBoardHeight(),
            labelFontSize: this.getScoreLabelFontSize(),
            valueFontSize: this.getScoreValueFontSize()
          })
            .width('80%')
            .margin({ bottom: '5%' })

          Button(BTN_NEW_GAME)
            .width(this.getBtnWidth())
            .height(this.getBtnHeight())
            .fontSize(this.getBtnFontSize())
            .fontColor(Color.White)
            .fontWeight(FontWeight.Bold)
            .backgroundColor('rgba(255,255,255,0.15)')
            .borderRadius('5vp')
            .border({ width: 1, color: 'rgba(255,255,255,0.2)' })
            .onClick(() => {
              this.showVictory = false;
              this.viewModel.startNewGame();
            })
        }
        .width('45%')
        .height('100%')
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }
      .width('100%')
      .height('100%')
      .onTouch((event: TouchEvent) => {
        this.handleTouch(event);
      })
    } else {
      Column() {
        Text(TITLE_TEXT)
          .fontSize(this.getTitleFontSize())
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .margin({ top: '4%', bottom: '2%' })
          .textShadow({
            radius: 4,
            color: 'rgba(78,205,196,0.3)',
            offsetX: 0,
            offsetY: 2
          })

        Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
          ScoreBoard({
            moveCount: this.viewState.moveCount,
            formattedTime: this.viewState.formattedTime,
            boardHeightPercent: this.getScoreBoardHeight(),
            labelFontSize: this.getScoreLabelFontSize(),
            valueFontSize: this.getScoreValueFontSize()
          })
        }
        .width('85%')
        .margin({ bottom: '2%' })

        Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
          GameBoard({
            board: this.viewState.board,
            gameState: this.viewState.gameState,
            tileFontSize: this.getTileFontSize(),
            boardPadding: this.getBoardPadding(),
            onTileClick: (row: number, col: number) => {
              this.handleTileClick(row, col);
            },
            isAdjacentToEmpty: (row: number, col: number) => {
              return this.viewModel.isAdjacentToEmpty(row, col);
            }
          })
        }
        .width(this.getBoardWidthPercent())
        .margin({ bottom: '2%' })

        Button(BTN_NEW_GAME)
          .width(this.getBtnWidth())
          .height(this.getBtnHeight())
          .fontSize(this.getBtnFontSize())
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .backgroundColor('rgba(255,255,255,0.15)')
          .borderRadius('5vp')
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
    }
  }

  // ========== 手机布局 ==========
  @Builder
  buildPhoneLayout() {
    Column() {
      Text(TITLE_TEXT)
        .fontSize(this.getTitleFontSize())
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .margin({ top: '5%', bottom: '2%' })
        .textShadow({
          radius: 4,
          color: 'rgba(78,205,196,0.3)',
          offsetX: 0,
          offsetY: 2
        })

      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        ScoreBoard({
          moveCount: this.viewState.moveCount,
          formattedTime: this.viewState.formattedTime,
          boardHeightPercent: this.getScoreBoardHeight(),
          labelFontSize: this.getScoreLabelFontSize(),
          valueFontSize: this.getScoreValueFontSize()
        })
      }
      .width('90%')
      .margin({ bottom: '2%' })

      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        GameBoard({
          board: this.viewState.board,
          gameState: this.viewState.gameState,
          tileFontSize: this.getTileFontSize(),
          boardPadding: this.getBoardPadding(),
          onTileClick: (row: number, col: number) => {
            this.handleTileClick(row, col);
          },
          isAdjacentToEmpty: (row: number, col: number) => {
            return this.viewModel.isAdjacentToEmpty(row, col);
          }
        })
      }
      .width(this.getBoardWidthPercent())
      .margin({ bottom: '3%' })

      Button(BTN_NEW_GAME)
        .width(this.getBtnWidth())
        .height(this.getBtnHeight())
        .fontSize(this.getBtnFontSize())
        .fontColor(Color.White)
        .fontWeight(FontWeight.Bold)
        .backgroundColor('rgba(255,255,255,0.15)')
        .borderRadius('5vp')
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
