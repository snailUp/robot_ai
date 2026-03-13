# AngryBull - 愤怒公牛Boss
# 继承Boss基类，实现愤怒公牛的特定行为逻辑
# 包含冲锋、反弹、眩晕等核心机制
#
# 使用示例:
#   var bull = AngryBull.new()
#   bull.init_from_config("angry_bull")

class_name AngryBull
extends Boss


# ==================== 攻击类型枚举 ====================
enum AttackType {
	SIMPLE_DASH,      # 简单冲撞
	STOMP_ATTACK,     # 踩踏攻击
}


# ==================== 公牛特有属性 ====================
# 冲锋方向
var dash_direction: Vector2 = Vector2.ZERO

# 是否正在冲锋
var is_dashing: bool = false

# 剩余反弹次数
var bounce_remaining: int = 0

# AnimatedSprite2D 引用
var animated_sprite: AnimatedSprite2D = null

# 预警线节点
var warning_line: Line2D = null

# 碰撞检测区域
var hit_area: Area2D = null

# 当前状态名称
var current_state_name: String = ""

# 蓄力计时器
var telegraph_timer: float = 0.0

# 方向是否已锁定
var is_direction_locked: bool = false

# Idle 状态计时器
var idle_timer: float = 0.0

# 眩晕计时器
var stun_timer: float = 0.0

# 子弹管理器引用
var bullet_manager: BulletManager = null

# 拖尾生成计时器
var _trail_timer: float = 0.0

# 摄像机引用（用于震屏）
var _camera: Camera2D = null

# 原始摄像机偏移
var _original_camera_offset: Vector2 = Vector2.ZERO

# 当前攻击类型
var _current_attack_type: int = AttackType.SIMPLE_DASH

# 当前冲刺目标距离
var _current_dash_distance: float = 600.0

# 已冲刺距离
var _dashed_distance: float = 0.0

# 愤怒阶段是否已完成入场动画
var _enrage_animation_done: bool = false

# 踩踏攻击音效播放器
var _dance_audio: AudioStreamPlayer = null

# 愤怒音效已播放标志
var _angry_audio_played: bool = false


# ==================== 生命周期方法 ====================
func _ready() -> void:
	super._ready()

	# 初始隐藏 Boss（等待出场特效）
	visible = false
	scale = Vector2.ZERO

	# 获取 AnimatedSprite2D 引用
	animated_sprite = get_node_or_null("AnimatedSprite2D")
	if animated_sprite == null:
		push_warning("[AngryBull] 未找到 AnimatedSprite2D 节点")

	# 获取摄像机引用
	_setup_camera()

	# 获取子弹管理器引用
	_setup_bullet_manager()

	# 创建预警线
	_create_warning_line()

	# 创建碰撞检测区域
	_create_hit_area()
	
	# 创建音效播放器
	_setup_audio_players()
	
	# 暂停状态机（等待出场动画完成）
	if state_chart != null:
		state_chart.process_mode = Node.PROCESS_MODE_DISABLED


## 开始 Boss 战
func start_battle() -> void:
	print("[AngryBull] start_battle() 被调用")
	visible = true
	_animate_spawn()


## Boss 出场动画
func _animate_spawn() -> void:
	print("[AngryBull] _animate_spawn() 开始")
	scale = Vector2.ZERO

	var tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_ELASTIC)

	tween.tween_property(self, "scale", Vector2.ONE, 0.2)
	tween.tween_callback(_on_spawn_animation_finished)


## 出场动画完成
func _on_spawn_animation_finished() -> void:
	print("[AngryBull] _on_spawn_animation_finished() 出场动画完成")
	# 启用状态机
	if state_chart != null:
		state_chart.process_mode = Node.PROCESS_MODE_INHERIT
		state_chart.send_event(&"battle_start")
	print("[AngryBull] Boss战开始!")


func init_from_config(id: String) -> void:
	super.init_from_config(id)


# ==================== 状态机信号连接 ====================
# 连接状态机各状态的进入/退出信号
func _connect_state_signals() -> void:
	if state_chart == null:
		push_warning("[AngryBull] 状态机未初始化，无法连接信号")
		return

	# Phase1 状态
	_connect_state_signal("BossBehavior/Phase1/Idle", "state_entered", _on_idle_entered)
	_connect_state_signal("BossBehavior/Phase1/Telegraphing", "state_entered", _on_telegraphing_entered)
	_connect_state_signal("BossBehavior/Phase1/Dashing", "state_entered", _on_dashing_entered)
	_connect_state_signal("BossBehavior/Phase1/DashComplete", "state_entered", _on_dash_complete_entered)
	_connect_state_signal("BossBehavior/Phase1/Falling", "state_entered", _on_falling_entered)
	_connect_state_signal("BossBehavior/Phase1/Stun", "state_entered", _on_stun_entered)

	# Phase2 状态
	_connect_state_signal("BossBehavior/Phase2/EnragedEntry", "state_entered", _on_enraged_entered)
	_connect_state_signal("BossBehavior/Phase2/Idle", "state_entered", _on_idle_entered)
	_connect_state_signal("BossBehavior/Phase2/Telegraphing", "state_entered", _on_telegraphing_entered)
	_connect_state_signal("BossBehavior/Phase2/Dashing", "state_entered", _on_dashing_entered)
	_connect_state_signal("BossBehavior/Phase2/DashComplete", "state_entered", _on_dash_complete_entered)
	_connect_state_signal("BossBehavior/Phase2/Falling", "state_entered", _on_falling_entered)
	_connect_state_signal("BossBehavior/Phase2/Stun", "state_entered", _on_stun_entered)

	# 死亡状态
	_connect_state_signal("BossBehavior/Dead", "state_entered", _on_dead_entered)


# 连接单个状态的信号
# @param state_path: 状态路径（相对于StateChart）
# @param signal_name: 信号名称
# @param callback: 回调函数
func _connect_state_signal(state_path: String, signal_name: String, callback: Callable) -> void:
	var state_node = state_chart.get_node_or_null(state_path)
	if state_node == null:
		push_warning("[AngryBull] 未找到状态节点: " + state_path)
		return

	if not state_node.has_signal(signal_name):
		push_warning("[AngryBull] 状态节点没有信号: " + state_path + "/" + signal_name)
		return

	state_node.connect(signal_name, callback)


# ==================== 状态处理方法 ====================
# 进入Idle状态
func _on_idle_entered() -> void:
	print("[AngryBull] 进入Idle状态")
	current_state_name = "Idle"

	# 重置冲锋状态
	is_dashing = false
	dash_direction = Vector2.ZERO

	# 重置反弹次数
	bounce_remaining = bounce_count

	# 重置Idle计时器
	idle_timer = 0.0

	# 播放idle动画
	_play_animation("idle")


# 进入Telegraphing状态
func _on_telegraphing_entered() -> void:
	print("[AngryBull] 进入Telegraphing状态")
	current_state_name = "Telegraphing"

	# 重置蓄力计时器
	telegraph_timer = 0.0

	# 锁定方向
	is_direction_locked = false

	# 随机选择攻击类型
	_select_random_attack_type()

	_dashed_distance = 0.0

	# 显示预警线
	if warning_line != null:
		warning_line.visible = true

	# 播放telegraphing动画
	_play_animation("telegraphing")


# 进入Dashing状态
func _on_dashing_entered() -> void:
	print("[AngryBull] 进入Dashing状态")
	current_state_name = "Dashing"

	# 设置冲锋状态
	is_dashing = true

	# 重新启用伤害检测
	if hit_area != null:
		hit_area.monitoring = true

	# 如果方向未锁定，锁定方向
	if not is_direction_locked:
		dash_direction = get_direction_to_target()

		# 如果没有目标，随机方向
		if dash_direction == Vector2.ZERO:
			dash_direction = Vector2.RIGHT.rotated(randf() * TAU)

	# 更新朝向
	_update_facing(dash_direction)

	# 隐藏预警线
	_hide_warning_line()
	
	# 冲刺时禁用与玩家的物理碰撞（只检测障碍物）
	collision_mask = LayerConstants.COLLISION_OBSTACLE
	print("[AngryBull] 冲刺 collision_mask 设置为: ", collision_mask, " (只检测障碍物)")

	# 播放dash动画
	_play_animation("dash")


# 进入Falling状态
func _on_falling_entered() -> void:
	print("[AngryBull] 进入Falling状态")
	current_state_name = "Falling"

	# 重置冲锋状态
	is_dashing = false

	# 恢复碰撞掩码
	collision_mask = LayerConstants.COLLISION_PLAYER | LayerConstants.COLLISION_OBSTACLE

	# 隐藏预警线
	_hide_warning_line()

	# 播放falling动画
	_play_animation("falling")


# 进入Stun状态
func _on_stun_entered() -> void:
	print("[AngryBull] 进入Stun状态")
	current_state_name = "Stun"

	# 重置眩晕计时器
	stun_timer = 0.0

	# 播放stun动画
	_play_animation("stun")


# 进入DashComplete状态
func _on_dash_complete_entered() -> void:
	print("[AngryBull] 进入DashComplete状态，攻击类型: ", _current_attack_type)
	current_state_name = "DashComplete"

	# 恢复碰撞掩码
	collision_mask = LayerConstants.COLLISION_PLAYER | LayerConstants.COLLISION_OBSTACLE

	# 停止冲刺动画，播放idle动画
	_play_animation("idle")

	# 根据攻击类型执行不同逻辑
	match _current_attack_type:
		AttackType.STOMP_ATTACK:
			_execute_stomp_attack()
		_:
			# 简单冲撞，直接回到 Idle
			await get_tree().create_timer(0.3).timeout
			if state_chart != null:
				state_chart.send_event(&"dash_done")


# 随机选择攻击类型
func _select_random_attack_type() -> void:
	var attack_types = [AttackType.SIMPLE_DASH, AttackType.SIMPLE_DASH, AttackType.STOMP_ATTACK]
	_current_attack_type = attack_types[randi() % attack_types.size()]
	print("[AngryBull] 选择攻击类型: ", _current_attack_type)


# 执行踩踏攻击
func _execute_stomp_attack() -> void:
	print("[AngryBull] 执行踩踏攻击")
	# 播放踩踏动画
	_play_animation("attack")
	
	# 播放踩踏音效（循环）
	_play_dance_music()
	
	# 创建脚底特效
	_create_stomp_effect()
	
	# 启用伤害检测区域
	if hit_area != null:
		hit_area.monitoring = true
	
	# 等待物理帧，确保 Area2D 能正确检测碰撞
	await get_tree().physics_frame
	
	# 踩踏攻击造成伤害
	_check_player_collision(true)
	
	# 分4段发射弹幕
	var bullet_wave_count = 4
	var bullet_interval = 37.0 / 12.0 / bullet_wave_count
	var angle_offset = 0.0
	var angle_step = TAU / 8.0
	
	for wave in range(bullet_wave_count):
		_fire_stomp_bullets(angle_offset)
		angle_offset += angle_step / 3.0
		await get_tree().create_timer(bullet_interval).timeout
	
	# 移除脚底特效
	_remove_stomp_effect()
	
	if state_chart != null:
		state_chart.send_event(&"dash_done")


# 创建脚底踩踏特效
func _create_stomp_effect() -> void:
	# 创建脚底特效节点
	var stomp_sprite = Sprite2D.new()
	stomp_sprite.name = "StompEffect"
	var texture = AssetManager.load("res://resources/sprites/map/img_fw.png")
	if texture != null:
		stomp_sprite.texture = texture
	stomp_sprite.z_index = LayerConstants.Z_FLOOR + 1
	
	# 设置位置在Boss脚底
	stomp_sprite.position = Vector2(0, 50)
	
	# 设置缩放以匹配攻击范围（300x300，增加2倍）
	var texture_size = stomp_sprite.texture.get_size()
	var target_size = Vector2(300, 300)
	stomp_sprite.scale = target_size / texture_size
	
	add_child(stomp_sprite)
	print("[AngryBull] 创建脚底踩踏特效")


# 移除脚底踩踏特效
func _remove_stomp_effect() -> void:
	var stomp_sprite = get_node_or_null("StompEffect")
	if stomp_sprite != null:
		stomp_sprite.queue_free()
		print("[AngryBull] 移除脚底踩踏特效")


# 踩踏攻击发射弹幕
# @param angle_offset: 角度偏移量
func _fire_stomp_bullets(angle_offset: float) -> void:
	if bullet_manager == null:
		print("[AngryBull] 弹幕管理器未初始化")
		return
	
	var count = 8
	if is_enraged:
		count = 12
	
	print("[AngryBull] 踩踏发射弹幕，数量: ", count, " 角度偏移: ", angle_offset)
	
	var bullet_texture = AssetManager.load("res://resources/sprites/map/img_zd2.png")
	var angle_step = TAU / count
	
	if bullet_texture != null:
		for i in range(count):
			var angle = i * angle_step + angle_offset
			var direction = Vector2.RIGHT.rotated(angle)
			
			var bullet = bullet_manager.spawn_enemy_bullet(global_position, direction, 200.0)
			if bullet != null:
				bullet.damage = damage / 2
				
				# 放大子弹2倍
				bullet.scale = Vector2(2, 2)
				
				if bullet.sprite != null:
					bullet.sprite.texture = bullet_texture


# 进入EnragedEntry状态
func _on_enraged_entered() -> void:
	print("[AngryBull] 进入EnragedEntry状态")
	current_state_name = "EnragedEntry"
	
	# 重置愤怒动画标志
	_enrage_animation_done = false
	_angry_audio_played = false
	
	# 播放angry1动画（进入愤怒的过渡动画）
	_play_animation("angry1")
	
	# 监听动画完成
	if animated_sprite and animated_sprite.animation_finished.is_connected(_on_angry1_finished):
		animated_sprite.animation_finished.disconnect(_on_angry1_finished)
	animated_sprite.animation_finished.connect(_on_angry1_finished)


# angry1动画完成回调
func _on_angry1_finished() -> void:
	if _enrage_animation_done:
		return
	_enrage_animation_done = true
	
	# 播放愤怒音效
	if not _angry_audio_played:
		_angry_audio_played = true
		AudioManager.play_se("res://resources/audios/sfx/boss/boss_angry.mp3")
	
	# 播放angry2动画（循环愤怒动画，持续2秒）
	_play_animation("angry2")
	
	# 2秒后进入Idle状态
	await get_tree().create_timer(2.0).timeout
	if state_chart != null:
		state_chart.send_event(&"enrage_done")


# 进入死亡状态
func _on_dead_entered() -> void:
	print("[AngryBull] 进入死亡状态")
	current_state_name = "Dead"

	# 播放死亡动画
	if animated_sprite != null and animated_sprite.sprite_frames != null:
		if animated_sprite.sprite_frames.has_animation("die"):
			animated_sprite.play("die")
		elif animated_sprite.sprite_frames.has_animation("stun"):
			animated_sprite.play("stun")


# ==================== 物理处理 ====================
func _physics_process(delta: float) -> void:
	# 根据当前状态处理逻辑
	match current_state_name:
		"Idle":
			_process_idle_state(delta)
		"Telegraphing":
			_process_telegraphing_state(delta)
		"Dashing":
			_process_dashing_state(delta)
		"Falling":
			_process_falling_state(delta)
		"Stun":
			_process_stun_state(delta)
		"EnragedEntry":
			_process_enraged_entry_state(delta)


# 处理Idle状态逻辑
# @param delta: 帧间隔时间
func _process_idle_state(delta: float) -> void:
	# Idle状态下保持静止
	velocity = Vector2.ZERO

	# 累计Idle时间
	idle_timer += delta


# 处理Telegraphing状态逻辑
# @param delta: 帧间隔时间
func _process_telegraphing_state(delta: float) -> void:
	# 蓄力状态下保持静止
	velocity = Vector2.ZERO

	# 累计蓄力时间
	telegraph_timer += delta

	# 更新预警线
	_update_warning_line()

	# 如果方向未锁定，持续跟踪目标
	if not is_direction_locked:
		var direction_to_target = get_direction_to_target()
		if direction_to_target != Vector2.ZERO:
			dash_direction = direction_to_target
			_update_facing(dash_direction)


# 处理Dashing状态逻辑
# @param delta: 帧间隔时间
func _process_dashing_state(delta: float) -> void:
	# 执行冲锋
	_perform_dash(delta)


# 处理Falling状态逻辑
# @param delta: 帧间隔时间
func _process_falling_state(delta: float) -> void:
	# Falling状态下保持静止
	velocity = Vector2.ZERO


# 处理眩晕状态逻辑
# @param delta: 帧间隔时间
func _process_stun_state(delta: float) -> void:
	# 眩晕状态下保持静止
	velocity = Vector2.ZERO


# 处理EnragedEntry状态逻辑
# @param delta: 帧间隔时间
func _process_enraged_entry_state(delta: float) -> void:
	# 进入狂暴状态时保持静止
	velocity = Vector2.ZERO


# 执行冲锋
# @param delta: 帧间隔时间
func _perform_dash(delta: float) -> void:
	# 计算冲锋速度
	var speed = dash_speed
	if is_enraged:
		speed *= phase2_speed_multiplier

	# 计算本帧移动距离
	var motion = dash_direction * speed * delta
	_dashed_distance += motion.length()
	
	# 检查是否达到目标距离
	if _dashed_distance >= _current_dash_distance:
		# 停止冲刺
		velocity = Vector2.ZERO
		if state_chart != null:
			state_chart.send_event(&"dash_complete")
		return
	
	# 执行移动并检测碰撞（只检测障碍物）
	var collision = move_and_collide(motion)
	
	if collision != null:
		# 撞墙，发送事件
		if state_chart != null:
			state_chart.send_event(&"hit_wall")
		
		# 处理反弹
		_handle_bounce(collision)
	
	# Phase2: 生成冲锋路径粒子
	if is_enraged:
		_spawn_dash_trail(delta)
	
	# 检测玩家碰撞（通过 Area2D）
	_check_player_collision()


# 检测与玩家的碰撞
# @param disable_after: 是否在检测后禁用 monitoring
func _check_player_collision(disable_after: bool = false) -> void:
	if hit_area == null:
		return
	
	# 如果 monitoring 已禁用，直接返回
	if not hit_area.monitoring:
		return
	
	var bodies = hit_area.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("player"):
			if body.has_method("take_damage"):
				body.take_damage(damage)
				print("[AngryBull] 冲锋对玩家造成伤害: ", damage)
				# 造成伤害后立即禁用，防止重复伤害
				hit_area.monitoring = false
				return
	
	# 只有在指定时才禁用
	if disable_after:
		hit_area.monitoring = false


# 处理反弹
# @param collision: 碰撞信息
func _handle_bounce(collision: KinematicCollision2D) -> void:
	# 减少反弹次数
	bounce_remaining -= 1

	# Phase2: 撞墙时生成弹幕
	if is_enraged:
		_spawn_wall_bullets(global_position)

	# 如果还有反弹次数，反弹
	if bounce_remaining > 0:
		# 计算反弹方向
		var normal = collision.get_normal()
		dash_direction = dash_direction.bounce(normal)

		# 更新朝向
		_update_facing(dash_direction)

		print("[AngryBull] 反弹，剩余次数: " + str(bounce_remaining))
	else:
		# 没有反弹次数，进入眩晕
		print("[AngryBull] 反弹次数用尽，进入眩晕")


# ==================== 辅助方法 ====================
# 创建预警线
func _create_warning_line() -> void:
	warning_line = Line2D.new()
	warning_line.name = "WarningLine"
	warning_line.width = 90
	warning_line.default_color = Color(1.0, 0.0, 0.0, 0.5)
	warning_line.visible = false
	warning_line.z_index = LayerConstants.Z_BACKGROUND
	warning_line.top_level = true
	add_child(warning_line)


# 隐藏并清空预警线
func _hide_warning_line() -> void:
	if warning_line == null:
		return
	warning_line.visible = false
	warning_line.clear_points()


# 创建碰撞检测区域
func _create_hit_area() -> void:
	hit_area = Area2D.new()
	hit_area.name = "HitArea"
	hit_area.monitoring = true
	hit_area.monitorable = true

	var collision_shape = CollisionShape2D.new()
	collision_shape.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = Vector2(100, 100)
	collision_shape.shape = shape
	hit_area.add_child(collision_shape)

	hit_area.collision_layer = 0
	hit_area.collision_mask = LayerConstants.COLLISION_PLAYER

	hit_area.body_entered.connect(_on_hit_area_body_entered)

	add_child(hit_area)
	print("[AngryBull] 碰撞检测区域创建完成, collision_mask: ", hit_area.collision_mask)


# 更新预警线显示
func _update_warning_line() -> void:
	if warning_line == null or not warning_line.visible:
		return

	# 清空当前点
	warning_line.clear_points()

	# 起点：Boss位置
	var start_pos = global_position
	warning_line.add_point(start_pos)

	# 终点：沿冲锋方向延伸到战场边界
	var line_length = 800.0
	var end_pos = start_pos + dash_direction * line_length
	warning_line.add_point(end_pos)


# 播放动画
# @param anim_name: 动画名称
func _play_animation(anim_name: String) -> void:
	if animated_sprite == null:
		return

	if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation(anim_name):
		animated_sprite.play(anim_name)
	else:
		push_warning("[AngryBull] 动画不存在: " + anim_name)


# 更新朝向
func _update_facing(direction: Vector2) -> void:
	if animated_sprite == null:
		return

	# 根据方向翻转精灵
	if direction.x < 0:
		animated_sprite.flip_h = true
	elif direction.x > 0:
		animated_sprite.flip_h = false


# 设置摄像机引用
func _setup_camera() -> void:
	# 查找场景中的摄像机
	var cameras = get_tree().get_nodes_in_group("camera")
	if cameras.size() > 0:
		_camera = cameras[0]
		_original_camera_offset = _camera.offset
		print("[AngryBull] 找到摄像机")
	else:
		# 尝试从玩家获取摄像机
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			var player = players[0]
			_camera = player.get_node_or_null("Camera2D")
			if _camera != null:
				_original_camera_offset = _camera.offset
				print("[AngryBull] 从玩家获取摄像机")


# 设置子弹管理器引用
func _setup_bullet_manager() -> void:
	# 查找场景中的子弹管理器
	var bullet_managers = get_tree().get_nodes_in_group("bullet_manager")
	if bullet_managers.size() > 0:
		bullet_manager = bullet_managers[0]
		print("[AngryBull] 找到子弹管理器")
	else:
		# 尝试从玩家获取子弹管理器
		var players = get_tree().get_nodes_in_group("player")
		if players.size() > 0:
			var player = players[0]
			bullet_manager = player.get_node_or_null("BulletManager")
			if bullet_manager != null:
				print("[AngryBull] 从玩家获取子弹管理器")


# 设置音效播放器
func _setup_audio_players() -> void:
	_dance_audio = AudioStreamPlayer.new()
	_dance_audio.name = "DanceAudio"
	_dance_audio.bus = &"Master"
	add_child(_dance_audio)
	print("[AngryBull] 音效播放器创建完成")


# 生成冲锋拖尾
func _spawn_dash_trail(delta: float) -> void:
	_trail_timer += delta

	var trail_interval = 0.05
	if _trail_timer >= trail_interval:
		_trail_timer = 0.0

		EffectManager.spawn("dash_trail", {
			"position": global_position,
			"duration": trail_duration,
			"z_index": LayerConstants.Z_BACKGROUND
		})


# 撞墙时生成弹幕
func _spawn_wall_bullets(pos: Vector2) -> void:
	if bullet_manager == null:
		return

	var count = bullet_count
	var angle_step = TAU / count

	for i in range(count):
		var angle = i * angle_step
		var direction = Vector2.RIGHT.rotated(angle)

		var bullet = bullet_manager.spawn_enemy_bullet(pos, direction, 300.0)
		if bullet != null:
			bullet.damage = damage / 2
			# 放大子弹2倍
			bullet.scale = Vector2(2, 2)


# 碰撞检测区域回调
func _on_hit_area_body_entered(body: Node2D) -> void:
	print("[AngryBull] 检测到碰撞: ", body.name, " groups: ", body.get_groups())
	if body.is_in_group("player"):
		print("[AngryBull] 玩家进入碰撞区域")
		# 对玩家造成伤害
		if body.has_method("take_damage"):
			body.take_damage(damage)
			print("[AngryBull] 对玩家造成伤害: ", damage)


# 死亡处理
func die() -> void:
	super.die()

	# 隐藏预警线
	if warning_line != null:
		warning_line.visible = false

	# 播放死亡动画（如果没有die动画，播放stun动画)
	if animated_sprite != null:
		if animated_sprite.sprite_frames != null and animated_sprite.sprite_frames.has_animation("die"):
			animated_sprite.play("die")
			animated_sprite.animation_looped.connect(_on_death_animation_finished)
		elif animated_sprite.sprite_frames.has_animation("stun"):
			animated_sprite.play("stun")
			animated_sprite.animation_looped.connect(_on_death_animation_finished)

	# 禁用碰撞
	set_deferred("collision_layer", 0)
	set_deferred("collision_mask", 0)

	if hit_area != null:
		hit_area.set_deferred("monitoring", false)
		hit_area.set_deferred("monitorable", false)


func _on_death_animation_finished() -> void:
	if animated_sprite != null:
		animated_sprite.pause()
		animated_sprite.frame = animated_sprite.sprite_frames.get_frame_count("die") - 1
	
	# 停止踩踏音效
	_stop_dance_music()
	
	await get_tree().create_timer(1.0).timeout
	queue_free()


# 播放踩踏音效（循环）
func _play_dance_music() -> void:
	if _dance_audio == null:
		return
	
	var music = AssetManager.load("res://resources/audios/sfx/boss/boss_dance.mp3")
	if music != null:
		return
	
	_dance_audio.stream = music
	_dance_audio.volume_db = 0.0
	_dance_audio.play()
	print("[AngryBull] 开始播放踩踏音效")


# 停止踩踏音效
func _stop_dance_music() -> void:
	if _dance_audio == null:
		return
	
	if _dance_audio.playing:
		_dance_audio.stop()
		print("[AngryBull] 停止踩踏音效")
