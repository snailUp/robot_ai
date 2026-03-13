# 角色闪躲功能实现计划

## 功能需求

### 核心功能
- **触发方式**：按空格键触发
- **移动方式**：朝当前移动方向快速移动（瞬移效果）
- **无敌帧**：闪躲期间无敌，不受伤害
- **拖尾效果**：生成角色残影的拖尾效果

### 参考实现
Boss 已有类似功能（`angry_bull.gd` 的 dash 功能），可以复用相关逻辑。

---

## 实现方案

### 方案概述
1. 创建新的拖尾特效 `player_dash_trail`（视觉残影）
2. 在 `player.gd` 中添加闪躲状态机
3. 使用 `EffectManager` 生成拖尾
4. 通过 `collision_mask = 0` 实现无敌帧

---

## 实现步骤

### Step 1: 创建玩家闪躲拖尾特效

#### 1.1 创建脚本文件 `game/effect/player_dash_trail.gd`
```gdscript
class_name PlayerDashTrail
extends Sprite2D

## 玩家闪躲拖尾：显示角色残影的视觉效果
## 持续一段时间后淡出销毁

## 持续时间（秒）
@export var duration: float = 0.3

## 初始透明度
@export var initial_alpha: float = 0.5

## 计时器
var _timer: float = 0.0


func _ready() -> void:
	modulate.a = initial_alpha


func _process(delta: float) -> void:
	if _timer <= 0:
		return

	_timer -= delta

	# 淡出效果
	modulate.a = initial_alpha * (_timer / duration)

	# 时间到，销毁
	if _timer <= 0:
		queue_free()


## 特效初始化
func on_spawn() -> void:
	_timer = duration
	modulate.a = initial_alpha


## 设置特效参数
func set_params(params: Dictionary) -> void:
	if params.has("duration"):
		duration = params["duration"]

	if params.has("initial_alpha"):
		initial_alpha = params["initial_alpha"]

	if params.has("texture"):
		texture = params["texture"]

	if params.has("flip_h"):
		flip_h = params["flip_h"]

	if params.has("scale"):
		scale = params["scale"]
```

#### 1.2 创建场景文件 `resources/prefabs/effect/player_dash_trail.tscn`
```gd_scene
[gd_scene format=3]

[ext_resource type="Script" path="res://game/effect/player_dash_trail.gd" id="1"]

[node name="PlayerDashTrail" type="Sprite2D"]
script = ExtResource("1")
z_index = 4  # Z_CHARACTER - 1，在角色下方
```

---

### Step 2: 修改 player.gd 添加闪躲功能

#### 2.1 添加闪躲相关变量（在类开头）
```gdscript
## 闪躲输入动作名称
@export var dodge_action: String = "ui_accept"

## 闪躲距离
@export var dodge_distance: float = 150.0

## 闪躲持续时间（秒）
@export var dodge_duration: float = 0.2

## 闪躲冷却时间（秒）
@export var dodge_cooldown: float = 1.0

## 拖尾生成间隔（秒）
@export var trail_interval: float = 0.03

## 是否正在闪躲
var is_dodging: bool = false

## 闪躲计时器
var _dodge_timer: float = 0.0

## 闪躲冷却计时器
var _dodge_cooldown_timer: float = 0.0

## 拖尾生成计时器
var _trail_timer: float = 0.0

## 闪躲前的碰撞掩码（用于恢复）
var _original_collision_mask: int = 0
```

#### 2.2 修改 `_physics_process` 添加闪躲处理
```gdscript
func _physics_process(delta: float) -> void:
	# 更新闪躲冷却
	_update_dodge_cooldown(delta)

	# 处理闪躲输入
	_handle_dodge_input()

	var direction = _get_input_direction()

	# 闪躲中时，使用闪躲移动逻辑
	if is_dodging:
		_process_dodge(delta)
	else:
		# 正常移动
		if direction.length() > 0:
			velocity = direction * move_speed
			_is_moving = true
			_update_facing_direction(direction)
		else:
			velocity = Vector2.ZERO
			_is_moving = false

	super._physics_process(delta)
	_update_animation()
	_handle_fire_input()
```

#### 2.3 添加闪躲输入处理方法
```gdscript
## 处理闪躲输入
func _handle_dodge_input() -> void:
	if is_dodging or _dodge_cooldown_timer > 0:
		return

	var dodge_pressed: bool = false
	if dodge_action != "" and InputMap.has_action(dodge_action):
		dodge_pressed = Input.is_action_just_pressed(dodge_action)

	if dodge_pressed:
		_start_dodge()
```

#### 2.4 添加闪躲开始方法
```gdscript
## 开始闪躲
func _start_dodge() -> void:
	var direction = _get_input_direction()

	# 如果没有移动方向，默认向右
	if direction == Vector2.ZERO:
		direction = Vector2.RIGHT

	is_dodging = true
	_dodge_timer = dodge_duration
	_trail_timer = 0.0

	# 保存原始碰撞掩码并设置为无敌
	_original_collision_mask = collision_mask
	collision_mask = 0

	# 计算闪躲速度（距离 / 时间）
	var dodge_speed = dodge_distance / dodge_duration
	velocity = direction * dodge_speed

	# 更新朝向
	_update_facing_direction(direction)

	print("[Player] 开始闪躲，方向: ", direction)
```

#### 2.5 添加闪躲处理方法
```gdscript
## 处理闪躲状态
func _process_dodge(delta: float) -> void:
	_dodge_timer -= delta

	# 生成拖尾
	_spawn_trail(delta)

	# 闪躲结束
	if _dodge_timer <= 0:
		_end_dodge()
```

#### 2.6 添加闪躲结束方法
```gdscript
## 结束闪躲
func _end_dodge() -> void:
	is_dodging = false
	_dodge_cooldown_timer = dodge_cooldown
	velocity = Vector2.ZERO

	# 恢复碰撞掩码
	collision_mask = _original_collision_mask

	print("[Player] 闪躲结束")
```

#### 2.7 添加拖尾生成方法
```gdscript
## 生成闪躲拖尾
func _spawn_trail(delta: float) -> void:
	_trail_timer += delta

	if _trail_timer >= trail_interval:
		_trail_timer = 0.0

		# 获取当前动画帧纹理
		var texture = null
		if animated_sprite and animated_sprite.sprite_frames:
			var animation_name = animated_sprite.animation
			var frame = animated_sprite.frame
			texture = animated_sprite.sprite_frames.get_frame_texture(animation_name, frame)

		EffectManager.spawn("player_dash_trail", {
			"position": global_position,
			"duration": 0.3,
			"initial_alpha": 0.5,
			"texture": texture,
			"flip_h": animated_sprite.flip_h if animated_sprite else false,
			"scale": scale
		})
```

#### 2.8 添加冷却更新方法
```gdscript
## 更新闪躲冷却
func _update_dodge_cooldown(delta: float) -> void:
	if _dodge_cooldown_timer > 0:
		_dodge_cooldown_timer -= delta
```

#### 2.9 修改 `take_damage` 方法，闪躲时不受伤害
```gdscript
## 受到伤害
func take_damage(amount: int) -> void:
	if is_dodging:
		print("[Player] 闪躲中，免疫伤害")
		return

	current_hp = max(0, current_hp - amount)
	print("[Player] 受到伤害: " + str(amount) + ", 剩余HP: " + str(current_hp))

	# 检查是否死亡
	if current_hp <= 0:
		die()
```

---

### Step 3: 注册特效到 EffectManager

#### 3.1 在 `game/map/level/LevelMapScene.gd` 中注册
```gdscript
EffectManager.register_type("player_dash_trail", "res://resources/prefabs/effect/player_dash_trail.tscn", 20)
```

---

### Step 4: 可选优化

#### 4.1 添加闪躲动画（如果有资源）
```gdscript
@export var dodge_animation: String = "dodge"

# 在 _start_dodge() 中
if animated_sprite and animated_sprite.sprite_frames.has_animation(dodge_animation):
	animated_sprite.play(dodge_animation)
```

#### 4.2 添加闪躲音效
```gdscript
# 在 _start_dodge() 中
AudioManager.play_sfx("dodge")
```

---

## 技术细节

### 无敌帧实现
- 通过设置 `collision_mask = 0` 使角色不检测任何碰撞
- 闪躲结束后恢复原始 `collision_mask`

### 拖尾效果
- 使用 `Sprite2D` 显示角色当前帧的纹理
- 通过 `modulate.a` 实现淡出效果
- 间隔生成多个残影形成拖尾

### 移动逻辑
- 闪躲时覆盖正常移动逻辑
- 使用固定距离和持续时间计算速度
- 保持朝向一致

---

## 需要修改的文件

| 文件 | 操作 | 说明 |
|------|------|------|
| `game/effect/player_dash_trail.gd` | 新建 | 拖尾特效脚本 |
| `resources/prefabs/effect/player_dash_trail.tscn` | 新建 | 拖尾特效场景 |
| `game/character/player.gd` | 修改 | 添加闪躲功能 |
| `game/map/level/LevelMapScene.gd` | 修改 | 注册特效 |

---

## 测试验证

1. 按空格键触发闪躲
2. 角色朝移动方向快速移动
3. 闪躲期间受到攻击不扣血
4. 拖尾残影正确显示并淡出
5. 冷却时间正常工作
6. 闪躲结束后恢复正常状态
