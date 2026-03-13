class_name Bullet
extends Area2D
## 子弹类：可池化的子弹对象，支持对象池复用
## 实现IPoolable接口，自动处理状态重置

## 子弹请求回收信号，通知管理器回收此子弹
signal request_recycle

## 子弹飞行速度（像素/秒）
@export var speed: float = 800.0

## 子弹伤害值
@export var damage: int = 1

## 安全边距（离开视口多少像素后回收）
@export var safe_margin: float = 100.0

## 子弹飞行方向（单位向量）
var direction: Vector2 = Vector2.UP

## 子弹来源（用于区分玩家子弹和敌人子弹）
var source: String = ""

## 子弹精灵
@onready var sprite: Sprite2D = $Sprite2D

## 可见性通知器，用于检测离开屏幕
@onready var visibility_notifier: VisibleOnScreenNotifier2D = $VisibleOnScreenNotifier2D

## 是否已离开视口
var _has_left_screen: bool = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)
	
	if visibility_notifier:
		visibility_notifier.screen_exited.connect(_on_screen_exited)


func _physics_process(delta: float) -> void:
	position += direction * speed * delta
	
	if _has_left_screen:
		_check_safe_margin_recycle()


## IPoolable接口：重置子弹状态
func reset_state() -> void:
	direction = Vector2.UP
	_has_left_screen = false


## IPoolable接口：从对象池获取时调用
func on_acquired_from_pool() -> void:
	_has_left_screen = false


## IPoolable接口：返回对象池时调用
func on_returned_to_pool() -> void:
	_has_left_screen = false


## 设置子弹飞行方向
func set_direction(dir: Vector2) -> void:
	direction = dir.normalized()
	rotation = direction.angle()


## 设置子弹初始位置
func set_initial_position(pos: Vector2) -> void:
	global_position = pos


## 碰撞检测：与其他物体碰撞
func _on_body_entered(body: Node2D) -> void:
	_apply_damage(body)
	_spawn_hit_effect()
	_request_recycle()


## 碰撞检测：与其他区域碰撞
func _on_area_entered(area: Area2D) -> void:
	_apply_damage(area)
	_spawn_hit_effect()
	_request_recycle()


## 对目标造成伤害
func _apply_damage(target: Node) -> void:
	if target.has_method("take_damage"):
		target.take_damage(damage)


## 生成击中特效
func _spawn_hit_effect() -> void:
	EffectManager.spawn("hit_effect", {
		"position": global_position,
		"scale": Vector2.ONE * 0.5
	})
	
	# 只有玩家的子弹才播放爆炸音效
	if source == "player":
		AudioManager.play_se("res://resources/audios/sfx/effect_bullet.mp3")


## 离开视口时标记
func _on_screen_exited() -> void:
	_has_left_screen = true


## 检查是否超出安全边距
func _check_safe_margin_recycle() -> void:
	var viewport_rect: Rect2 = get_viewport_rect()
	var camera: Camera2D = get_viewport().get_camera_2d()
	
	if camera:
		var camera_pos: Vector2 = camera.global_position
		var half_size: Vector2 = viewport_rect.size / 2
		var expanded_rect: Rect2 = Rect2(
			camera_pos - half_size - Vector2(safe_margin, safe_margin),
			viewport_rect.size + Vector2(safe_margin * 2, safe_margin * 2)
		)
		
		if not expanded_rect.has_point(global_position):
			_request_recycle()
	else:
		var expanded_rect: Rect2 = viewport_rect.grow(safe_margin)
		if not expanded_rect.has_point(global_position):
			_request_recycle()


## 请求回收子弹
func _request_recycle() -> void:
	request_recycle.emit()
