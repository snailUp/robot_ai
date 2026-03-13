# Tasks

- [x] Task 1: 创建层级常量类 LayerConstants
  - [x] SubTask 1.1: 创建 `framecore/layer/` 目录
  - [x] SubTask 1.2: 创建 `layer_constants.gd`，定义渲染层级常量（Z_BACKGROUND, Z_FLOOR, Z_CHARACTER, Z_BULLET, Z_EFFECT, Z_WARNING, Z_UI）
  - [x] SubTask 1.3: 定义碰撞层级常量（COLLISION_PLAYER, COLLISION_ENEMY, COLLISION_PLAYER_BULLET, COLLISION_ENEMY_BULLET, COLLISION_OBSTACLE）
  - [x] SubTask 1.4: 定义碰撞预设配置函数（get_player_collision, get_enemy_collision, get_player_bullet_collision 等）

- [x] Task 2: 创建层级管理器 LayerManager
  - [x] SubTask 2.1: 创建 `layer_manager.gd`，实现单例模式
  - [x] SubTask 2.2: 实现 `setup(root: Node2D)` 初始化方法，创建层级容器节点
  - [x] SubTask 2.3: 实现 `add_character(node)`, `add_bullet(node)`, `add_effect(node)` 方法
  - [x] SubTask 2.4: 实现 `get_character_layer()`, `get_bullet_layer()`, `get_effect_layer()` 获取方法
  - [x] SubTask 2.5: 实现 YSort 角色层支持

- [x] Task 3: 重构 BattleArena 场景结构
  - [x] SubTask 3.1: 在 BattleArena 中创建标准层级容器节点
  - [x] SubTask 3.2: 设置各容器的 z_index
  - [x] SubTask 3.3: 为角色层添加 YSort 功能
  - [x] SubTask 3.4: 在 _ready 中调用 LayerManager.setup()

- [x] Task 4: 重构现有代码使用层级管理器
  - [x] SubTask 4.1: 修改 `boss_battle_controller.gd` 使用 LayerManager.add_character() 添加 Boss
  - [x] SubTask 4.2: 修改 `angry_bull.gd` 使用 LayerManager.add_effect() 添加 DashTrail
  - [x] SubTask 4.3: 修改 `bullet_manager.gd` 使用 LayerManager 管理子弹
  - [x] SubTask 4.4: 修改 `LevelMapScene.gd` 使用 LayerManager 管理层级

- [x] Task 5: 验证和测试
  - [x] SubTask 5.1: 运行项目验证层级渲染正确
  - [x] SubTask 5.2: 验证 YSort 角色排序正常工作
  - [x] SubTask 5.3: 验证碰撞层级配置正确

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 2]
- [Task 4] depends on [Task 3]
- [Task 5] depends on [Task 4]
