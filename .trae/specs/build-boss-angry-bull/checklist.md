# Checklist

## Boss Battle Intro
- [x] 进入地图立即锁定玩家操作
- [x] 摄像机平滑拉远至战场全景
- [x] 围墙生成（淡入效果）
- [x] Boss在围墙边缘入场
- [x] 入场完成后解锁玩家操作

## Boss Base Class
- [x] Boss基类继承Character并支持状态机
- [x] Boss从配置表加载属性
- [x] Boss发出hp_changed和died信号

## Battle Arena
- [x] 战场围墙以玩家为中心生成
- [x] 围墙有淡入/淡出效果
- [x] 摄像机锁定在战场范围内
- [x] Boss击败后战场销毁

## Phase 1 Behavior
- [x] Idle状态：锁定玩家、持续1秒、播放idle动画
- [x] Telegraphing状态：预警线显示、锁定方向、持续1秒
- [x] Dashing状态：800px/s冲锋、碰撞检测
- [x] Stun状态：眩晕0.5秒、播放stun动画

## Phase 2 Enraged
- [x] HP低于50%触发狂暴模式
- [x] 怒吼动画+震屏效果
- [x] 冲锋速度1.5倍、蓄力时间0.5倍
- [x] 折返冲锋（反弹3次）
- [x] 冲锋路径生成伤害粒子
- [x] 撞墙发射散弹

## Player Integration
- [x] 玩家可被Boss伤害
- [x] 玩家可对Boss造成伤害

## Animation
- [x] idle动画正确播放
- [x] telegraphing动画正确播放
- [x] dash动画正确播放
- [x] stun动画正确播放
- [x] angry动画正确播放
