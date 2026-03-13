# Boss 战斗逻辑调整计划

## 需求确认

### 1. 冲刺距离调整
- **随机距离**： 200-600像素
- **不撞墙**： 冲刺固定距离后自动停止
- **保留撞墙机制**： 撞墙后仍反弹

### 2. 三种攻击方式
- **选择方式**： 随机选择
- **攻击类型**：
  1. **简单冲撞** - 向玩家方向冲刺固定距离
  2. **踩踏攻击** - 冲刺到玩家附近，执行踩踏动画
  3. **冲撞+弹幕** - 冲刺后从Boss位置发射弹幕（普通3发/狂暴5发)
### 3. 弹幕配置
- **发射位置**： Boss位置
- **弹幕资源**： `img_zd2.png`
- **弹幕数量**： 普通3发 / 狂暴5发

---

## 详细设计

### 1. 冲刺距离调整
- **随机距离**： 200-600像素
- **不撞墙**： 冲刺固定距离后自动停止
- **保留撞墙机制**： 撞墙后仍反弹

### 2. 三种攻击方式
- **选择方式**： 随机选择
- **攻击类型**：
  1. **简单冲撞** - 向玩家方向冲刺固定距离
  2. **踩踏攻击** - 冲刺到玩家附近，执行踩踏动画
  3. **冲撞+弹幕** - 冲刺后从Boss位置发射弹幕（普通3发/狂暴5发)
### 3. 弹幕配置
- **发射位置**： Boss位置
- **弹幕资源**： `img_zd2.png`
- **弹幕数量**： 普通3发 / 狂暴5发

---

## 实现步骤

### Step 1: 添加攻击类型枚举
在 `angry_bull.gd` 中添加攻击类型枚举：
```gdscript
enum AttackType {
    SIMPLE_DASH,      # 简单冲撞
    STOMP_ATTACK,      # 踩踏攻击
    DASH_AND_BULLETS   # 冲撞+弹幕
}
```

### Step 2: 添加冲刺距离相关变量
```gdscript
# 冲刺距离范围
var dash_distance_min: float = 200.0
var dash_distance_max: float = 600.0

# 当前冲刺目标距离
var _current_dash_distance: float = 300.0

# 已冲刺距离
var _dashed_distance: float = 0.0
```
### Step 3: 修改状态机 - 添加攻击选择状态
在 Telegraphing 状态结束后，随机选择攻击类型：
```gdscript
func _on_telegraphing_exited() -> void:
    # 随机选择攻击类型
    _select_random_attack_type()
    
    # 随机生成冲刺距离
    _current_dash_distance = randf_range(dash_distance_min, dash_distance_max)
```
### Step 4: 修改 Dashing 状态逻辑
```gdscript
func _perform_dash(delta: float) -> void:
    var speed = dash_speed
    if is_enraged:
        speed *= phase2_speed_multiplier
    
    var motion = dash_direction * speed * delta
    _dashed_distance += motion.length()
    
    # 检查是否达到目标距离
    if _dashed_distance >= _current_dash_distance:
        # 停止冲刺
        velocity = Vector2.ZERO
        state_chart.send_event(&"dash_complete")
        return
    
    # 执行移动并检测撞墙
    var collision = move_and_collide(motion)
    if collision != null:
        _handle_bounce(collision)
    
    # 检测玩家碰撞
    _check_player_collision()
```
### Step 5: 添加新状态 DashComplete
用于处理冲刺完成后的逻辑（踩踏攻击或发射弹幕）：
```gdscript
func _on_dash_complete_entered() -> void:
    current_state_name = "DashComplete"
    
    match _current_attack_type:
        AttackType.STOMP_ATTACK:
            _execute_stomp_attack()
        AttackType.DASH_AND_BULLETS:
            _fire_bullets()
        _:
            # 简单冲撞，进入 Falling
            state_chart.send_event(&"falling")
```
### Step 6: 实现踩踏攻击
```gdscript
func _execute_stomp_attack() -> void:
    # 播放踩踏动画
    _play_animation("attack")
    
    # 等待动画完成后进入 Falling
    await get_tree().create_timer(0.5).timeout
    state_chart.send_event(&"falling")
```
### Step 7: 实现弹幕发射
```gdscript
func _fire_bullets() -> void:
    if bullet_manager == null:
        return
    
    var count = 3
    if is_enraged:
        count = 5
    
    var angle_step = TAU / count
    for i in range(count):
        var angle = i * angle_step
        var direction = Vector2.RIGHT.rotated(angle)
        
        var bullet = bullet_manager.acquire_bullet()
        if bullet != null:
            bullet.global_position = global_position
            bullet.set_direction(direction)
            bullet.speed = 300.0
            bullet.damage = damage / 2
```
### Step 8: 修改状态机配置
在 `angry_bull.tscn` 中添加新状态：
- 添加 DashComplete 状态
- 添加相应过渡

### Step 9: 更新弹幕资源
创建新的弹幕场景使用 `img_zd2.png`：
```gdscript
# 在 BulletManager 或 Bullet 场景中设置新纹理
bullet.texture = preload("res://resources/sprites/map/img_zd2.png")
```
---

## 需要修改的文件

| 文件 | 操作 |
|------|------|
| `game/boss/angry_bull.gd` | 添加攻击类型、冲刺距离、修改状态逻辑 |
| `resources/prefabs/boss/angry_bull.tscn` | 添加 DashComplete 状态 |
| `resources/prefabs/bullet/bullet.tscn` | 更新弹幕纹理（可选） |

---

## 测试验证
1. Boss 冲刺距离在 200-600 像素范围内
2. 三种攻击方式随机触发
3. 踩踏攻击动画正确播放
4. 弹幕正确发射（普通3发/狂暴5发）
5. 撞墙反弹机制仍然有效
