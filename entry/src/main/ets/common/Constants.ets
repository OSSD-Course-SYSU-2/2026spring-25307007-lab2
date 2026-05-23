// 游戏常量定义

// 棋盘尺寸
export const GRID_SIZE: number = 4;
export const TOTAL_TILES: number = GRID_SIZE * GRID_SIZE;
export const EMPTY_TILE: number = 0;

// 动画参数
export const SLIDE_ANIMATION_DURATION: number = 250;
export const CLICK_FEEDBACK_DURATION: number = 100;
export const CELEBRATION_DURATION: number = 3000;
export const CELEBRATION_PARTICLE_INTERVAL: number = 50;

// 数字块尺寸
export const TILE_SIZE: number = 80;
export const TILE_GAP: number = 8;
export const TILE_BORDER_RADIUS: number = 12;
export const TILE_FONT_SIZE: number = 28;

// 棋盘尺寸
export const BOARD_PADDING: number = 16;
export const BOARD_SIZE: number = GRID_SIZE * TILE_SIZE + (GRID_SIZE + 1) * TILE_GAP + BOARD_PADDING * 2;

// 配色方案 - 深色渐变背景
export const BG_COLOR_START: string = '#1a1a2e';
export const BG_COLOR_END: string = '#16213e';
export const BOARD_BG_COLOR: string = '#0f3460';

// 数字块渐变色组（4组，每组2色）
export const TILE_GRADIENT_COLORS: Array<Array<string>> = [
  ['#667eea', '#764ba2'], // 蓝紫
  ['#43e97b', '#38f9d7'], // 青绿
  ['#f093fb', '#f5576c'], // 粉红
  ['#4facfe', '#00f2fe'], // 蓝青
];

// 胜利弹窗
export const VICTORY_DIALOG_WIDTH: number = 300;
export const VICTORY_DIALOG_HEIGHT: number = 360;

// 计分板
export const SCORE_LABEL_FONT_SIZE: number = 14;
export const SCORE_VALUE_FONT_SIZE: number = 24;

// 庆部标题
export const TITLE_FONT_SIZE: number = 32;
export const TITLE_TEXT: string = '数字华容道';

// 按钮文字
export const BTN_NEW_GAME: string = '新游戏';
export const BTN_RESTART: string = '再来一局';
