extends Node

## 特效管理器：管理特效的生命周期
## 作为 Autoload 单例使用

## 特效类型注册表
var _effect_types: Dictionary = {}

## 活跃特效列表
var _active_effects: Array = []

## 特效层引用
var _effect_layer: Node2D = null


## 初始化特效管理器
## @param effect_layer: 特效层节点
func setup(effect_layer: Node2D) -> void:
	_effect_layer = effect_layer


## 注册特效类型
## @param type_name: 特效类型名称
## @param scene_path: 特效场景路径
## @param pool_size: 对象池初始大小（暂不使用）
func register_type(type_name: String, scene_path: String, pool_size: int = 10) -> void:
	if _effect_types.has(type_name):
		push_warning("[EffectManager] 特效类型已注册: " + type_name)
		return

	var prefab = load(scene_path) as PackedScene
	if prefab == null:
		push_error("[EffectManager] 无法加载特效场景: " + scene_path)
		return

	_effect_types[type_name] = {
		"prefab": prefab
	}

	print("[EffectManager] 注册特效类型: " + type_name)


## 生成特效
## @param type_name: 特效类型名称
## @param params: 特效参数（position, duration, z_index, scale等）
## @return: 生成的特效实例
func spawn(type_name: String, params: Dictionary = {}) -> Node:
	if not _effect_types.has(type_name):
		push_error("[EffectManager] 特效类型未注册: " + type_name)
		return null

	var type_data = _effect_types[type_name]
	var prefab = type_data["prefab"]

	var effect = prefab.instantiate()
	if effect == null:
		push_error("[EffectManager] 无法实例化特效: " + type_name)
		return null

	_active_effects.append(effect)

	# 添加到特效层
	if _effect_layer != null:
		_effect_layer.add_child(effect)
	else:
		add_child(effect)

	# 设置位置
	if params.has("position"):
		effect.global_position = params["position"]

	# 设置参数
	if effect.has_method("set_params"):
		effect.set_params(params)

	# 连接完成信号
	if effect.has_signal("effect_finished"):
		effect.effect_finished.connect(_on_effect_finished.bind(effect))

	# 调用初始化方法
	if effect.has_method("on_spawn"):
		effect.on_spawn()

	print("[EffectManager] 生成特效: " + type_name)

	return effect


## 回收特效
## @param effect: 要回收的特效实例
func recycle(effect: Node) -> void:
	if effect == null:
		return

	if effect in _active_effects:
		_active_effects.erase(effect)

	# 断开信号
	if effect.has_signal("effect_finished"):
		if effect.effect_finished.is_connected(_on_effect_finished):
			effect.effect_finished.disconnect(_on_effect_finished)

	# 调用回收方法
	if effect.has_method("on_despawn"):
		effect.on_despawn()

	# 移除并销毁
	effect.get_parent().remove_child(effect)
	effect.queue_free()

	print("[EffectManager] 回收特效")


## 回收所有特效
func recycle_all() -> void:
	for effect in _active_effects.duplicate():
		recycle(effect)


## 获取活跃特效数量
func get_active_count() -> int:
	return _active_effects.size()


## 特效完成回调
## @param effect: 完成的特效实例
func _on_effect_finished(effect: Node) -> void:
	recycle(effect)
