# Tasks

## Phase 1: 基础架构

- [x] Task 1: 创建Boss配置表
  - [x] 创建 `resources/tables/bosses.csv`
  - [x] 添加 angry_bull 配置数据（HP、冲锋速度、蓄力时间、眩晕时间、伤害等）

- [x] Task 2: 创建Boss基类
  - [x] 创建 `framecore/character/boss.gd`
  - [x] 继承 Character，添加状态机支持
  - [x] 添加 `hp_changed` 和 `died` 信号
  - [x] 实现从配置表加载属性

- [x] Task 3: 创建Boss动画资源
  - [x] 创建 `resources/animation/boss/b1/bull_frames.tres` (SpriteFrames)
  - [x] 配置 idle, telegraphing, dash, stun, angry 动画

## Phase 2: 战场系统

- [x] Task 4: 创建战场围墙系统
  - [x] 创建 `framecore/battle/battle_arena.gd`
  - [x] 实现围墙生成（以玩家为中心）
  - [x] 实现围墙淡入/淡出效果
  - [x] 实现摄像机锁定

- [x] Task 5: 实现Boss战开场流程
  - [x] 创建 `framecore/battle/boss_battle_controller.gd`
  - [x] 实现玩家操作锁定/解锁
  - [x] 实现摄像机拉远动画
  - [x] 实现围墙生成后Boss入场
  - [x] 实现入场完成后的战斗开始

## Phase 3: Boss状态机

- [x] Task 6: 创建AngryBull预制体和脚本
  - [x] 创建 `game/boss/angry_bull.gd`
  - [x] 创建 `resources/prefabs/boss/angry_bull.tscn`
  - [x] 配置 StateChart 状态机节点

- [x] Task 7: 实现Phase1状态逻辑
  - [x] 实现 Idle 状态（锁定玩家、1秒后进入蓄力）
  - [x] 实现 Telegraphing 状态（预警线显示、锁定方向）
  - [x] 实现 Dashing 状态（冲锋移动、碰撞检测）
  - [x] 实现 Stun 状态（眩晕、返回Idle）

- [x] Task 8: 实现Phase2狂暴模式
  - [x] 实现HP检测触发狂暴
  - [x] 实现怒吼动画和震屏效果
  - [x] 实现属性增强（速度1.5倍、蓄力0.5倍）
  - [x] 实现折返冲锋（反弹3次）
  - [x] 创建 `game/boss/dash_trail.gd` 路径粒子
  - [x] 实现撞墙弹幕

## Phase 4: 整合测试

- [x] Task 9: 玩家受伤处理
  - [x] 修改 Player 添加受伤处理
  - [x] 添加与Boss/子弹的碰撞检测

- [x] Task 10: Boss战结束处理
  - [x] 实现Boss击败后的战场销毁
  - [x] 实现胜利结算

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 5] depends on [Task 4]
- [Task 6] depends on [Task 2, Task 3]
- [Task 7] depends on [Task 6]
- [Task 8] depends on [Task 7]
- [Task 9] depends on [Task 7]
- [Task 10] depends on [Task 5, Task 8, Task 9]
