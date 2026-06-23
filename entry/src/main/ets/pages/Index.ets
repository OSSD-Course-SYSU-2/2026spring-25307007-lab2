// 数字华容道 - 游戏主页面（全设备自适应）

import { GameViewModel, MoveDirection, GameViewState } from '../viewmodel/GameViewModel';
import { GameBoard } from '../components/GameBoard';
import { ScoreBoard } from '../components/ScoreBoard';
import { VictoryDialog } from '../components/VictoryDialog';
import { ModeSelector } from '../components/ModeSelector';
import { GameState } from '../model/GameModel';
import {
  BG_COLOR_START,
  BG_COLOR_END,
  TITLE_TEXT,
  BTN_NEW_GAME,
  GameMode
} from '../common/Constants';
import { ConfigurationConstant, Configuration } from '@kit.AbilityKit';
import { deviceInfo } from '@kit.BasicServicesKit';
import { display } from '@kit.ArkUI';
import common from '@ohos.app.ability.common';

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
  @State hasDetectedDevice: boolean = false;

  // 游戏模式状态
  @State currentMode: GameMode = GameMode.NORMAL;

  // ViewModel（非响应式，通过回调更新状态）
  private viewModel: GameViewModel = new GameViewModel((state: GameViewState) => {
    this.viewState = state;
  });

  // 滑动相关
  private touchStartX: number = 0;
  private touchStartY: number = 0;
  private readonly SWIPE_THRESHOLD: number = 30;

  aboutToAppear(): void {
    // 设置上下文
    const context = getContext(this) as common.UIAbilityContext;
    this.viewModel.setContext(context);

    // 加载保存的游戏模式
    this.loadSavedMode();

    this.hasDetectedDevice = false; // 重置检测标志，确保每次加载都重新检测
    this.detectDeviceType();
  }

  // 加载保存的游戏模式
  private async loadSavedMode(): Promise<void> {
    const savedMode = await this.viewModel.loadGameMode();
    this.currentMode = savedMode;
    this.viewModel.setGameMode(savedMode);
    this.viewModel.startNewGame();
  }

  // 处理模式切换
  private async handleModeChange(mode: GameMode): Promise<void> {
    if (mode === this.currentMode) {
      return;
    }

    // 如果游戏正在进行，可以添加确认对话框（这里简化处理）
    this.currentMode = mode;
    this.viewModel.setGameMode(mode);
    await this.viewModel.saveGameMode(mode);
    this.showVictory = false;
    this.viewModel.startNewGame();
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
      // 优先使用 @ohos.deviceInfo API 检测设备类型
      const devType = deviceInfo.deviceType;
      if (devType === 'wearable' || devType === 'watch') {
        this.deviceCategory = 'wearable';
      } else if (devType === 'tv') {
        this.deviceCategory = 'tv';
      } else if (devType === 'tablet') {
        this.deviceCategory = 'tablet';
      } else {
        this.deviceCategory = 'phone';
      }
    } catch (e) {
      // API 不可用
    }
    // 通过屏幕形状二次校验
    this.detectByScreenShape();
  }

  // 通过屏幕形状兜底检测设备类型
  private detectByScreenShape(): void {
    try {
      const disp = display.getDefaultDisplaySync();
      const ratio = Math.min(disp.width, disp.height) / Math.max(disp.width, disp.height);
      const minDim = Math.min(disp.width, disp.height);
      
      // 圆形手表屏幕宽高比接近1:1（>0.95），且短边较小（<=500）
      if (ratio > 0.95 && minDim <= 500) {
        this.deviceCategory = 'wearable';
      }
      // 平板：短边较大（>500vp），或宽高比接近1:1但尺寸大
      else if (minDim > 500) {
        this.deviceCategory = 'tablet';
      }
    } catch (e) {
      // 屏幕检测也失败，保持默认值
    }
  }

  // 通过组件区域尺寸检测设备类型（最可靠的方式）
  private detectByComponentArea(width: number, height: number): void {
    if (this.hasDetectedDevice) return;
    this.hasDetectedDevice = true;
    
    const ratio = Math.min(width, height) / Math.max(width, height);
    const minDim = Math.min(width, height);
    
    // 圆形手表屏幕：宽高比接近1:1（>0.95），且短边较小（<=500vp）
    if (ratio > 0.95 && minDim <= 500) {
      this.deviceCategory = 'wearable';
    }
    // 平板：短边较大（>500vp）
    else if (minDim > 500) {
      this.deviceCategory = 'tablet';
    }
  }

  // ========== 各设备布局参数计算 ==========

  private getBoardWidthPercent(): string {
    // 6×6模式使用稍小的棋盘宽度
    const isHardMode = this.currentMode === GameMode.HARD;
    if (this.deviceCategory === 'wearable') return isHardMode ? '60%' : '65%';
    if (this.deviceCategory === 'tv') return this.isLandscape ? (isHardMode ? '45%' : '50%') : (isHardMode ? '65%' : '70%');
    if (this.deviceCategory === 'tablet') return this.isLandscape ? (isHardMode ? '50%' : '55%') : (isHardMode ? '75%' : '80%');
    return isHardMode ? '85%' : '90%';
  }

  private getTitleFontSize(): string {
    if (this.deviceCategory === 'wearable') return '4fp';
    if (this.deviceCategory === 'tv') return '12fp';
    if (this.deviceCategory === 'tablet') return '28fp';
    return '9fp';
  }

  private getScoreBoardHeight(): string {
    if (this.deviceCategory === 'wearable') return '6%';
    if (this.deviceCategory === 'tv') return '6%';
    return '8%';
  }

  private getBtnWidth(): string {
    if (this.deviceCategory === 'wearable') return '40%';
    if (this.deviceCategory === 'tv') return '25%';
    if (this.deviceCategory === 'tablet') return '30%';
    return '35%';
  }

  private getBtnHeight(): string {
    if (this.deviceCategory === 'wearable') return '5%';
    return '6%';
  }

  private getBtnFontSize(): string {
    if (this.deviceCategory === 'wearable') return '2fp';
    if (this.deviceCategory === 'tv') return '6fp';
    if (this.deviceCategory === 'tablet') return '14fp';
    return '4.5fp';
  }

  private getTileFontSize(): string {
    // 6×6模式使用更小的字体
    const isHardMode = this.currentMode === GameMode.HARD;
    if (this.deviceCategory === 'wearable') return isHardMode ? '6fp' : '8fp';
    if (this.deviceCategory === 'tv') return isHardMode ? '12fp' : '16fp';
    if (this.deviceCategory === 'tablet') return isHardMode ? '24fp' : '32fp';
    return isHardMode ? '9fp' : '12fp';
  }

  private getScoreLabelFontSize(): string {
    if (this.deviceCategory === 'wearable') return '2fp';
    if (this.deviceCategory === 'tablet') return '14fp';
    return '4fp';
  }

  private getScoreValueFontSize(): string {
    if (this.deviceCategory === 'wearable') return '2.5fp';
    if (this.deviceCategory === 'tablet') return '18fp';
    return '6fp';
  }

  private getBoardPadding(): string {
    if (this.deviceCategory === 'wearable') return '1.5%';
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
    .onAreaChange((oldValue: Area, newValue: Area) => {
      // 通过组件实际渲染区域检测设备类型
      const width = newValue.width as number;
      const height = newValue.height as number;
      this.detectByComponentArea(width, height);
    })
  }

  // ========== wearable 精简布局 ==========
  @Builder
  buildWearableLayout() {
    Column() {
      Text(`步数: ${this.viewState.moveCount}`)
        .fontSize(this.getScoreValueFontSize())
        .fontColor('rgba(255,255,255,0.8)')
        .fontWeight(FontWeight.Bold)
        .margin({ top: '1%', bottom: '1%' })

      ModeSelector({
        currentMode: this.currentMode,
        selectorWidth: '70%',
        selectorHeight: '6vp',
        fontSize: '2.5fp',
        onModeChange: (mode: GameMode) => {
          this.handleModeChange(mode);
        }
      })
        .margin({ bottom: '1%' })

      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        GameBoard({
          board: this.viewState.board,
          gameState: this.viewState.gameState,
          tileFontSize: this.getTileFontSize(),
          boardPadding: this.getBoardPadding(),
          gridSize: this.viewState.gridSize,
          onTileClick: (row: number, col: number) => {
            this.handleTileClick(row, col);
          },
          isAdjacentToEmpty: (row: number, col: number) => {
            return this.viewModel.isAdjacentToEmpty(row, col);
          }
        })
      }
      .width(this.getBoardWidthPercent())
      .margin({ bottom: '1%' })

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

      ModeSelector({
        currentMode: this.currentMode,
        selectorWidth: '50%',
        selectorHeight: '8vp',
        fontSize: '5fp',
        onModeChange: (mode: GameMode) => {
          this.handleModeChange(mode);
        }
      })
        .margin({ bottom: '1.5%' })

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
          gridSize: this.viewState.gridSize,
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
            gridSize: this.viewState.gridSize,
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

          ModeSelector({
            currentMode: this.currentMode,
            selectorWidth: '80%',
            selectorHeight: '10vp',
            fontSize: '10fp',
            onModeChange: (mode: GameMode) => {
              this.handleModeChange(mode);
            }
          })
            .margin({ bottom: '3%' })

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

        ModeSelector({
          currentMode: this.currentMode,
          selectorWidth: '70%',
          selectorHeight: '10vp',
          fontSize: '10fp',
          onModeChange: (mode: GameMode) => {
            this.handleModeChange(mode);
          }
        })
          .margin({ bottom: '2%' })

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
            gridSize: this.viewState.gridSize,
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
        .margin({ top: '3%', bottom: '1.5%' })
        .textShadow({
          radius: 4,
          color: 'rgba(78,205,196,0.3)',
          offsetX: 0,
          offsetY: 2
        })

      ModeSelector({
        currentMode: this.currentMode,
        selectorWidth: '70%',
        selectorHeight: '8vp',
        fontSize: '4fp',
        onModeChange: (mode: GameMode) => {
          this.handleModeChange(mode);
        }
      })
        .margin({ bottom: '1.5%' })

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
      .margin({ bottom: '1.5%' })

      Flex({ justifyContent: FlexAlign.Center, alignItems: ItemAlign.Center }) {
        GameBoard({
          board: this.viewState.board,
          gameState: this.viewState.gameState,
          tileFontSize: this.getTileFontSize(),
          boardPadding: this.getBoardPadding(),
          gridSize: this.viewState.gridSize,
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
