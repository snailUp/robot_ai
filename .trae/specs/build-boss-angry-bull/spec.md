# Boss 愤怒公牛 (Angry Bull) Spec

## Why
关卡1需要一个Boss敌人，提供有挑战性的战斗体验。Boss需要具备状态机驱动的行为逻辑、多阶段战斗机制、以及与战场环境的交互。

## What Changes
- 新增 `Boss` 基类，继承 `Character`，支持状态机驱动
- 新增 `AngryBull` Boss实现，包含两个战斗阶段
- 新增 `BattleArena` 战场围墙系统
- 新增 `DashTrail` 冲锋路径伤害粒子
- 新增 Boss 配置表数据

## Impact
- Affected specs: Character System, State Charts Plugin
- Affected code: `framecore/character/`, `game/character/`, `game/boss/`

---

## ADDED Requirements

### Requirement: Boss Base Class
系统应提供 Boss 基类，支持状态机驱动的行为逻辑。

#### Scenario: Boss 初始化
- **WHEN** Boss 场景被实例化
- **THEN** Boss 应从配置表加载属性（HP、攻击力等）
- **AND** Boss 应初始化状态机
- **AND** Boss 应播放初始动画

#### Scenario: Boss 受伤
- **WHEN** Boss 受到伤害
- **THEN** Boss 应减少当前HP
- **AND** Boss 应播放受伤反馈（闪烁/震屏）
- **AND** 当HP低于50%时，应触发狂暴模式

### Requirement: Battle Arena System
系统应提供战场围墙系统，在Boss战触发时创建闭环战场。

#### Scenario: Boss战开场流程
- **WHEN** 玩家进入Boss地图
- **THEN** 系统应立即锁定玩家操作（禁止移动和射击）
- **AND** 摄像机应平滑拉远至战场全景视角
- **AND** 系统应以玩家当前位置为中心生成矩形围墙（淡入效果）
- **AND** 围墙生成完成后，Boss应在围墙边缘入场
- **AND** Boss入场动画完成后，解锁玩家操作
- **AND** Boss战正式开始

#### Scenario: 战场生成
- **WHEN** Boss战触发
- **THEN** 系统应以玩家当前位置为中心生成矩形围墙
- **AND** 围墙应为 `StaticBody2D` 类型
- **AND** 围墙应有淡入效果
- **AND** 摄像机应锁定在战场范围内

#### Scenario: 战场销毁
- **WHEN** Boss被击败
- **THEN** 围墙应有淡出效果后销毁
- **AND** 摄像机限制应解除

### Requirement: Angry Bull Phase 1
愤怒公牛在第一阶段应执行"锁定-蓄力-冲锋-撞墙"循环。

#### Scenario: 锁定与待机 (Idle/Lock-on)
- **WHEN** Boss进入Idle状态
- **THEN** Boss应停止移动
- **AND** Boss应实时转向玩家位置
- **AND** 状态持续1.0秒
- **AND** 播放 `idle` 动画

#### Scenario: 蓄力预警 (Telegraphing)
- **WHEN** Boss进入Telegraphing状态
- **THEN** Boss应播放刨地动画（身体闪红）
- **AND** 屏幕应显示穿过玩家位置的预警线
- **AND** 在预警结束前0.2秒锁定最终冲锋方向
- **AND** 状态持续1.0秒
- **AND** 播放 `telegraphing` 动画

#### Scenario: 冲锋位移 (Dashing)
- **WHEN** Boss进入Dashing状态
- **THEN** Boss应以800px/s速度沿锁定方向冲刺
- **AND** 检测与玩家的碰撞时应造成伤害但不减速
- **AND** 检测与围墙碰撞时应停止冲锋
- **AND** 播放 `dash` 动画

#### Scenario: 撞墙反馈 (Wall Impact)
- **WHEN** Boss撞墙
- **THEN** Boss应进入0.5秒眩晕状态
- **AND** 播放 `stun` 动画
- **AND** 眩晕结束后返回Idle状态

### Requirement: Angry Bull Phase 2 (Enraged)
当HP低于50%时，Boss应进入狂暴模式。

#### Scenario: 狂暴模式触发
- **WHEN** Boss HP降至50%以下
- **THEN** Boss应播放1.5秒怒吼动画
- **AND** 触发全场震屏效果
- **AND** 冲锋速度提升至1.5倍
- **AND** 蓄力时间缩短至0.5倍
- **AND** 播放 `angry` 动画

#### Scenario: 折返冲锋
- **WHEN** Boss在狂暴模式下冲锋
- **THEN** Boss应在墙体间反弹3次才停止
- **AND** 每次撞墙后立即反向冲锋

#### Scenario: 路径遗留
- **WHEN** Boss在狂暴模式下冲锋
- **THEN** 冲锋路径上应生成伤害粒子
- **AND** 粒子持续3秒
- **AND** 玩家接触粒子应受到伤害

#### Scenario: 撞墙弹幕
- **WHEN** Boss在狂暴模式下撞墙
- **THEN** 应以撞击点为圆心发射一圈散弹
- **AND** 散弹数量为8发
- **AND** 散弹向外辐射

### Requirement: Boss Configuration
Boss属性应通过配置表管理。

#### Scenario: 配置加载
- **WHEN** Boss初始化
- **THEN** 应从 `bosses` 配置表加载属性
- **AND** 属性包括：max_hp, dash_speed, telegraph_time, stun_time, damage

---

## MODIFIED Requirements

### Requirement: Character Base Class
Character基类应支持HP变化事件。

#### Scenario: HP变化通知
- **WHEN** 角色HP发生变化
- **THEN** 应发出 `hp_changed` 信号
- **AND** 应发出 `died` 信号当HP降至0

---

## Technical Design

### State Machine Structure
```
StateChart
└── BossBehavior (CompoundState)
    ├── Phase1 (CompoundState, initial_state=Idle)
    │   ├── Idle (AtomicState)
    │   ├── Telegraphing (AtomicState)
    │   ├── Dashing (AtomicState)
    │   └── Stun (AtomicState)
    └── Phase2 (CompoundState)
        ├── EnragedEntry (AtomicState)
        ├── Idle (AtomicState)
        ├── Telegraphing (AtomicState)
        ├── Dashing (AtomicState)
        └── Stun (AtomicState)
```

### Animation Resources
| 状态 | 动画资源路径 |
|------|-------------|
| Idle | resources/animation/boss/b1/idle |
| Telegraphing | resources/animation/boss/b1/telegraphing |
| Dashing | resources/animation/boss/b1/dash |
| Stun | resources/animation/boss/b1/stun |
| Angry | resources/animation/boss/b1/angry |

### File Structure
```
framecore/
├── character/
│   └── boss.gd              # Boss基类
├── battle/
│   └── battle_arena.gd      # 战场围墙系统

game/
├── boss/
│   ├── angry_bull.gd        # 愤怒公牛实现
│   └── dash_trail.gd        # 冲锋路径粒子
└── character/
    └── player.gd            # (修改) 添加受伤处理

resources/
├── prefabs/
│   ├── boss/
│   │   └── angry_bull.tscn  # Boss预制体
│   └── battle/
│       └── battle_arena.tscn # 战场预制体
└── tables/
    └── bosses.csv           # Boss配置表
```
