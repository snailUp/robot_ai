class_name DamageVignette
extends CanvasLayer
## 受伤红色晕影效果：屏幕边缘显示红色渐变

@onready var color_rect: ColorRect = $ColorRect

var _tween: Tween = null
var _material: ShaderMaterial = null


func _ready() -> void:
	layer = 100
	_setup_material()
	_setup_color_rect()


func _setup_color_rect() -> void:
	if color_rect == null:
		return
	color_rect.mouse_filter = Control.MOUSE_FILTER_IGNORE


func _setup_material() -> void:
	if color_rect == null:
		return
	
	_material = color_rect.material as ShaderMaterial
	if _material == null:
		return
	
	# 初始隐藏
	_set_intensity(0.0)


func _set_intensity(value: float) -> void:
	if _material == null:
		return
	
	_material.set_shader_parameter("intensity", value)


## 显示受伤晕影效果
## @param intensity: 强度 (0.0 - 1.0)
## @param duration: 持续时间
func show_damage(intensity: float = 0.5, duration: float = 0.3) -> void:
	if _material == null:
		return
	
	if _tween != null and _tween.is_valid():
		_tween.kill()
	
	_tween = create_tween()
	_tween.set_ease(Tween.EASE_OUT)
	
	# 快速显示
	_tween.tween_method(_set_intensity, 0.0, intensity, 0.08)
	# 保持一小段时间
	_tween.tween_interval(0.1)
	# 渐变消失
	_tween.tween_method(_set_intensity, intensity, 0.0, duration)


## 立即隐藏
func hide_immediately() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	
	_set_intensity(0.0)
