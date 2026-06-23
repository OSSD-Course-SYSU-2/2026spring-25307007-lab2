// 游戏常量定义

// 游戏模式枚举
export enum GameMode {
  NORMAL = 4,  // 普通模式：4×4棋盘
  HARD = 6     // 困难模式：6×6棋盘
}

// 棋盘尺寸（默认4×4，保持向后兼容）
export const GRID_SIZE: number = 4;
export const TOTAL_TILES: number = GRID_SIZE * GRID_SIZE;
export const EMPTY_TILE: number = 0;

// 动画参数
export const SLIDE_ANIMATION_DURATION: number = 250;
export const CLICK_FEEDBACK_DURATION: number = 100;
export const CELEBRATION_DURATION: number = 3000;
export const CELEBRATION_PARTICLE_INTERVAL: number = 50;

// 数字块尺寸（使用 vp 响应式单位）
export const TILE_SIZE: string = '18vp';
export const TILE_GAP: string = '1.5vp';
export const TILE_BORDER_RADIUS: string = '2.5vp';
export const TILE_FONT_SIZE: string = '6fp';

// 棋盘尺寸（使用 vp 响应式单位）
export const BOARD_PADDING: string = '3vp';
export const BOARD_BORDER_RADIUS: string = '3vp';

// 配色方案 - 深色渐变背景
export const BG_COLOR_START: string = '#1a1a2e';
export const BG_COLOR_END: string = '#16213e';
export const BOARD_BG_COLOR: string = '#0f3460';

// 数字块渐变色组（6组，每组2色，适配1-35数字）
export const TILE_GRADIENT_COLORS: Array<Array<string>> = [
  ['#667eea', '#764ba2'], // 蓝紫 (1-6)
  ['#43e97b', '#38f9d7'], // 青绿 (7-12)
  ['#f093fb', '#f5576c'], // 粉红 (13-18)
  ['#4facfe', '#00f2fe'], // 蓝青 (19-24)
  ['#fa709a', '#fee140'], // 橙黄 (25-30)
  ['#a8edea', '#fed6e3'], // 浅粉 (31-35)
];

// 胜利弹窗（使用百分比宽度）
export const VICTORY_DIALOG_WIDTH: string = '80%';

// 计分板（使用 fp 字体单位）
export const SCORE_LABEL_FONT_SIZE: string = '3fp';
export const SCORE_VALUE_FONT_SIZE: string = '5fp';

// 页面标题（使用 fp 字体单位）
export const TITLE_FONT_SIZE: string = '7fp';
export const TITLE_TEXT: string = '数字华容道';

// 按钮文字
export const BTN_NEW_GAME: string = '新游戏';
export const BTN_RESTART: string = '再来一局';

// 模式选择器常量
export const MODE_SELECTOR_WIDTH: string = '60%';
export const MODE_SELECTOR_HEIGHT: string = '8vp';
export const MODE_SELECTOR_FONT_SIZE: string = '4fp';
export const MODE_NORMAL_TEXT: string = '普通模式';
export const MODE_HARD_TEXT: string = '困难模式';

// 持久化存储键
export const PREF_KEY_GAME_MODE: string = 'game_mode';
