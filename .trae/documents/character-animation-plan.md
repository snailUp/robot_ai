# 角色控制动画实现计划

## 目标
为 MapPlayer 角色添加走路(walk)和待机(idle)两个帧动画，并实现角色转向功能。

## 资源情况
- **走路动画**: `resources/animation/character/walk/` - 16帧
- **待机动画**: `resources/animation/character/idle/` - 30帧

## 实施步骤

### 1. 创建 SpriteFrames 资源
- 创建 `resources/animation/character/character_frames.tres`
- 添加 `idle` 动画：加载 idle 目录下的所有帧（按文件名排序）
- 添加 `walk` 动画：加载 walk 目录下的所有帧（按文件名排序）
- 设置动画速度为 10 FPS

### 2. 修改 MapPlayer 代码
更新 `map_player.gd`：
- 将 `Sprite2D` 改为 `AnimatedSprite2D`
- **角色转向逻辑**：
  - 向左移动时：`flip_h = true`（水平翻转）
  - 向右移动时：`flip_h = false`（正常方向）
  - 停止时保持当前朝向
- 动画播放：
  - 移动时播放 `walk`
  - 停止时播放 `idle`

### 3. 更新 LevelMapScene.tscn
- 将 `Sprite2D` 节点替换为 `AnimatedSprite2D`
- 移除 `AnimationPlayer` 节点（不再需要）
- 配置 `AnimatedSprite2D` 使用创建的 SpriteFrames 资源

## 角色转向逻辑
```
移动方向 X < 0 → 角色朝左 → flip_h = true
移动方向 X > 0 → 角色朝右 → flip_h = false
移动方向 X = 0 → 保持当前朝向
```

## 文件变更清单
1. `framecore/map/map_player.gd` - 修改动画播放和转向逻辑
2. `resources/animation/character/character_frames.tres` - 新建 SpriteFrames 资源
3. `resources/map/level/LevelMapScene.tscn` - 更新场景结构
