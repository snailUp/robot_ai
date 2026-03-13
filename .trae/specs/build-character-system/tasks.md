# Tasks

- [x] Task 1: 创建角色配置表
  - [x] SubTask 1.1: 创建 `resources/tables/characters.csv` 配置表文件
  - [x] SubTask 1.2: 定义配置表字段：id, name, max_hp, move_speed, attack_power, attack_speed, bullet_speed

- [x] Task 2: 创建角色基类 Character
  - [x] SubTask 2.1: 创建 `framecore/character/` 目录
  - [x] SubTask 2.2: 创建 `character.gd` 角色基类，包含基础属性和配置加载方法
  - [x] SubTask 2.3: 实现 `init_from_config()` 方法从配置表加载属性

- [x] Task 3: 创建子弹类 Bullet（实现IPoolable接口）
  - [x] SubTask 3.1: 创建 `bullet.gd` 子弹类，继承 Area2D
  - [x] SubTask 3.2: 实现 `IPoolable` 接口的 `reset_state()` 方法
  - [x] SubTask 3.3: 实现子弹飞行逻辑（`_physics_process`）
  - [x] SubTask 3.4: 实现碰撞检测，碰撞后通知管理器回收
  - [x] SubTask 3.5: 实现离开屏幕自动回收（使用 `VisibilityNotifier2D`）
  - [x] SubTask 3.6: 创建子弹场景文件 `bullet.tscn`

- [x] Task 4: 创建子弹管理器 BulletManager
  - [x] SubTask 4.1: 创建 `bullet_manager.gd` 子弹管理器
  - [x] SubTask 4.2: 封装 ObjectPool，管理子弹对象池
  - [x] SubTask 4.3: 实现 `spawn_bullet(position, direction, speed)` 方法
  - [x] SubTask 4.4: 实现 `recycle_bullet(bullet)` 方法

- [x] Task 5: 创建枪械组件 Gun
  - [x] SubTask 5.1: 创建 `gun.gd` 枪械组件，继承 Node2D
  - [x] SubTask 5.2: 实现枪口跟随鼠标旋转（`_process` 中计算角度）
  - [x] SubTask 5.3: 实现子弹发射逻辑，调用 BulletManager
  - [x] SubTask 5.4: 实现攻击速度控制（冷却时间）
  - [x] SubTask 5.5: 创建枪械场景文件 `gun.tscn`

- [x] Task 6: 重构 MapPlayer 继承 Character
  - [x] SubTask 6.1: 修改 `map_player.gd` 继承 Character 基类
  - [x] SubTask 6.2: 添加枪械组件到玩家场景
  - [x] SubTask 6.3: 添加子弹管理器到场景
  - [x] SubTask 6.4: 更新 `LevelMapScene.tscn` 场景

- [x] Task 7: 测试验证
  - [x] SubTask 7.1: 运行项目验证角色属性从配置表加载
  - [x] SubTask 7.2: 验证枪口跟随鼠标功能
  - [x] SubTask 7.3: 验证子弹发射和飞行功能
  - [x] SubTask 7.4: 验证子弹对象池复用功能

# Task Dependencies
- [Task 3] depends on [Task 1]
- [Task 4] depends on [Task 3]
- [Task 5] depends on [Task 4]
- [Task 6] depends on [Task 2, Task 5]
- [Task 7] depends on [Task 6]
