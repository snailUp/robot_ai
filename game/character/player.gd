class_name Player
extends Character
## 玩家控制器：处理玩家输入、移动、动画和射击
## 继承 Character 基类，使用角色配置表加载属性

## 角色配置ID
@export var character_config_id: String = "player_001"

## 移动输入动作名称
@export var move_up_action: String = "ui_up"
@export var move_down_action: String = "ui_down"
@export var move_left_action: String = "ui_left"
@export var move_right_action: String = "ui_right"

## 射击输入
@export var fire_action: String = "fire"

## 动画名称
@export var idle_animation: String = "idle"
@export var walk_animation: String = "walk"

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

## 武器组件
var weapon: WeaponBase = null

## 子弹管理器
var bullet_manager: BulletManager = null

## 动画精灵
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

## 血条组件
@onready var _health_bar: HealthBar = $HealthBar

## 是否正在移动
var _is_moving: bool = false

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

## 是否已死亡
var _is_dead: bool = false

## 受伤效果
var _camera: Camera2D = null
var _original_camera_offset: Vector2 = Vector2.ZERO


func _ready() -> void:
	add_to_group("player")
	init_from_config(character_config_id)
	
	collision_layer = LayerConstants.COLLISION_PLAYER
	collision_mask = LayerConstants.COLLISION_ENEMY_BULLET | LayerConstants.COLLISION_OBSTACLE
	
	if animated_sprite:
		animated_sprite.play(idle_animation)
	
	_setup_components()
	_setup_camera()
	
	hp_changed.connect(_on_hp_changed)
	
	if _health_bar:
		_health_bar.update_position(global_position)


## 初始化组件
func _setup_components() -> void:
	var weapon_node = get_node_or_null("Gun")
	if weapon_node and weapon_node is WeaponBase:
		weapon = weapon_node
		weapon.set_attack_speed(attack_speed)
		weapon.damage = attack_power
	
	var bm_node = get_node_or_null("BulletManager")
	if bm_node and bm_node is BulletManager:
		bullet_manager = bm_node
	
	if weapon and bullet_manager and weapon.has_method("set_bullet_manager"):
		weapon.set_bullet_manager(bullet_manager)


## 初始化摄像机
func _setup_camera() -> void:
	_camera = get_node_or_null("Camera2D")
	if _camera:
		_original_camera_offset = _camera.offset


func _physics_process(delta: float) -> void:
	_update_dodge_cooldown(delta)
	_handle_dodge_input()

	var direction = _get_input_direction()

	if is_dodging:
		_process_dodge(delta)
	else:
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
	_update_health_bar_position()


## 获取输入方向
func _get_input_direction() -> Vector2:
	var direction = Vector2.ZERO
	
	if Input.is_action_pressed(move_up_action):
		direction.y -= 1
	if Input.is_action_pressed(move_down_action):
		direction.y += 1
	if Input.is_action_pressed(move_left_action):
		direction.x -= 1
	if Input.is_action_pressed(move_right_action):
		direction.x += 1
	
	return direction.normalized()


## 更新朝向
func _update_facing_direction(direction: Vector2) -> void:
	if animated_sprite and direction.x != 0:
		animated_sprite.flip_h = direction.x < 0


## 更新动画
func _update_animation() -> void:
	if not animated_sprite:
		return
	
	var target_anim = idle_animation if not _is_moving else walk_animation
	if animated_sprite.animation != target_anim:
		animated_sprite.play(target_anim)


## 处理射击输入
func _handle_fire_input() -> void:
	var fire_pressed: bool = false

	if fire_action != "" and InputMap.has_action(fire_action):
		fire_pressed = Input.is_action_just_pressed(fire_action)

	if fire_pressed or Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		if weapon:
			weapon.try_fire()


## 处理闪躲输入
func _handle_dodge_input() -> void:
	if is_dodging or _dodge_cooldown_timer > 0:
		return

	var dodge_pressed: bool = false
	if dodge_action != "" and InputMap.has_action(dodge_action):
		dodge_pressed = Input.is_action_just_pressed(dodge_action)

	if dodge_pressed:
		_start_dodge()


## 开始闪躲
func _start_dodge() -> void:
	var direction = _get_input_direction()

	if direction == Vector2.ZERO:
		if animated_sprite and animated_sprite.flip_h:
			direction = Vector2.LEFT
		else:
			direction = Vector2.RIGHT

	is_dodging = true
	_dodge_timer = dodge_duration
	_trail_timer = 0.0

	_original_collision_mask = collision_mask
	collision_mask = LayerConstants.COLLISION_OBSTACLE

	var dodge_speed = dodge_distance / dodge_duration
	velocity = direction * dodge_speed

	_update_facing_direction(direction)

	print("[Player] 开始闪躲，方向: ", direction)


## 处理闪躲状态
func _process_dodge(delta: float) -> void:
	_dodge_timer -= delta

	_spawn_trail(delta)

	if _dodge_timer <= 0:
		_end_dodge()


## 结束闪躲
func _end_dodge() -> void:
	is_dodging = false
	_dodge_cooldown_timer = dodge_cooldown
	velocity = Vector2.ZERO

	collision_mask = _original_collision_mask

	print("[Player] 闪躲结束")


## 生成闪躲拖尾
func _spawn_trail(delta: float) -> void:
	_trail_timer += delta

	if _trail_timer >= trail_interval:
		_trail_timer = 0.0

		var texture = null
		var sprite_scale = Vector2.ONE
		if animated_sprite and animated_sprite.sprite_frames:
			var animation_name = animated_sprite.animation
			var frame = animated_sprite.frame
			texture = animated_sprite.sprite_frames.get_frame_texture(animation_name, frame)
			sprite_scale = animated_sprite.scale

		EffectManager.spawn("player_dash_trail", {
			"position": global_position,
			"duration": 0.3,
			"initial_alpha": 0.5,
			"texture": texture,
			"flip_h": animated_sprite.flip_h if animated_sprite else false,
			"scale": sprite_scale
		})


## 更新闪躲冷却
func _update_dodge_cooldown(delta: float) -> void:
	if _dodge_cooldown_timer > 0:
		_dodge_cooldown_timer -= delta


## 更新血条位置
func _update_health_bar_position() -> void:
	if _health_bar:
		_health_bar.update_position(global_position)


## 血量变化回调
func _on_hp_changed(current: int, maximum: int) -> void:
	if _health_bar:
		_health_bar.set_hp(current, maximum)


## 受到伤害
## @param amount: 伤害数值
func take_damage(amount: int) -> void:
	if _is_dead:
		return
	
	if is_dodging:
		print("[Player] 闪躲中，免疫伤害")
		return
	
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, max_hp)
	#_spawn_damage_number(amount)
	
	# 播放受伤效果
	_play_damage_effects()
	
	print("[Player] 受到伤害: " + str(amount) + ", 剩余HP: " + str(current_hp))
	
	if current_hp <= 0:
		die()


## 播放受伤效果
func _play_damage_effects() -> void:
	_play_damage_flash()
	_play_camera_shake()
	_show_damage_vignette()


## 闪烁效果
func _play_damage_flash() -> void:
	if animated_sprite == null:
		return
	
	var tween = create_tween()
	for i in range(3):
		tween.tween_property(animated_sprite, "modulate", Color.RED, 0.05)
		tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.05)
	tween.tween_property(animated_sprite, "modulate", Color.WHITE, 0.1)


## 屏幕震动效果
func _play_camera_shake() -> void:
	if _camera == null:
		return
	
	var tween = create_tween()
	var shake_count = 5
	var shake_intensity = 6.0
	
	for i in range(shake_count):
		var shake_offset = Vector2(
			randf_range(-shake_intensity, shake_intensity),
			randf_range(-shake_intensity, shake_intensity)
		)
		tween.tween_property(_camera, "offset", _original_camera_offset + shake_offset, 0.03)
	
	tween.tween_property(_camera, "offset", _original_camera_offset, 0.05)


## 显示红色晕影效果
func _show_damage_vignette() -> void:
	GameEventBus.damage_vignette_requested.emit(0.5, 0.3)


## 生成伤害飘字
#func _spawn_damage_number(amount: int) -> void:
	#var font_size = clamp(amount, 40, 46)
	#EffectManager.spawn("damage_number", {
		#"position": global_position + Vector2(0, -50),
		#"value": -amount,
		#"color": Color.RED,
		#"font_size": font_size
	#})


## 死亡处理
func die() -> void:
	if _is_dead:
		return
	
	_is_dead = true
	print("[Player] 玩家死亡")
	
	# 1. 锁定角色控制
	set_process(false)
	set_physics_process(false)
	
	# 2. 隐藏枪械
	if weapon != null:
		weapon.visible = false
	
	# 3. 隐藏血量条
	if _health_bar != null:
		_health_bar.visible = false
	
	# 4. 播放死亡动画
	if animated_sprite != null and animated_sprite.sprite_frames != null:
		if animated_sprite.sprite_frames.has_animation("die"):
			animated_sprite.play("die")
			# 动画播放完成后停在最后一帧
			if animated_sprite.animation_finished.is_connected(_on_die_animation_finished):
				animated_sprite.animation_finished.disconnect(_on_die_animation_finished)
			animated_sprite.animation_finished.connect(_on_die_animation_finished)


## 死亡动画完成回调
func _on_die_animation_finished() -> void:
	if animated_sprite != null:
		return
	
	# 停在最后一帧
	animated_sprite.stop()
	animated_sprite.frame = animated_sprite.sprite_frames.get_frame_count("die") - 1
