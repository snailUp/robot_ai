## 战场围墙系统
## 管理战场边界，创建可视化围墙并限制角色活动范围
class_name BattleArena
extends Node2D

## 围墙创建完成信号
signal arena_created()
## 围墙销毁完成信号
signal arena_destroyed()

## 战场尺寸
@export var arena_size: Vector2 = Vector2(1600, 1200)
## 围墙厚度
@export var wall_thickness: float = 61.0
## 淡入淡出时间
@export var fade_duration: float = 0.5

## 围墙容器
var _walls_container: Node2D = null
## 四面围墙节点
var _walls: Array[StaticBody2D] = []
## 围墙可视化节点
var _wall_visuals: Array[Node2D] = []
## 围墙碰撞形状
var _wall_collisions: Array[CollisionShape2D] = []
## 当前锁定的摄像机
var _locked_camera: Camera2D = null
## 围墙中心位置
var _center: Vector2 = Vector2.ZERO
## 是否已创建围墙
var _is_created: bool = false
## 淡入淡出 Tween
var _fade_tween: Tween = null


func _ready() -> void:
	_walls_container = Node2D.new()
	_walls_container.name = "WallsContainer"
	_walls_container.z_index = LayerConstants.Z_WALL
	add_child(_walls_container)


## 以指定位置为中心创建围墙
func create_arena(center: Vector2) -> void:
	if _is_created:
		push_warning("BattleArena: 围墙已存在，请先销毁再创建")
		return
	
	_center = center
	_is_created = true
	
	# 创建四面围墙
	_create_walls()
	
	# 执行淡入动画
	_fade_in()


## 销毁围墙
func destroy_arena() -> void:
	if not _is_created:
		push_warning("BattleArena: 围墙不存在")
		return
	
	# 执行淡出动画
	_fade_out()


## 返回战场边界 Rect2
func get_bounds() -> Rect2:
	var half_size = arena_size / 2.0
	return Rect2(
		_center - half_size,
		arena_size
	)


## 锁定摄像机到战场边界
func lock_camera(camera: Camera2D) -> void:
	if camera == null:
		push_warning("BattleArena: 摄像机为空")
		return
	
	_locked_camera = camera
	
	# 设置摄像机边界
	var bounds = get_bounds()
	camera.limit_left = bounds.position.x
	camera.limit_top = bounds.position.y
	camera.limit_right = bounds.end.x
	camera.limit_bottom = bounds.end.y


## 解锁摄像机边界
func unlock_camera() -> void:
	if _locked_camera == null:
		return
	
	# 重置摄像机边界
	_locked_camera.limit_left = -10000000
	_locked_camera.limit_top = -10000000
	_locked_camera.limit_right = 10000000
	_locked_camera.limit_bottom = 10000000
	
	_locked_camera = null


## 创建四面围墙
func _create_walls() -> void:
	# 清理旧围墙
	_clear_walls()
	
	var half_width = arena_size.x / 2.0
	var half_height = arena_size.y / 2.0
	
	# 围墙配置: [位置偏移, 尺寸]
	var wall_configs: Array[Dictionary] = [
		# 上墙
		{
			"offset": Vector2(0, -half_height - wall_thickness / 2.0),
			"size": Vector2(arena_size.x + wall_thickness * 2.0, wall_thickness)
		},
		# 下墙
		{
			"offset": Vector2(0, half_height + wall_thickness / 2.0),
			"size": Vector2(arena_size.x + wall_thickness * 2.0, wall_thickness)
		},
		# 左墙
		{
			"offset": Vector2(-half_width - wall_thickness / 2.0, 0),
			"size": Vector2(wall_thickness, arena_size.y)
		},
		# 右墙
		{
			"offset": Vector2(half_width + wall_thickness / 2.0, 0),
			"size": Vector2(wall_thickness, arena_size.y)
		}
	]
	
	for i in range(wall_configs.size()):
		var config = wall_configs[i]
		var wall = _create_single_wall(i, config["offset"], config["size"])
		_walls.append(wall)


## 创建单个围墙
func _create_single_wall(index: int, offset: Vector2, size: Vector2) -> StaticBody2D:
	var wall = StaticBody2D.new()
	wall.name = "Wall_%d" % index
	wall.position = _center + offset
	
	var collision_config = LayerConstants.get_obstacle_collision()
	LayerConstants.apply_collision_to_node(wall, collision_config)
	
	_walls_container.add_child(wall)
	
	# 创建碰撞形状
	var collision = CollisionShape2D.new()
	collision.name = "CollisionShape2D"
	var shape = RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	wall.add_child(collision)
	_wall_collisions.append(collision)
	
	# 创建可视化 - 使用砖头纹理平铺
	var texture = preload("res://resources/sprites/map/img_zhauntou.png")
	var actual_texture_size = Vector2(61.0, 63.0)
	var visuals_container = Node2D.new()
	visuals_container.name = "VisualsContainer"
	visuals_container.modulate = Color(1.0, 1.0, 1.0, 0.0)
	wall.add_child(visuals_container)
	
	# 平铺纹理 - 使用实际纹理尺寸
	var tiles_x = ceili(size.x / actual_texture_size.x)
	var tiles_y = ceili(size.y / actual_texture_size.y)
	var start_pos = Vector2(-size.x / 2.0, -size.y / 2.0)
	
	for tx in range(tiles_x):
		for ty in range(tiles_y):
			var visual = Sprite2D.new()
			visual.texture = texture
			visual.centered = false
			var tile_pos = start_pos + Vector2(tx * actual_texture_size.x, ty * actual_texture_size.y)
			# 裁剪超出部分
			var remaining_x = size.x - tx * actual_texture_size.x
			var remaining_y = size.y - ty * actual_texture_size.y
			visual.region_enabled = true
			visual.region_rect = Rect2(0, 0, minf(remaining_x, actual_texture_size.x), minf(remaining_y, actual_texture_size.y))
			visual.position = tile_pos
			visuals_container.add_child(visual)
	
	_wall_visuals.append(visuals_container)
	
	return wall


## 清理围墙
func _clear_walls() -> void:
	for wall in _walls:
		if is_instance_valid(wall):
			wall.queue_free()
	
	_walls.clear()
	_wall_visuals.clear()
	_wall_collisions.clear()


## 淡入动画
func _fade_in() -> void:
	# 停止之前的动画
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	
	_fade_tween = create_tween()
	_fade_tween.set_parallel(true)
	
	for visual in _wall_visuals:
		_fade_tween.tween_property(visual, "modulate:a", 1.0, fade_duration)
	
	_fade_tween.set_parallel(false)
	_fade_tween.tween_callback(_on_fade_in_complete)


## 淡出动画
func _fade_out() -> void:
	# 停止之前的动画
	if _fade_tween and _fade_tween.is_valid():
		_fade_tween.kill()
	
	_fade_tween = create_tween()
	_fade_tween.set_parallel(true)
	
	for visual in _wall_visuals:
		_fade_tween.tween_property(visual, "modulate:a", 0.0, fade_duration)
	
	_fade_tween.set_parallel(false)
	_fade_tween.tween_callback(_on_fade_out_complete)


## 淡入完成回调
func _on_fade_in_complete() -> void:
	arena_created.emit()


## 淡出完成回调
func _on_fade_out_complete() -> void:
	_is_created = false
	_clear_walls()
	arena_destroyed.emit()
