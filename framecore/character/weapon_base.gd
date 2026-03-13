class_name WeaponBase
extends Node2D
## 武器基类：定义武器的通用行为
## 子类实现具体射击逻辑

signal fired()

## 攻击速度（每秒攻击次数）
@export var attack_speed: float = 1.0

## 伤害值
@export var damage: int = 1

## 上次射击时间
var _last_fire_time: float = 0.0

## 射击冷却时间
var _fire_cooldown: float = 0.0


func _ready() -> void:
	_update_fire_cooldown()


## 更新射击冷却时间
func _update_fire_cooldown() -> void:
	if attack_speed > 0:
		_fire_cooldown = 1.0 / attack_speed
	else:
		_fire_cooldown = 0.0


## 检查是否可以射击
func can_fire() -> bool:
	var current_time: float = Time.get_ticks_msec() / 1000.0
	return current_time - _last_fire_time >= _fire_cooldown


## 尝试射击
func try_fire() -> bool:
	if not can_fire():
		return false
	_do_fire()
	_last_fire_time = Time.get_ticks_msec() / 1000.0
	fired.emit()
	return true


## 子类实现具体射击逻辑
func _do_fire() -> void:
	push_warning("WeaponBase._do_fire() should be overridden")


## 设置攻击速度
func set_attack_speed(speed: float) -> void:
	attack_speed = speed
	_update_fire_cooldown()
