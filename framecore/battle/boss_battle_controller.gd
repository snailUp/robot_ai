## Boss战开场流程控制器
## 管理Boss战的整体流程，包括开场动画、围墙创建、Boss入场等
class_name BossBattleController
extends Node

## 战斗开始信号
signal battle_started(boss: Node)
## 战斗结束信号
signal battle_ended(victory: bool)

## Boss预制体
@export var boss_scene: PackedScene
## 战场尺寸
@export var arena_size: Vector2 = Vector2(1200, 800)
## 摄像机拉远倍率
@export var camera_zoom_out: float = 0.5
## 开场动画时长
@export var intro_duration: float = 2.0

## 战场围墙系统
var _arena: BattleArena = null
## 当前Boss实例
var _boss_instance: Node = null
## 当前玩家
var _player: CharacterBody2D = null
## 玩家摄像机
var _player_camera: Camera2D = null
## 原始摄像机缩放
var _original_camera_zoom: Vector2 = Vector2.ONE
## 是否战斗中
var _is_battling: bool = false
## 流程动画 Tween
var _intro_tween: Tween = null


func _ready() -> void:
	# 添加到组，方便Boss查找
	add_to_group("boss_battle_controller")
	
	# 创建战场围墙系统
	_arena = BattleArena.new()
	_arena.name = "BattleArena"
	_arena.arena_size = arena_size
	add_child(_arena)
	
	# 连接围墙信号
	_arena.arena_created.connect(_on_arena_created)
	_arena.arena_destroyed.connect(_on_arena_destroyed)


## 开始Boss战
## player: 玩家角色
## spawn_position: 战场中心位置
func start_battle(player: CharacterBody2D, spawn_position: Vector2) -> void:
	if _is_battling:
		push_warning("BossBattleController: 战斗已在进行中")
		return
	
	if boss_scene == null:
		push_error("BossBattleController: Boss预制体未设置")
		return
	
	if player == null:
		push_error("BossBattleController: 玩家为空")
		return
	
	_is_battling = true
	_player = player
	
	# 获取玩家摄像机
	_player_camera = _get_player_camera()
	if _player_camera == null:
		push_warning("BossBattleController: 未找到玩家摄像机")
	
	# 锁定玩家操作
	_lock_player()
	
	# 摄像机拉远动画
	_zoom_out_camera()
	
	# 创建战场围墙
	_arena.create_arena(spawn_position)


## 结束Boss战
## victory: 是否胜利
func end_battle(victory: bool) -> void:
	if not _is_battling:
		push_warning("BossBattleController: 战斗未开始")
		return
	
	_is_battling = false
	
	# 停止开场动画
	if _intro_tween and _intro_tween.is_valid():
		_intro_tween.kill()
		_intro_tween = null
	
	# 只有在失败时才销毁Boss实例（胜利时Boss已死亡）
	if not victory and _boss_instance and is_instance_valid(_boss_instance):
		_boss_instance.queue_free()
		_boss_instance = null
	
	# 解锁玩家操作
	_unlock_player()
	
	# 解除摄像机限制和缩放
	if _player_camera:
		_arena.unlock_camera()
		_reset_camera_zoom()
	
	# 销毁围墙
	_arena.destroy_arena()
	
	# 打印胜利消息
	if victory:
		print("[BossBattleController] ========== 战斗胜利 ==========")
	else:
		print("[BossBattleController] ========== 战斗失败 ==========")
	
	# 发出战斗结束信号
	battle_ended.emit(victory)


## 锁定玩家操作
func _lock_player() -> void:
	if _player == null:
		return
	
	# 禁用玩家处理
	_player.set_process(false)
	_player.set_physics_process(false)
	
	# 如果玩家有自定义锁定方法，调用它
	if _player.has_method("set_locked"):
		_player.call("set_locked", true)


## 解锁玩家操作
func _unlock_player() -> void:
	if _player == null:
		return
	
	# 启用玩家处理
	_player.set_process(true)
	_player.set_physics_process(true)
	
	# 如果玩家有自定义解锁方法，调用它
	if _player.has_method("set_locked"):
		_player.call("set_locked", false)


## 获取玩家摄像机
func _get_player_camera() -> Camera2D:
	if _player == null:
		return null
	
	# 查找玩家下的摄像机
	for child in _player.get_children():
		if child is Camera2D:
			return child
	
	return null


## 摄像机拉远动画
func _zoom_out_camera() -> void:
	if _player_camera == null:
		return
	
	# 保存原始缩放
	_original_camera_zoom = _player_camera.zoom
	
	# 创建拉远动画
	if _intro_tween and _intro_tween.is_valid():
		_intro_tween.kill()
	
	_intro_tween = create_tween()
	_intro_tween.set_ease(Tween.EASE_OUT)
	_intro_tween.set_trans(Tween.TRANS_QUAD)
	
	var target_zoom = _original_camera_zoom * (1.0 - camera_zoom_out)
	_intro_tween.tween_property(_player_camera, "zoom", target_zoom, intro_duration * 0.3)


## 重置摄像机缩放
func _reset_camera_zoom() -> void:
	if _player_camera == null:
		return
	
	# 创建恢复动画
	var reset_tween = create_tween()
	reset_tween.set_ease(Tween.EASE_OUT)
	reset_tween.set_trans(Tween.TRANS_QUAD)
	reset_tween.tween_property(_player_camera, "zoom", _original_camera_zoom, 0.5)


## 围墙创建完成回调
func _on_arena_created() -> void:
	# 锁定摄像机到战场边界
	if _player_camera:
		_arena.lock_camera(_player_camera)
	
	# 实例化Boss
	_spawn_boss()


## 围墙销毁完成回调
func _on_arena_destroyed() -> void:
	pass


## 实例化Boss
func _spawn_boss() -> void:
	if boss_scene == null:
		push_error("BossBattleController: Boss预制体为空")
		end_battle(false)
		return
	
	# 实例化Boss
	_boss_instance = boss_scene.instantiate()
	_boss_instance.name = "Boss"
	
	# 监听Boss的died信号
	if _boss_instance.has_signal("died"):
		_boss_instance.died.connect(_on_boss_died)
	
	# 获取围墙边界
	var bounds = _arena.get_bounds()
	
	# 在围墙边缘生成Boss（上方边缘）
	var spawn_position = Vector2(
		bounds.get_center().x,
		bounds.position.y + 100  # 上方边缘内侧
	)
	
	_boss_instance.position = spawn_position
	
	# 添加到角色层
	LayerManager.add_character(_boss_instance)
	
	# 初始化Boss配置和目标
	if _boss_instance.has_method("init_from_config"):
		_boss_instance.call("init_from_config", "angry_bull")
	
	if _boss_instance.has_method("set_target") and _player != null:
		_boss_instance.call("set_target", _player)
	
	# 执行Boss入场动画
	_boss_intro_animation()


## Boss入场动画
func _boss_intro_animation() -> void:
	if _boss_instance == null:
		_finish_intro()
		return

	# 使用 Boss 出场特效
	_spawn_boss_with_effect()


## 使用出场特效生成 Boss
func _spawn_boss_with_effect() -> void:
	if _boss_instance == null:
		_finish_intro()
		return

	# 生成 Boss 出场特效
	var effect = EffectManager.spawn("boss_spawn", {
		"position": _boss_instance.global_position,
		"boss": _boss_instance,
		"warning_duration": 2.0,
		"blink_speed": 0.2
	})

	# 监听特效完成信号
	if effect and effect.has_signal("effect_finished"):
		effect.effect_finished.connect(_on_spawn_effect_finished)


## 完成开场流程
func _finish_intro() -> void:
	# 解锁玩家操作
	_unlock_player()

	# 发出战斗开始信号（传递Boss实例）
	battle_started.emit(_boss_instance)


## 出场特效完成回调
func _on_spawn_effect_finished() -> void:
	_finish_intro()


## Boss死亡信号回调
func _on_boss_died() -> void:
	print("[BossBattleController] 收到Boss死亡信号")
	
	# 延迟一段时间后结束战斗（让死亡动画播放）
	var death_delay = 2.0  # 死亡动画播放时间
	
	# 创建延迟调用
	var timer = get_tree().create_timer(death_delay)
	timer.timeout.connect(func(): end_battle(true))
