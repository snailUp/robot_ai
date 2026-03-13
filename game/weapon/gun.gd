class_name Gun
extends WeaponBase
## 枪械：实现具体的射击逻辑，枪口跟随鼠标

## 子弹管理器引用
@export var bullet_manager: BulletManager

## 子弹飞行速度（像素/秒）
@export var bullet_speed: float = 800.0

## 后坐力强度（像素偏移）
@export var recoil_strength: float = 10.0

## 后坐力恢复速度
@export var recoil_recovery_speed: float = 20.0

## 枪口位置节点
@onready var muzzle: Marker2D = $Muzzle

## 枪械精灵
@onready var sprite: Sprite2D = $Sprite2D

## 当前后坐力偏移
var _recoil_offset: float = 0.0


func _process(delta: float) -> void:
	_rotate_to_mouse()
	_update_recoil(delta)


## 枪口跟随鼠标旋转
func _rotate_to_mouse() -> void:
	var mouse_position: Vector2 = get_global_mouse_position()
	var target_angle: float = (mouse_position - global_position).angle()
	
	rotation = target_angle
	
	# 当枪朝左时（角度在 ±90° 之外），翻转精灵避免倒置
	if sprite:
		var is_facing_left: bool = abs(target_angle) > PI / 2
		sprite.flip_v = is_facing_left


## 更新后坐力恢复
func _update_recoil(delta: float) -> void:
	if _recoil_offset > 0:
		_recoil_offset = max(0, _recoil_offset - recoil_recovery_speed * delta)
		_apply_recoil()


## 应用后坐力到精灵
func _apply_recoil() -> void:
	if sprite:
		sprite.position.x = -_recoil_offset


## 实现具体射击逻辑
func _do_fire() -> void:
	if bullet_manager == null:
		push_warning("Gun: BulletManager is not assigned")
		return
	
	var muzzle_position: Vector2
	var direction: Vector2
	
	if muzzle:
		muzzle_position = muzzle.global_position
		direction = Vector2(cos(rotation), sin(rotation))
	else:
		muzzle_position = global_position + Vector2(cos(rotation), sin(rotation)) * 30.0
		direction = Vector2(cos(rotation), sin(rotation))
	
	var bullet: Bullet = bullet_manager.spawn_bullet(muzzle_position, direction, bullet_speed)
	if bullet:
		bullet.damage = damage
		bullet.source = "player"
	
	_apply_recoil_effect()
	AudioManager.play_se("res://resources/audios/sfx/effect_gun.mp3")


## 应用后坐力效果
func _apply_recoil_effect() -> void:
	_recoil_offset = recoil_strength
	_apply_recoil()


## 设置子弹管理器
func set_bullet_manager(manager: BulletManager) -> void:
	bullet_manager = manager
