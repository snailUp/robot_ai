# 角色系统 Spec

## Why
当前玩家角色参数硬编码在代码中，不便于调整和平衡。需要通过配置表驱动角色属性，并实现持枪射击的战斗机制。

## What Changes
- 新增角色配置表 `characters.csv`，定义角色基础属性
- 新增 `Character` 角色基类，从配置表动态加载属性
- 新增 `Bullet` 子弹类，实现 `IPoolable` 接口，使用对象池管理
- 新增 `BulletManager` 子弹管理器，封装对象池操作
- 新增 `Gun` 枪械组件，实现枪口跟随鼠标旋转和子弹发射
- 重构 `MapPlayer` 继承 `Character` 基类

## Impact
- Affected specs: 无
- Affected code:
  - `framecore/character/character.gd` - 角色基类
  - `framecore/character/bullet.gd` - 子弹类（实现IPoolable）
  - `framecore/character/bullet_manager.gd` - 子弹管理器
  - `framecore/character/gun.gd` - 枪械组件
  - `framecore/map/map_player.gd` - 重构继承 Character
  - `resources/tables/characters.csv` - 角色配置表
  - `resources/sprites/player/gun.png` - 枪械图片
  - `resources/sprites/player/img_zd.png` - 子弹图片

## ADDED Requirements

### Requirement: 角色配置表
系统应提供角色配置表，定义角色的基础属性参数。

#### Scenario: 配置表结构
- **WHEN** 查看 `characters.csv` 配置表
- **THEN** 表格包含以下字段：id, name, max_hp, move_speed, attack_power, attack_speed, bullet_speed

#### Scenario: 加载角色配置
- **WHEN** 创建角色实例时指定角色ID
- **THEN** 系统从配置表加载对应角色的属性参数

### Requirement: 角色基类
系统应提供 `Character` 角色基类，支持从配置表初始化属性。

#### Scenario: 属性初始化
- **WHEN** 调用 `Character.init_from_config("player_001")`
- **THEN** 角色属性从 `characters.csv` 中 id 为 "player_001" 的行加载

#### Scenario: 配置不存在
- **WHEN** 指定的角色ID在配置表中不存在
- **THEN** 系统使用默认属性并输出警告日志

### Requirement: 子弹类
系统应提供子弹类，实现 `IPoolable` 接口以支持对象池复用。

#### Scenario: 子弹飞行
- **WHEN** 子弹被发射后
- **THEN** 子弹以配置的速度沿发射方向直线飞行

#### Scenario: 子弹碰撞
- **WHEN** 子弹碰撞到物体
- **THEN** 子弹通过对象池回收并触发碰撞效果

#### Scenario: 对象池状态重置
- **WHEN** 子弹从对象池获取或归还时
- **THEN** 子弹状态被正确重置（位置、速度、方向等）

#### Scenario: 离开屏幕自动回收
- **WHEN** 子弹飞行离开屏幕可视区域
- **THEN** 子弹自动回收到对象池

### Requirement: 子弹管理器
系统应提供子弹管理器，封装子弹对象池操作。

#### Scenario: 发射子弹
- **WHEN** 调用 `BulletManager.spawn_bullet(position, direction, speed)`
- **THEN** 从对象池获取子弹实例并初始化飞行参数

#### Scenario: 回收子弹
- **WHEN** 子弹需要被回收时
- **THEN** 通过 `BulletManager` 将子弹归还对象池

### Requirement: 枪械组件
系统应提供枪械组件，实现枪口跟随鼠标旋转。

#### Scenario: 枪口跟随鼠标
- **WHEN** 鼠标移动时
- **THEN** 枪械图片围绕角色中心旋转，枪口始终指向鼠标位置

#### Scenario: 枪械位置
- **WHEN** 角色移动时
- **THEN** 枪械始终跟随角色，保持相对位置

#### Scenario: 发射子弹
- **WHEN** 玩家点击鼠标左键
- **THEN** 通过子弹管理器从枪口位置发射一颗子弹

### Requirement: 攻击速度控制
系统应根据配置的攻击速度控制射击频率。

#### Scenario: 攻击间隔
- **WHEN** 玩家连续点击鼠标
- **THEN** 受攻击速度限制，两次射击之间存在最小间隔

## MODIFIED Requirements
无

## REMOVED Requirements
无
