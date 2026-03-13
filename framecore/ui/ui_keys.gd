class_name UIRegistry extends RefCounted
## UI 注册表：框架提供 UI 注册机制，业务层负责注册具体 UI

static var _keys: Dictionary = {}

## 注册 UI
static func register(ui_id: StringName, path: String) -> void:
	_keys[ui_id] = UIKey.new(ui_id, path)

## 批量注册 UI
static func register_batch(ui_definitions: Dictionary) -> void:
	for ui_id: StringName in ui_definitions:
		var path: String = ui_definitions[ui_id]
		register(ui_id, path)

## 获取 UI Key
static func get_key(ui_id: StringName) -> RefCounted:
	return _keys.get(ui_id)

## 检查 UI 是否已注册
static func has_ui(ui_id: StringName) -> bool:
	return _keys.has(ui_id)

## 获取所有已注册的 UI ID
static func get_all_ui_ids() -> Array[StringName]:
	var result: Array[StringName] = []
	result.assign(_keys.keys())
	return result

## 清空注册表（用于测试或重置）
static func clear() -> void:
	_keys.clear()
