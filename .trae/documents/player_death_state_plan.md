# 玩家死亡状态实现计划

## 目标
在玩家（Player）角色中增加死亡状态，进入死亡状态时：
1. 播放 die 动画
2. 关闭枪械（停止射击）
3. 锁定角色控制（无法移动）

## 现有结构分析

### Player 类 (`game/character/player.gd`)
- `die()` 函数：当前只打印日志，没有实际处理
- `weapon` 变量：持有武器实例
- 移动控制：通过输入处理

### 动画系统
- 使用 AnimatedSprite2D 或类似组件播放动画

## 实现步骤

### 步骤 1：修改 die() 函数
**文件**: `game/character/player.gd`

```gdscript
func die() -> void:
    print("[Player] 玩家死亡")
    
    # 1. 锁定角色控制
    set_process_input(false)
    set_physics_process(false)
    
    # 2. 关闭枪械（停止射击）
    if weapon != null:
        weapon.set_deferred("enabled", false)
    
    # 3. 播放死亡动画
    if animated_sprite != null:
        if animated_sprite.sprite_frames.has_animation("die"):
            animated_sprite.play("die")
```

### 步骤 2：确保动画组件存在
检查 Player 场景中是否有动画组件，如果没有需要添加。

## 文件修改清单

| 文件 | 操作 |
|------|------|
| `game/character/player.gd` | 修改 die() 函数 |

## 技术细节

### 锁定角色控制
- `set_process_input(false)` - 停止接收输入事件
- `set_physics_process(false)` - 停止物理处理

### 关闭枪械
- `weapon.set_deferred("enabled", false)` - 延迟设置武器禁用状态

### 播放死亡动画
- 检查动画组件是否存在
- 检查 die 动画是否存在
- 播放动画

## 注意事项
- 使用 `set_deferred` 确保在安全时机修改属性
- 死亡后可能需要显示游戏结束界面（后续任务）
