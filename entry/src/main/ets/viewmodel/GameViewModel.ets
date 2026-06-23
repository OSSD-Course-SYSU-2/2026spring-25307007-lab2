// 游戏核心逻辑控制器

import { GameModel, GameState, TilePosition } from '../model/GameModel';
import { GameMode, PREF_KEY_GAME_MODE } from '../common/Constants';
import dataPreferences from '@ohos.data.preferences';
import common from '@ohos.app.ability.common';

// 移动方向枚举
export enum MoveDirection {
  UP,
  DOWN,
  LEFT,
  RIGHT
}

// 移动结果
export class MoveResult {
  moved: boolean = false;
  fromRow: number = 0;
  fromCol: number = 0;
  toRow: number = 0;
  toCol: number = 0;
  value: number = 0;
  won: boolean = false;
}

// 游戏视图状态（纯数据，供UI绑定）
export class GameViewState {
  board: number[][] = [];
  moveCount: number = 0;
  elapsedTime: number = 0;
  gameState: GameState = GameState.IDLE;
  formattedTime: string = '00:00';
  gridSize: number = 4;
}

// 游戏核心逻辑（非响应式，由页面统一管理状态）
export class GameViewModel {
  private model: GameModel = new GameModel();
  private timerId: number = -1;
  private onStateChange: (state: GameViewState) => void = () => {};
  private currentMode: GameMode = GameMode.NORMAL;
  private context: common.UIAbilityContext | null = null;

  constructor(onStateChange: (state: GameViewState) => void) {
    this.onStateChange = onStateChange;
    this.notifyState();
  }

  // 设置上下文（用于Preferences）
  setContext(context: common.UIAbilityContext): void {
    this.context = context;
  }

  // 设置游戏模式
  setGameMode(mode: GameMode): void {
    this.currentMode = mode;
    this.model.setGridSize(mode);
    this.notifyState();
  }

  // 获取游戏模式
  getGameMode(): GameMode {
    return this.currentMode;
  }

  // 获取棋盘尺寸
  getGridSize(): number {
    return this.model.getGridSize();
  }

  private notifyState(): void {
    const state = new GameViewState();
    state.board = this.model.board.map(row => [...row]);
    state.moveCount = this.model.moveCount;
    state.elapsedTime = this.model.elapsedTime;
    state.gameState = this.model.state;
    state.formattedTime = this.model.getFormattedTime();
    state.gridSize = this.model.getGridSize();
    this.onStateChange(state);
  }

  // 开始新游戏
  startNewGame(): void {
    this.stopTimer();
    this.model.initBoard();
    this.model.shuffle();
    this.notifyState();
    this.startTimer();
  }

  // 重置
  resetGame(): void {
    this.stopTimer();
    this.model.initBoard();
    this.notifyState();
  }

  // 点击移动
  moveTile(row: number, col: number): MoveResult {
    const result = new MoveResult();

    if (this.model.state !== GameState.PLAYING) {
      return result;
    }

    if (this.model.board[row][col] === 0) {
      return result;
    }

    if (!this.model.isAdjacentToEmpty(row, col)) {
      return result;
    }

    result.moved = true;
    result.fromRow = row;
    result.fromCol = col;
    result.toRow = this.model.emptyPos.row;
    result.toCol = this.model.emptyPos.col;
    result.value = this.model.board[row][col];

    this.model.swapWithEmpty(row, col);

    if (this.model.checkWin()) {
      this.model.state = GameState.WON;
      result.won = true;
      this.stopTimer();
    }

    this.notifyState();
    return result;
  }

  // 滑动移动
  swipeMove(direction: MoveDirection): MoveResult {
    if (this.model.state !== GameState.PLAYING) {
      return new MoveResult();
    }

    const emptyRow = this.model.emptyPos.row;
    const emptyCol = this.model.emptyPos.col;
    let targetRow = emptyRow;
    let targetCol = emptyCol;

    switch (direction) {
      case MoveDirection.UP:
        targetRow = emptyRow + 1;
        break;
      case MoveDirection.DOWN:
        targetRow = emptyRow - 1;
        break;
      case MoveDirection.LEFT:
        targetCol = emptyCol + 1;
        break;
      case MoveDirection.RIGHT:
        targetCol = emptyCol - 1;
        break;
    }

    const gridSize = this.model.getGridSize();
    if (targetRow < 0 || targetRow >= gridSize || targetCol < 0 || targetCol >= gridSize) {
      return new MoveResult();
    }

    return this.moveTile(targetRow, targetCol);
  }

  // 判断是否与空格相邻
  isAdjacentToEmpty(row: number, col: number): boolean {
    return this.model.isAdjacentToEmpty(row, col);
  }

  // 是否游戏中
  isPlaying(): boolean {
    return this.model.state === GameState.PLAYING;
  }

  // 启动计时器
  private startTimer(): void {
    this.stopTimer();
    this.timerId = setInterval(() => {
      if (this.model.state === GameState.PLAYING) {
        this.model.elapsedTime++;
        this.notifyState();
      }
    }, 1000);
  }

  // 停止计时器
  stopTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  // 保存游戏模式到Preferences
  async saveGameMode(mode: GameMode): Promise<void> {
    if (!this.context) {
      return;
    }
    try {
      const preferences = await dataPreferences.getPreferences(this.context, 'game_settings');
      await preferences.put(PREF_KEY_GAME_MODE, mode);
      await preferences.flush();
    } catch (error) {
      console.error('Failed to save game mode:', error);
    }
  }

  // 从Preferences加载游戏模式
  async loadGameMode(): Promise<GameMode> {
    if (!this.context) {
      return GameMode.NORMAL;
    }
    try {
      const preferences = await dataPreferences.getPreferences(this.context, 'game_settings');
      const mode = await preferences.get(PREF_KEY_GAME_MODE, GameMode.NORMAL);
      return mode as GameMode;
    } catch (error) {
      console.error('Failed to load game mode:', error);
      return GameMode.NORMAL;
    }
  }
}
