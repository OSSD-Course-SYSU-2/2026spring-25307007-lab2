// 游戏核心逻辑控制器

import { GameModel, GameState, TilePosition } from '../model/GameModel';
import { GRID_SIZE } from '../common/Constants';

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
}

// 游戏核心逻辑（非响应式，由页面统一管理状态）
export class GameViewModel {
  private model: GameModel = new GameModel();
  private timerId: number = -1;
  private onStateChange: (state: GameViewState) => void = () => {};

  constructor(onStateChange: (state: GameViewState) => void) {
    this.onStateChange = onStateChange;
    this.notifyState();
  }

  private notifyState(): void {
    const state = new GameViewState();
    state.board = this.model.board.map(row => [...row]);
    state.moveCount = this.model.moveCount;
    state.elapsedTime = this.model.elapsedTime;
    state.gameState = this.model.state;
    state.formattedTime = this.model.getFormattedTime();
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

    if (targetRow < 0 || targetRow >= GRID_SIZE || targetCol < 0 || targetCol >= GRID_SIZE) {
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
}
