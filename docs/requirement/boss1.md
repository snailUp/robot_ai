#  Boss 需求文档：愤怒公牛 (Angry Bull) - 逻辑设计篇

## 1. 战场环境需求 (Arena Setup)

在 Boss 战触发时，系统需自动构建闭环战场，防止玩家利用无限地图拉扯。

- **生成逻辑**：以玩家当前 $P_{player}$ 为中心，瞬间实例化一个 `StaticBody2D` 矩形围墙。
- **围墙属性**：
  - **碰撞层 (Layer/Mask)**：设为 `World_Static` 层。
  - **可见性**：可选择半透明能量墙或实体砖墙，需有淡入效果。
- **镜头锁定**：将摄像机的 `limit_left/right/top/bottom` 设置为围墙坐标，确保战斗视角集中。

------

## 2. 详细行为逻辑 (Behavior Logic)

### 阶段一：常规循环 (Phase 1)

Boss 处于该阶段时，行为呈现“走-看-冲”的节奏感。

1. **锁定与待机 (Idle/Lock-on)**：
   - Boss 停下，实时转向玩家位置。
   - **时长**：1.0s。
   - 帧动画：resources/animation/boss/b1/idle
2. **蓄力预警 (Telegraphing)**：
   - **视觉**：Boss 播放刨地动画，身体开始闪红。
   - **指示线**：在屏幕上绘制一条穿过玩家位置的直线轨迹。
   - **逻辑**：在预警结束前 0.2s 锁定最终方向向量 $\vec{d}$。
   - 帧动画：resources/animation/boss/b1/telegraphing
3. **冲锋位移 (Dashing)**：
   - **速度**：固定高速位移（如 $800\text{ px/s}$）。
   - **碰撞判定**：
	 - **玩家**：检测到 `Area2D` 重叠，触发伤害函数，Boss 不减速，穿透玩家。
	 - **围墙**：检测到 `KinematicCollision2D`，Boss 停止冲锋。
   - 帧动画：resources/animation/boss/b1/dash
4. **撞墙反馈 (Wall Impact)**：
   - 撞墙后进入 0.5s 的**小硬直**（眩晕动画），随后回归“锁定”状态。
   - 帧动画：resources/animation/boss/b1/stun

### 阶段二：狂暴模式 (Phase 2 - <50% HP)

当血量触发阈值，Boss 逻辑发生质变。

- **状态转变**：播放一个 1.5s 的“怒吼”动画，全场震屏。
- **数值增强**：
  - 冲锋速度提升至 $1.5 \times$。
  - 蓄力时间缩短至 $0.5 \times$。
- **新增机制：**
  1. **折返冲锋**：单次锁定后，不再只冲一次，而是连续在墙体之间反弹 3 次才停止。
  2. **路径遗留**：冲锋路径上生成伤害粒子（如火焰），持续 3s，阻碍玩家走位。
  3. **撞墙弹幕**：每次撞击墙面，以撞击点为圆心发射一圈散弹。
- 帧动画：resources/animation/boss/b1/angry
