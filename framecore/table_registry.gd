extends Node

## 表格注册表
## 作为 Autoload 单例，用于管理所有需要预加载的表格
## 提供表格注册和批量预加载功能

# 已注册的表格名称列表
var _registered_tables: Array[String] = []

# 预加载状态跟踪
var _preloaded_tables: Array[String] = []


func _ready() -> void:
	## 节点就绪时自动预加载所有注册的表格
	preload_registered_tables()


## 注册一个表格到预加载列表
## [param table_name] 表格名称（不包含路径和扩展名）
func register_table(table_name: String) -> void:
	if table_name.is_empty():
		push_warning("[TableRegistry] Cannot register empty table name")
		return
	
	if _registered_tables.has(table_name):
		push_warning("[TableRegistry] Table '%s' is already registered" % table_name)
		return
	
	_registered_tables.append(table_name)
	print("[TableRegistry] Registered table: %s" % table_name)


## 批量预加载所有已注册的表格
## 使用 TableData 加载表格数据
func preload_registered_tables() -> void:
	if _registered_tables.is_empty():
		print("[TableRegistry] No tables registered for preloading")
		return
	
	print("[TableRegistry] Starting to preload %d registered tables..." % _registered_tables.size())
	
	var success_count := 0
	var fail_count := 0
	
	for table_name in _registered_tables:
		if _preload_table(table_name):
			success_count += 1
		else:
			fail_count += 1
	
	print("[TableRegistry] Preload complete. Success: %d, Failed: %d" % [success_count, fail_count])


## 获取已注册的表格名称列表
## [return] 已注册表格名称数组
func get_registered_tables() -> Array[String]:
	return _registered_tables.duplicate()


## 获取已预加载的表格名称列表
## [return] 已预加载表格名称数组
func get_preloaded_tables() -> Array[String]:
	return _preloaded_tables.duplicate()


## 检查表格是否已注册
## [param table_name] 表格名称
## [return] 是否已注册
func is_table_registered(table_name: String) -> bool:
	return _registered_tables.has(table_name)


## 检查表格是否已预加载
## [param table_name] 表格名称
## [return] 是否已预加载
func is_table_preloaded(table_name: String) -> bool:
	return _preloaded_tables.has(table_name)


## 清除所有已注册的表格和预加载状态
func clear() -> void:
	_registered_tables.clear()
	_preloaded_tables.clear()
	print("[TableRegistry] All tables cleared")


## 获取已注册但未预加载的表格列表
## [return] 未预加载的表格名称数组
func get_pending_tables() -> Array[String]:
	var pending: Array[String] = []
	for table_name in _registered_tables:
		if not _preloaded_tables.has(table_name):
			pending.append(table_name)
	return pending


# 内部方法：预加载单个表格
# [param table_name] 表格名称
# [return] 是否加载成功
func _preload_table(table_name: String) -> bool:
	# 检查是否已预加载
	if _preloaded_tables.has(table_name):
		return true
	
	# 使用 TableData 加载表格
	var data = TableData.load_table(table_name)
	
	if data.is_empty():
		push_error("[TableRegistry] Failed to preload table: %s" % table_name)
		return false
	
	_preloaded_tables.append(table_name)
	print("[TableRegistry] Preloaded table: %s (%d rows)" % [table_name, data.size()])
	return true
