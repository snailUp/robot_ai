class_name BulletManager
extends Node
## 子弹管理器：封装对象池，管理子弹的生成和回收
## 使用 ObjectPool 实现子弹复用，提升性能

## 子弹场景路径
const BULLET_SCENE_PATH := "res://resources/prefabs/bullet/bullet.tscn"

## 敌人子弹场景路径
const ENEMY_BULLET_SCENE_PATH := "res://resources/prefabs/bullet/enemy_bullet.tscn"

## 对象池初始大小
const INITIAL_POOL_SIZE := 20

## 对象池最大大小
const MAX_POOL_SIZE := 200

## 子弹场景预加载
var _bullet_prefab: PackedScene

## 敌人子弹场景预加载
var _enemy_bullet_prefab: PackedScene

## 子弹对象池
var _bullet_pool: ObjectPool

## 敌人子弹对象池
var _enemy_bullet_pool: ObjectPool


func _ready() -> void:
	_preload_resources()
	call_deferred("_setup_bullet_pool")


## 预加载子弹场景
func _preload_resources() -> void:
	_bullet_prefab = preload(BULLET_SCENE_PATH)
	_enemy_bullet_prefab = preload(ENEMY_BULLET_SCENE_PATH)


## 初始化子弹对象池
func _setup_bullet_pool() -> void:
	_bullet_pool = ObjectPool.new()
	_bullet_pool.prefab = _bullet_prefab
	_bullet_pool.initial_size = INITIAL_POOL_SIZE
	_bullet_pool.max_size = MAX_POOL_SIZE
	_bullet_pool.auto_expand = true
	
	_enemy_bullet_pool = ObjectPool.new()
	_enemy_bullet_pool.prefab = _enemy_bullet_prefab
	_enemy_bullet_pool.initial_size = INITIAL_POOL_SIZE
	_enemy_bullet_pool.max_size = MAX_POOL_SIZE
	_enemy_bullet_pool.auto_expand = true
	
	var bullet_layer = LayerManager.get_bullet_layer()
	if bullet_layer != null:
		bullet_layer.add_child(_bullet_pool)
		bullet_layer.add_child(_enemy_bullet_pool)
		_bullet_pool.set_spawn_parent(bullet_layer)
		_enemy_bullet_pool.set_spawn_parent(bullet_layer)
	else:
		add_child(_bullet_pool)
		add_child(_enemy_bullet_pool)
		push_warning("[BulletManager] 子弹层未初始化，子弹池添加到本地")


## 生成子弹
## @param position: 子弹初始位置
## @param direction: 子弹飞行方向（单位向量）
## @param speed: 子弹飞行速度（像素/秒）
## @return: 生成的子弹实例，如果池耗尽则返回null
func spawn_bullet(position: Vector2, direction: Vector2, speed: float) -> Bullet:
	var bullet: Bullet = _bullet_pool.acquire()
	
	if bullet == null:
		push_warning("BulletManager: Failed to spawn bullet, pool exhausted")
		return null
	
	# 设置子弹属性
	bullet.set_initial_position(position)
	bullet.set_direction(direction)
	bullet.speed = speed
	
	# 连接回收信号（确保不重复连接）
	if not bullet.request_recycle.is_connected(recycle_bullet):
		bullet.request_recycle.connect(recycle_bullet.bind(bullet))
	
	return bullet


## 生成敌人子弹
## @param position: 子弹初始位置
## @param direction: 子弹飞行方向（单位向量）
## @param speed: 子弹飞行速度（像素/秒）
## @return: 生成的子弹实例，如果池耗尽则返回null
func spawn_enemy_bullet(position: Vector2, direction: Vector2, speed: float) -> Bullet:
	var bullet: Bullet = _enemy_bullet_pool.acquire()
	
	if bullet == null:
		push_warning("BulletManager: Failed to spawn enemy bullet, pool exhausted")
		return null
	
	# 设置子弹属性
	bullet.set_initial_position(position)
	bullet.set_direction(direction)
	bullet.speed = speed
	
	# 连接回收信号（确保不重复连接）
	if not bullet.request_recycle.is_connected(recycle_enemy_bullet):
		bullet.request_recycle.connect(recycle_enemy_bullet.bind(bullet))
	
	return bullet


## 回收子弹
## @param bullet: 要回收的子弹实例
func recycle_bullet(bullet: Bullet) -> void:
	if bullet == null:
		return
	
	# 断开信号连接
	if bullet.request_recycle.is_connected(recycle_bullet):
		bullet.request_recycle.disconnect(recycle_bullet)
	
	# 释放回对象池
	_bullet_pool.release(bullet)


## 回收敌人子弹
## @param bullet: 要回收的子弹实例
func recycle_enemy_bullet(bullet: Bullet) -> void:
	if bullet == null:
		return
	
	# 断开信号连接
	if bullet.request_recycle.is_connected(recycle_enemy_bullet):
		bullet.request_recycle.disconnect(recycle_enemy_bullet)
	
	# 释放回对象池
	_enemy_bullet_pool.release(bullet)


## 获取当前活跃的子弹数量
func get_active_bullet_count() -> int:
	return _bullet_pool.get_active_count()


## 获取池中可用子弹数量
func get_pooled_bullet_count() -> int:
	return _bullet_pool.get_pooled_count()


## 回收所有子弹
func recycle_all_bullets() -> void:
	_bullet_pool.release_all()


## 清空子弹池
func clear_pool() -> void:
	_bullet_pool.clear()
