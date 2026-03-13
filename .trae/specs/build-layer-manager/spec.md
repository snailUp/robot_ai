# 层级管理系统 Spec

## Why
当前项目中游戏对象的层级管理分散且不规范，ZIndex 仅在预警线使用，节点添加位置不一致，缺乏 YSort 机制，导致渲染顺序不可控、角色遮挡问题、维护困难等问题。

## What Changes
- 创建层级常量类 `LayerConstants`，统一管理渲染层级和碰撞层级
- 创建层级管理器 `LayerManager`，提供统一的节点添加接口
- 重构场景结构，添加 YSort 支持和层级容器
- 修改现有代码使用新的层级管理系统

## Impact
- Affected specs: 无
- Affected code:
  - `framecore/layer/` (新建目录)
  - `framecore/battle/battle_arena.gd`
  - `framecore/battle/boss_battle_controller.gd`
  - `framecore/character/bullet_manager.gd`
  - `game/boss/angry_bull.gd`
  - `game/map/level/LevelMapScene.gd`

## ADDED Requirements

### Requirement: 层级常量定义
系统 SHALL 提供统一的层级常量定义，包括渲染层级和碰撞层级。

#### Scenario: 渲染层级定义
- **WHEN** 开发者需要设置对象的渲染层级
- **THEN** 可以使用预定义的 ZIndex 常量，如 `Z_BACKGROUND`、`Z_CHARACTER`、`Z_BULLET`、`Z_EFFECT` 等

#### Scenario: 碰撞层级定义
- **WHEN** 开发者需要设置对象的碰撞层级
- **THEN** 可以使用预定义的碰撞层常量，如 `COLLISION_PLAYER`、`COLLISION_ENEMY`、`COLLISION_BULLET` 等

### Requirement: 层级管理器
系统 SHALL 提供层级管理器，统一管理游戏对象的添加和层级设置。

#### Scenario: 添加角色到角色层
- **WHEN** 创建新的角色（玩家、敌人、Boss）
- **THEN** 通过 `LayerManager.add_character(node)` 添加到角色层

#### Scenario: 添加子弹到子弹层
- **WHEN** 创建新的子弹
- **THEN** 通过 `LayerManager.add_bullet(node)` 添加到子弹层

#### Scenario: 添加特效到特效层
- **WHEN** 创建新的特效（拖尾、爆炸等）
- **THEN** 通过 `LayerManager.add_effect(node)` 添加到特效层

### Requirement: YSort 支持
系统 SHALL 支持 YSort 排序，使角色按 Y 坐标自动排序。

#### Scenario: 角色按 Y 坐标排序
- **WHEN** 多个角色在同一层级
- **THEN** Y 坐标较小的角色渲染在上方，Y 坐标较大的角色渲染在下方

### Requirement: 场景层级结构
系统 SHALL 提供标准的场景层级结构。

#### Scenario: BattleArena 层级结构
- **WHEN** 创建战斗场景
- **THEN** 场景包含以下层级容器：
  - `BackgroundLayer` (z_index = -10)
  - `CharacterLayer` (YSort, z_index = 0)
  - `BulletLayer` (z_index = 10)
  - `EffectLayer` (z_index = 15)
  - `UILayer` (CanvasLayer, layer = 10)

## MODIFIED Requirements

### Requirement: 现有代码适配
现有代码 SHALL 使用新的层级管理系统。

#### Scenario: Boss 实例化
- **WHEN** BossBattleController 创建 Boss 实例
- **THEN** 使用 `LayerManager.add_character(boss)` 替代 `get_tree().current_scene.add_child(boss)`

#### Scenario: 特效创建
- **WHEN** AngryBull 创建 DashTrail 特效
- **THEN** 使用 `LayerManager.add_effect(trail)` 替代 `get_tree().current_scene.add_child(trail)`

#### Scenario: 子弹管理
- **WHEN** BulletManager 管理子弹
- **THEN** 子弹池和子弹实例添加到子弹层级容器
