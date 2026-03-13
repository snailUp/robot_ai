class_name DashTrail
extends Area2D

## 冲锋路径粒子：在冲锋路径上生成的伤害区域
## 玩家接触时受到伤害，持续一段时间后自动销毁

## 特效完成信号
signal effect_finished

## 伤害值
@export var damage: int = 10

## 持续时间（秒）
@export var duration: float = 3.0

## 碰撞形状大小
@export var collision_size: Vector2 = Vector2(40, 40)

## 碰撞形状引用
@onready var _collision_shape: CollisionShape2D = $CollisionShape2D

## 计时器
var _timer: float = 0.0

## 是否已造成伤害（防止重复伤害）
var _has_damaged: bool = false


func _ready() -> void:
	# 设置碰撞形状大小
	if _collision_shape != null and _collision_shape.shape != null:
		_collision_shape.shape.size = collision_size

	# 连接信号
	body_entered.connect(_on_body_entered)


func _process(delta: float) -> void:
	if _timer <= 0:
		return

	_timer -= delta

	# 时间到，发送完成信号
	if _timer <= 0:
		effect_finished.emit()


## 特效初始化
func on_spawn() -> void:
	_timer = duration
	_has_damaged = false


## 特效回收
func on_despawn() -> void:
	_has_damaged = false


## 设置特效参数
func set_params(params: Dictionary) -> void:
	if params.has("duration"):
		duration = params["duration"]

	if params.has("damage"):
		damage = params["damage"]

	if params.has("z_index"):
		z_index = params["z_index"]

	if params.has("collision_size"):
		collision_size = params["collision_size"]
		if _collision_shape != null and _collision_shape.shape != null:
			_collision_shape.shape.size = collision_size


## 玩家进入碰撞区域
func _on_body_entered(body: Node2D) -> void:
	# 检查是否为玩家
	if body is Player and not _has_damaged:
		_has_damaged = true
		_apply_damage_to_player(body)


## 对玩家造成伤害
func _apply_damage_to_player(player: Player) -> void:
	if player.has_method("take_damage"):
		player.take_damage(damage)
		print("[DashTrail] 对玩家造成伤害: " + str(damage))
