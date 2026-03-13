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

	modulate.a = initial_alpha * (_timer / duration)

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
