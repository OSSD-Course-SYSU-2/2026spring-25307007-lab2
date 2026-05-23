// 胜利结算弹窗组件

import {
  VICTORY_DIALOG_WIDTH,
  VICTORY_DIALOG_HEIGHT,
  BTN_RESTART,
  CELEBRATION_DURATION,
  CELEBRATION_PARTICLE_INTERVAL
} from '../common/Constants';

// 彩纸粒子数据
class ConfettiParticle {
  x: number = 0;
  y: number = 0;
  color: string = '';
  size: number = 0;
  rotation: number = 0;
  speedX: number = 0;
  speedY: number = 0;
  id: number = 0;

  constructor(x: number, y: number, color: string, size: number, id: number) {
    this.x = x;
    this.y = y;
    this.color = color;
    this.size = size;
    this.id = id;
    this.rotation = Math.random() * 360;
    this.speedX = (Math.random() - 0.5) * 8;
    this.speedY = Math.random() * 4 + 2;
  }
}

const CONFETTI_COLORS: string[] = [
  '#FF6B6B', '#4ECDC4', '#45B7D1', '#96CEB4',
  '#FFEAA7', '#DDA0DD', '#98D8C8', '#F7DC6F',
  '#BB8FCE', '#85C1E9', '#F1948A', '#82E0AA'
];

@Component
export struct VictoryDialog {
  @Prop moveCount: number = 0;
  @Prop formattedTime: string = '00:00';
  @State showConfetti: boolean = false;
  @State confettiParticles: ConfettiParticle[] = [];
  @State dialogOpacity: number = 0;
  @State dialogScale: number = 0.8;
  onRestart: () => void = () => {};
  onClose: () => void = () => {};

  private confettiTimerId: number = -1;
  private animationTimerId: number = -1;
  private particleIdCounter: number = 0;

  aboutToAppear(): void {
    // 弹窗入场动画
    setTimeout(() => {
      animateTo({
        duration: 400,
        curve: Curve.Ease,
        onFinish: () => {
          this.startConfetti();
        }
      }, () => {
        this.dialogOpacity = 1;
        this.dialogScale = 1;
      });
    }, 50);
  }

  aboutToDisappear(): void {
    this.stopConfetti();
  }

  private startConfetti(): void {
    this.showConfetti = true;
    this.generateConfetti();

    this.confettiTimerId = setInterval(() => {
      this.generateConfetti();
    }, CELEBRATION_PARTICLE_INTERVAL * 4);

    this.animationTimerId = setTimeout(() => {
      this.stopConfetti();
    }, CELEBRATION_DURATION);
  }

  private generateConfetti(): void {
    const newParticles: ConfettiParticle[] = [];
    for (let i = 0; i < 5; i++) {
      const x = Math.random() * VICTORY_DIALOG_WIDTH;
      const y = -10;
      const color = CONFETTI_COLORS[Math.floor(Math.random() * CONFETTI_COLORS.length)];
      const size = Math.random() * 8 + 4;
      newParticles.push(new ConfettiParticle(x, y, color, size, this.particleIdCounter++));
    }

    // 更新现有粒子位置
    const existing = this.confettiParticles.map(p => {
      p.x += p.speedX;
      p.y += p.speedY;
      p.rotation += 5;
      return p;
    }).filter(p => p.y < VICTORY_DIALOG_HEIGHT + 20);

    this.confettiParticles = [...existing, ...newParticles];
  }

  private stopConfetti(): void {
    if (this.confettiTimerId !== -1) {
      clearInterval(this.confettiTimerId);
      this.confettiTimerId = -1;
    }
    if (this.animationTimerId !== -1) {
      clearTimeout(this.animationTimerId);
      this.animationTimerId = -1;
    }
  }

  build() {
    Stack() {
      // 半透明遮罩
      Column()
        .width('100%')
        .height('100%')
        .backgroundColor('rgba(0,0,0,0.6)')
        .onClick(() => {
          this.onClose();
        })

      // 弹窗主体
      Column() {
        // 彩纸层
        if (this.showConfetti) {
          Stack() {
            ForEach(this.confettiParticles, (particle: ConfettiParticle) => {
              Column()
                .width(particle.size)
                .height(particle.size * 0.6)
                .backgroundColor(particle.color)
                .borderRadius(2)
                .rotate({ angle: particle.rotation })
                .position({ x: particle.x, y: particle.y })
            }, (item: ConfettiParticle) => `${item.id}`)
          }
          .width('100%')
          .height(120)
          .margin({ top: -20 })
        }

        // 胜利图标
        Text('\u{1F3C6}')
          .fontSize(48)
          .margin({ top: 16, bottom: 8 })

        // 胜利标题
        Text('恭喜通关！')
          .fontSize(24)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .margin({ bottom: 20 })

        // 统计信息
        Row() {
          Column() {
            Text('步数')
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.6)')
              .margin({ bottom: 4 })
            Text(`${this.moveCount}`)
              .fontSize(20)
              .fontColor('#4ECDC4')
              .fontWeight(FontWeight.Bold)
          }
          .layoutWeight(1)

          Column() {
            Text('用时')
              .fontSize(12)
              .fontColor('rgba(255,255,255,0.6)')
              .margin({ bottom: 4 })
            Text(this.formattedTime)
              .fontSize(20)
              .fontColor('#4ECDC4')
              .fontWeight(FontWeight.Bold)
          }
          .layoutWeight(1)
        }
        .width('100%')
        .padding({ left: 24, right: 24 })
        .margin({ bottom: 24 })

        // 再来一局按钮
        Button(BTN_RESTART)
          .width(160)
          .height(44)
          .fontSize(16)
          .fontColor(Color.White)
          .fontWeight(FontWeight.Bold)
          .backgroundColor('#4ECDC4')
          .borderRadius(22)
          .shadow({
            radius: 8,
            color: 'rgba(78,205,196,0.4)',
            offsetX: 0,
            offsetY: 4
          })
          .onClick(() => {
            this.onRestart();
          })
      }
      .width(VICTORY_DIALOG_WIDTH)
      .padding({ left: 20, right: 20, top: 24, bottom: 24 })
      .borderRadius(20)
      .backgroundColor('#1a1a2e')
      .border({ width: 1, color: 'rgba(255,255,255,0.1)' })
      .shadow({
        radius: 20,
        color: 'rgba(0,0,0,0.5)',
        offsetX: 0,
        offsetY: 10
      })
      .opacity(this.dialogOpacity)
      .scale({ x: this.dialogScale, y: this.dialogScale })
    }
    .width('100%')
    .height('100%')
  }
}
