# 角色受伤效果实现计划

## 目标
实现角色受伤时的三种画面效果：
1. 角色闪烁效果
2. 屏幕震动效果
3. 红色边缘/晕影效果

## 实现步骤

### 1. 创建红色晕影效果组件
**文件：** 新建 `game/effect/damage_vignette.gd`

创建一个全屏覆盖层，用于显示红色边缘效果：
- 使用 ColorRect 节点
- 支持 Shader 实现渐变晕影效果
- 提供显示/隐藏动画方法

### 2. 创建红色晕影效果场景
**文件：** 新建 `resources/prefabs/effect/damage_vignette.tscn`

- 根节点为 CanvasLayer（确保在最上层显示）
- 包含 ColorRect 子节点
- 配置 Shader 实现边缘渐变效果

### 3. 修改 Player 类添加受伤效果
**文件：** `game/character/player.gd`

在 `take_damage()` 方法中添加：
- 调用闪烁效果函数
- 调用屏幕震动效果函数
- 调用红色晕影效果函数

### 4. 实现闪烁效果
**位置：** `game/character/player.gd`

添加 `_play_damage_flash()` 函数：
- 使用 Tween 控制 `modulate` 属性
- 快速在白色/红色和原色之间切换
- 闪烁 2-3 次后恢复

### 5. 实现屏幕震动效果
**位置：** `game/character/player.gd`

添加 `_play_camera_shake()` 函数：
- 获取 Camera2D 节点引用
- 使用 Tween 控制 `offset` 属性随机偏移
- 震动持续 0.2-0.3 秒后恢复

### 6. 实现红色晕影效果
**位置：** `game/character/player.gd`

添加晕影效果显示：
- 在 _ready 中实例化晕影场景
- 受伤时显示晕影效果
- 使用 Tween 控制透明度渐变

## 实现细节

### 闪烁效果代码示例
```gdscript
func _play_damage_flash() -> void:
    var tween = create_tween()
    for i in range(3):
        tween.tween_property(animated_sprite, "modulate", Color.RED, 0.05)
        tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.05)
    tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)
```

### 屏幕震动代码示例
```gdscript
func _play_camera_shake() -> void:
    var camera = get_node_or_null("Camera2D")
    if camera == null:
        return
    
    var tween = create_tween()
    var original_offset = camera.offset
    for i in range(5):
        var shake_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
        tween.tween_property(camera, "offset", shake_offset, 0.03)
    tween.tween_property(camera, "offset", original_offset, 0.05)
```

### 红色晕影代码示例
```gdscript
func _show_damage_vignette() -> void:
    if _vignette == null:
        return
    
    var tween = create_tween()
    tween.tween_property(_vignette, "modulate:a", 0.5, 0.1)
    tween.tween_interval(0.2)
    tween.tween_property(_vignette, "modulate:a", 0.0, 0.3)
```

## 注意事项
1. 确保效果不会相互干扰
2. 效果持续时间要短，不影响游戏体验
3. 晕影效果需要在 UI 层显示，不被其他元素遮挡
4. 震动强度要适中，不要让玩家感到不适
