class_name DamageNumber
extends Node2D

## 伤害飘字特效
## 显示伤害数值，带有缩放和飘动动画

## 特效完成信号
signal effect_finished

## 显示数值
@export var value: int = -10

## 文字颜色
@export var text_color: Color = Color.RED

## 字体大小
@export var font_size: int = 50

## 动画总时长
@export var duration: float = 1.0

## 向上飘动距离
@export var float_distance: float = 60.0

## 随机水平偏移范围
@export var random_offset_range: float = 30.0

## Label 引用
var _label: Label = null

## 计时器
var _timer: float = 0.0

## 起始位置
var _start_position: Vector2 = Vector2.ZERO

## 随机水平偏移
var _random_offset: float = 0.0

## 是否已初始化
var _initialized: bool = false


func _ready() -> void:
	_label = $Label
	z_index = LayerConstants.Z_UI
	# 记录初始位置
	_start_position = global_position


func _process(delta: float) -> void:
	if not _initialized:
		return

	_timer += delta

	if _timer >= duration:
		effect_finished.emit()
		return

	_update_animation()


## 设置初始状态
func _setup_initial_state() -> void:
	if _label == null:
		return

	_label.scale = Vector2(0.5, 0.5)
	_label.modulate.a = 1.0
	_label.modulate = text_color
	_update_label_text()


## 特效初始化
func on_spawn() -> void:
	if _label == null:
		await ready

	# 重新记录起始位置（确保是最终位置） 
	_start_position = global_position
	_random_offset = randf_range(-random_offset_range, random_offset_range)
	_timer = 0.0
	_initialized = true

	_setup_initial_state()


## 特效回收
func on_despawn() -> void:
	_timer = 0.0
	_initialized = false


## 设置特效参数
func set_params(params: Dictionary) -> void:
	if _label == null:
		await ready

	if params.has("value"):
		value = params["value"]
		_update_label_text()

	if params.has("color"):
		text_color = params["color"]
		if _label != null:
			_label.modulate = text_color

	if params.has("font_size"):
		font_size = params["font_size"]
		if _label != null:
			_label.add_theme_font_size_override("font_size", font_size)

	if params.has("z_index"):
		z_index = params["z_index"]


## 更新标签文本
func _update_label_text() -> void:
	if _label == null:
		return

	if value >= 0:
		_label.text = "+" + str(value)
	else:
		_label.text = str(value)


## 更新动画
func _update_animation() -> void:
	if _label == null:
		return

	var t = _timer / duration

	# 缩放动画 (0.0-0.3秒)
	# var scale_t = min(t / 0.3, 1.0)
	# var scale = _ease_out_back(scale_t)
	# _label.scale = Vector2(scale, scale)

	# 移动动画：直接向上飘
	var y_offset = -float_distance * t
	global_position = _start_position + Vector2(_random_offset, y_offset)

	# 淡出动画 (最后0.3秒)
	if t > 0.7:
		var fade_t = (t - 0.7) / 0.3
		_label.modulate.a = 1.0 - fade_t


## 缓动函数：弹性回弹
func _ease_out_back(t: float) -> float:
	const c1 = 1.70158
	const c3 = c1 + 1
	if t < 0.5:
		return 0.5 * (1 + c3 * pow(2 * t - 1, 3) + c1 * pow(2 * t - 1, 2))
	else:
		return 0.5 * (2 - (1 + c3 * pow(-2 * t + 2, 3) + c1 * pow(-2 * t + 2, 2)))
