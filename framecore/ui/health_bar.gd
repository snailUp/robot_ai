class_name HealthBar
extends Node2D

## 血条 UI 组件：显示角色血量百分比
## 支持平滑过渡动画和颜色渐变

## 血条宽度
@export var bar_width: float = 60.0

## 血条高度
@export var bar_height: float = 6.0

## 血条偏移（相对于角色位置）
@export var bar_offset: Vector2 = Vector2(0, -60)

## 前景色（满血）
@export var full_color: Color = Color.GREEN

## 中等血量颜色
@export var mid_color: Color = Color.YELLOW

## 低血量颜色
@export var low_color: Color = Color.RED

## 背景色
@export var background_color: Color = Color(0.2, 0.2, 0.2, 0.8)

## 边框颜色
@export var border_color: Color = Color(0.1, 0.1, 0.1, 1.0)

## 平滑过渡时间（秒）
@export var transition_duration: float = 0.2

## 当前血量百分比
var _current_percent: float = 1.0

## 目标血量百分比
var _target_percent: float = 1.0

## 过渡计时器
var _transition_timer: float = 0.0

## 起始百分比（用于插值）
var _start_percent: float = 1.0


func _ready() -> void:
	z_index = LayerConstants.Z_UI
	top_level = true


func _process(delta: float) -> void:
	# 平滑过渡
	if _transition_timer > 0:
		_transition_timer -= delta
		var t = 1.0 - (_transition_timer / transition_duration)
		_current_percent = lerp(_start_percent, _target_percent, t)
		queue_redraw()


## 设置血量百分比
## @param current: 当前血量
## @param maximum: 最大血量
func set_hp(current: int, maximum: int) -> void:
	var new_percent = clamp(current as float / maximum as float, 0.0, 1.0)
	
	if new_percent != _target_percent:
		_start_percent = _current_percent
		_target_percent = new_percent
		_transition_timer = transition_duration
		queue_redraw()


## 更新位置（跟随角色）
## @param character_pos: 角色全局位置
func update_position(character_pos: Vector2) -> void:
	global_position = character_pos + bar_offset


func _draw() -> void:
	var half_width = bar_width / 2.0
	var half_height = bar_height / 2.0

	# 绘制边框
	draw_rect(
		Rect2(-half_width - 1, -half_height - 1, bar_width + 2, bar_height + 2),
		border_color
	)

	# 绘制背景
	draw_rect(
		Rect2(-half_width, -half_height, bar_width, bar_height),
		background_color
	)

	# 绘制前景（血量）
	var fg_width = bar_width * _current_percent
	if fg_width > 0:
		var fg_color = _get_color_by_percent(_current_percent)
		draw_rect(
			Rect2(-half_width, -half_height, fg_width, bar_height),
			fg_color
		)


## 根据血量百分比获取颜色
## @param percent: 血量百分比
## @return: 对应的颜色
func _get_color_by_percent(percent: float) -> Color:
	if percent > 0.6:
		return full_color
	elif percent > 0.3:
		return mid_color
	else:
		return low_color
