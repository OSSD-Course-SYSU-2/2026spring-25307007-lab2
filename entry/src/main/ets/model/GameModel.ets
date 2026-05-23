// 游戏数据模型与类型定义

import { GRID_SIZE, TOTAL_TILES, EMPTY_TILE } from '../common/Constants';

// 数字块位置信息
export class TilePosition {
  row: number = 0;
  col: number = 0;

  constructor(row: number, col: number) {
    this.row = row;
    this.col = col;
  }
}

// 游戏状态枚举
export enum GameState {
  IDLE,       // 初始/待开始
  PLAYING,    // 游戏中
  WON         // 已胜利
}

// 游戏数据模型
export class GameModel {
  // 棋盘数据：4x4数组，0表示空格，1-15表示数字
  board: number[][] = [];
  // 空格位置
  emptyPos: TilePosition = new TilePosition(0, 0);
  // 移动步数
  moveCount: number = 0;
  // 游戏用时（秒）
  elapsedTime: number = 0;
  // 游戏状态
  state: GameState = GameState.IDLE;

  constructor() {
    this.initBoard();
  }

  // 初始化为已排好的状态（1-15, 0）
  initBoard(): void {
    this.board = [];
    for (let row = 0; row < GRID_SIZE; row++) {
      this.board[row] = [];
      for (let col = 0; col < GRID_SIZE; col++) {
        let value = row * GRID_SIZE + col + 1;
        if (value === TOTAL_TILES) {
          value = EMPTY_TILE;
          this.emptyPos = new TilePosition(row, col);
        }
        this.board[row][col] = value;
      }
    }
    this.moveCount = 0;
    this.elapsedTime = 0;
    this.state = GameState.IDLE;
  }

  // 获取指定位置的值
  getTileValue(row: number, col: number): number {
    return this.board[row][col];
  }

  // 判断是否与空格相邻
  isAdjacentToEmpty(row: number, col: number): boolean {
    const dr = Math.abs(row - this.emptyPos.row);
    const dc = Math.abs(col - this.emptyPos.col);
    return (dr === 1 && dc === 0) || (dr === 0 && dc === 1);
  }

  // 交换指定位置与空格
  swapWithEmpty(row: number, col: number): void {
    this.board[this.emptyPos.row][this.emptyPos.col] = this.board[row][col];
    this.board[row][col] = EMPTY_TILE;
    this.emptyPos = new TilePosition(row, col);
    this.moveCount++;
  }

  // 检查是否胜利（1-15按顺序，空格在最后）
  checkWin(): boolean {
    for (let row = 0; row < GRID_SIZE; row++) {
      for (let col = 0; col < GRID_SIZE; col++) {
        const expected = row * GRID_SIZE + col + 1;
        if (row === GRID_SIZE - 1 && col === GRID_SIZE - 1) {
          if (this.board[row][col] !== EMPTY_TILE) return false;
        } else {
          if (this.board[row][col] !== expected) return false;
        }
      }
    }
    return true;
  }

  // 计算逆序数（用于可解性判断）
  countInversions(): number {
    const flat: number[] = [];
    for (let row = 0; row < GRID_SIZE; row++) {
      for (let col = 0; col < GRID_SIZE; col++) {
        if (this.board[row][col] !== EMPTY_TILE) {
          flat.push(this.board[row][col]);
        }
      }
    }
    let inversions = 0;
    for (let i = 0; i < flat.length; i++) {
      for (let j = i + 1; j < flat.length; j++) {
        if (flat[i] > flat[j]) {
          inversions++;
        }
      }
    }
    return inversions;
  }

  // 判断当前棋盘是否可解
  // 对于4x4棋盘：空格在从底部数的偶数行时，逆序数为奇数可解；空格在奇数行时，逆序数为偶数可解
  isSolvable(): boolean {
    const inversions = this.countInversions();
    const emptyRowFromBottom = GRID_SIZE - this.emptyPos.row;
    if (emptyRowFromBottom % 2 === 0) {
      return inversions % 2 === 1;
    } else {
      return inversions % 2 === 0;
    }
  }

  // 打乱棋盘（Fisher-Yates洗牌，确保可解）
  shuffle(): void {
    // 将棋盘展平为一维数组
    const flat: number[] = [];
    for (let row = 0; row < GRID_SIZE; row++) {
      for (let col = 0; col < GRID_SIZE; col++) {
        flat.push(this.board[row][col]);
      }
    }

    // Fisher-Yates 洗牌
    for (let i = flat.length - 1; i > 0; i--) {
      const j = Math.floor(Math.random() * (i + 1));
      const temp = flat[i];
      flat[i] = flat[j];
      flat[j] = temp;
    }

    // 写回棋盘
    for (let row = 0; row < GRID_SIZE; row++) {
      for (let col = 0; col < GRID_SIZE; col++) {
        this.board[row][col] = flat[row * GRID_SIZE + col];
        if (this.board[row][col] === EMPTY_TILE) {
          this.emptyPos = new TilePosition(row, col);
        }
      }
    }

    // 如果不可解，交换两个非空数字块使其可解
    if (!this.isSolvable()) {
      // 找到前两个非空块并交换
      let found1: boolean = false;
      let found2: boolean = false;
      let row1: number = 0;
      let col1: number = 0;
      let row2: number = 0;
      let col2: number = 0;
      for (let row = 0; row < GRID_SIZE; row++) {
        for (let col = 0; col < GRID_SIZE; col++) {
          if (this.board[row][col] !== EMPTY_TILE) {
            if (!found1) {
              row1 = row;
              col1 = col;
              found1 = true;
            } else if (!found2) {
              row2 = row;
              col2 = col;
              found2 = true;
              break;
            }
          }
        }
        if (found2) break;
      }
      if (found1 && found2) {
        const temp = this.board[row1][col1];
        this.board[row1][col1] = this.board[row2][col2];
        this.board[row2][col2] = temp;
      }
    }

    this.moveCount = 0;
    this.elapsedTime = 0;
    this.state = GameState.PLAYING;
  }

  // 格式化时间 mm:ss
  getFormattedTime(): string {
    const minutes = Math.floor(this.elapsedTime / 60);
    const seconds = this.elapsedTime % 60;
    const minStr = minutes < 10 ? `0${minutes}` : `${minutes}`;
    const secStr = seconds < 10 ? `0${seconds}` : `${seconds}`;
    return `${minStr}:${secStr}`;
  }
}
