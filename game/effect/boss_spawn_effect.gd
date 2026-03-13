class_name BossSpawnEffect
extends Node2D

## Boss 出场特效
## 显示警告光圈，闪烁后 Boss 弹出出场

## 特效完成信号
signal effect_finished

## 警告持续时间
@export var warning_duration: float = 2.0

## 闪烁速度（秒）
@export var blink_speed: float = 0.2

## Boss 引用
var boss: Node2D = null

## 警告光圈精灵
var _warning_sprite: Sprite2D = null

## 计时器
var _timer: float = 0.0

## 闪烁计时器
var _blink_timer: float = 0.0

## 是否正在闪烁
var _is_blinking: bool = false

## 是否已初始化
var _initialized: bool = false


func _ready() -> void:
	_warning_sprite = $WarningSprite
	_warning_sprite.z_index = LayerConstants.Z_WARNING_EFFECT
	_warning_sprite.z_as_relative = false
	_initialized = true


func _process(delta: float) -> void:
	if not _is_blinking:
		return

	_timer += delta
	_blink_timer += delta

	# 更新闪烁效果
	_update_blink()

	# 检查是否完成
	if _timer >= warning_duration:
		_is_blinking = false
		_on_warning_finished()


## 更新闪烁效果
func _update_blink() -> void:
	if _warning_sprite == null:
		return

	# 计算闪烁透明度
	var blink_cycle = fmod(_blink_timer, blink_speed * 2)
	var alpha = 0.3 + 0.7 * (0.5 + 0.5 * cos(blink_cycle * PI / blink_speed))

	# 最后 0.5 秒快速闪烁
	var remaining_time = warning_duration - _timer
	if remaining_time < 0.5:
		var fast_blink = fmod(_blink_timer, 0.1 * 2)
		alpha = 0.3 + 0.7 * (0.5 + 0.5 * cos(fast_blink * PI / 0.1))

	_warning_sprite.modulate.a = alpha


## 特效初始化
func on_spawn() -> void:
	if _warning_sprite == null:
		await ready

	_timer = 0.0
	_blink_timer = 0.0
	_is_blinking = true
	_initialized = true

	# 显示警告光圈
	_warning_sprite.visible = true
	_warning_sprite.modulate.a = 1.0


## 特效回收
func on_despawn() -> void:
	_is_blinking = false
	_timer = 0.0
	_blink_timer = 0.0


## 设置特效参数
func set_params(params: Dictionary) -> void:
	if _warning_sprite == null:
		await ready

	if params.has("position"):
		global_position = params["position"]

	if params.has("boss"):
		boss = params["boss"]

	if params.has("warning_duration"):
		warning_duration = params["warning_duration"]

	if params.has("blink_speed"):
		blink_speed = params["blink_speed"]


## 警告结束
func _on_warning_finished() -> void:
	print("[BossSpawnEffect] 警告结束")

	# 隐藏警告光圈
	if _warning_sprite != null:
		_warning_sprite.visible = false

	# 先发出完成信号（解锁玩家）
	effect_finished.emit()

	# 再通知 Boss 开始出场动画
	if boss != null and boss.has_method("start_battle"):
		print("[BossSpawnEffect] 调用 boss.start_battle()")
		boss.start_battle()
