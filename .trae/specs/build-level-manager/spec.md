# 关卡数据管理模块 Spec

## Why
需要一个通用的关卡数据管理模块，支持不同游戏复用。策划通过 CSV 表格配置关卡数据，管理器提供关卡进度、通关、解锁等功能。

## What Changes
- 新增 `LevelManager` 关卡管理器（Autoload）
- 新增关卡配置表 `levels.csv`（基础字段 + 展示字段）
- 新增章节配置表 `chapters.csv`
- 新增关卡进度存储结构
- 提供关卡数据访问、进度管理、通关处理等 API

## 关卡配置表字段

### levels.csv 字段
| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 关卡ID |
| chapter_id | int | 所属章节ID |
| name | string | 关卡名称 |
| difficulty | int | 难度等级 |
| scene_path | string | 场景路径 |
| description | string | 关卡描述 |
| icon | string | 图标路径 |
| background | string | 背景图路径 |

### chapters.csv 字段
| 字段 | 类型 | 说明 |
|------|------|------|
| id | int | 章节ID |
| name | string | 章节名称 |
| description | string | 章节描述 |
| icon | string | 图标路径 |
| levels | array | 包含的关卡ID列表 |

## Impact
- Affected specs: 无
- Affected code:
  - `framecore/level_manager.gd` - 关卡管理器
  - `resources/tables/levels.csv` - 关卡配置表
  - `resources/tables/chapters.csv` - 章节配置表
  - `SaveManager` - 进度持久化（复用现有）

## ADDED Requirements

### Requirement: 关卡数据访问
系统应提供关卡和章节数据的访问接口。

#### Scenario: 获取关卡数据
- **WHEN** 调用 `LevelManager.get_level(1001)`
- **THEN** 返回 ID 为 1001 的关卡配置字典

#### Scenario: 获取章节关卡
- **WHEN** 调用 `LevelManager.get_levels_by_chapter(1)`
- **THEN** 返回章节 1 的所有关卡数据数组

### Requirement: 当前进度管理
系统应提供当前关卡进度的管理功能。

#### Scenario: 获取当前关卡
- **WHEN** 调用 `LevelManager.get_current_level()`
- **THEN** 返回当前正在进行的关卡数据

#### Scenario: 获取下一关卡
- **WHEN** 调用 `LevelManager.get_next_level()`
- **THEN** 返回下一关数据，若已是最后一关返回空字典

### Requirement: 通关处理
系统应提供通关处理功能，包括记录成绩、解锁下一关。

#### Scenario: 通关关卡
- **WHEN** 调用 `LevelManager.complete_level(1001, 3, 1500)`
- **THEN** 记录关卡 1001 通关（3星，1500分），解锁下一关

#### Scenario: 更新最佳成绩
- **WHEN** 再次通关同一关卡且成绩更好
- **THEN** 更新最佳成绩记录

### Requirement: 解锁检查
系统应提供关卡解锁状态检查功能。

#### Scenario: 检查关卡解锁
- **WHEN** 调用 `LevelManager.is_level_unlocked(1002)`
- **THEN** 返回关卡 1002 是否已解锁

#### Scenario: 检查章节解锁
- **WHEN** 调用 `LevelManager.is_chapter_unlocked(2)`
- **THEN** 返回章节 2 是否已解锁

### Requirement: 进度持久化
系统应支持关卡进度的保存和加载。

#### Scenario: 保存进度
- **WHEN** 调用 `LevelManager.save_progress()`
- **THEN** 将当前进度保存到 SaveManager

#### Scenario: 加载进度
- **WHEN** 游戏启动时
- **THEN** 自动从 SaveManager 加载关卡进度

### Requirement: 可配置性
系统应支持不同游戏复用，关卡表名可配置。

#### Scenario: 配置关卡表名
- **WHEN** 设置 `LevelManager.levels_table_name = "my_levels"`
- **THEN** 从 `my_levels.csv` 加载关卡数据

## MODIFIED Requirements
无

## REMOVED Requirements
无
