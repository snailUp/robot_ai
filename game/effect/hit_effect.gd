class_name HitEffect
extends Node2D

## 子弹击中特效
## 使用 AnimatedSprite2D 播放动画
## 动画播放完成后自动回收

## 特效完成信号
signal effect_finished

## 动画精灵
@onready var _sprite: AnimatedSprite2D = $AnimatedSprite2D

## 是否正在播放
var _is_playing: bool = false

## 是否已初始化
var _initialized: bool = false


func _ready() -> void:
	_load_frames()


## 加载动画帧
func _load_frames() -> void:
	if _initialized:
		return

	var frames = _sprite.sprite_frames
	if frames == null:
		frames = SpriteFrames.new()
		_sprite.sprite_frames = frames

	# 清空并重新添加帧
	if frames.has_animation("default"):
		frames.clear("default")
	else:
		frames.add_animation("default")

	var frame_paths = [
		"res://resources/animation/effect/gunfire/1.png",
		"res://resources/animation/effect/gunfire/2.png",
		"res://resources/animation/effect/gunfire/3.png",
		"res://resources/animation/effect/gunfire/4.png"
	]

	for frame_path in frame_paths:
		var texture = AssetManager.load(frame_path)
		if texture != null:
			frames.add_frame("default", texture)

	frames.set_animation_loop("default", false)
	frames.set_animation_speed("default", 15.0)

	_sprite.animation = "default"
	_initialized = true


func _process(_delta: float) -> void:
	if not _is_playing:
		return

	if _sprite != null and not _sprite.is_playing():
		_is_playing = false
		effect_finished.emit()


## 特效初始化
func on_spawn() -> void:
	_is_playing = true
	if _sprite != null:
		_sprite.play("default")


## 特效回收
func on_despawn() -> void:
	_is_playing = false
	if _sprite != null and _sprite.is_playing():
		_sprite.stop()


## 设置特效参数
func set_params(params: Dictionary) -> void:
	if params.has("scale"):
		scale = params["scale"]

	if params.has("z_index"):
		z_index = params["z_index"]
