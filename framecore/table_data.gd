# TableData - 表格数据管理器
# Autoload 单例，提供表格数据的加载、缓存和查询功能
#
# 使用示例:
#   var item = TableData.get_by_id("items", 1001)
#   var items = TableData.query("items", func(row): return row.rarity >= 3)
#   var all_items = TableData.get_all("items")

extends Node


# 表格数据缓存: {table_name: Array[Dictionary]}
var _cache: Dictionary = {}

# 表格文件路径模板
const TABLE_PATH_TEMPLATE_JSON = "res://resources/tables/{table_name}.json"
const TABLE_PATH_TEMPLATE_CSV = "res://resources/tables/{table_name}.csv"


# 初始化
func _ready() -> void:
	pass


# 加载指定表格
# 如果表格已缓存，返回缓存数据；否则从文件加载
# @param table_name: 表格名称（不含扩展名）
# @return: 表格数据数组，每个元素是一个字典（行数据）
func load_table(table_name: String) -> Array[Dictionary]:
	# 检查缓存
	if _cache.has(table_name):
		return _cache[table_name]
	
	# 构建文件路径
	var file_path = TABLE_PATH_TEMPLATE_JSON.format({"table_name": table_name})
	
	# 通过 AssetManager 加载文件内容
	var content = _load_table_content(file_path)
	if content.is_empty():
		# 尝试 CSV 格式（兼容旧格式）
		file_path = TABLE_PATH_TEMPLATE_CSV.format({"table_name": table_name})
		content = _load_table_content(file_path)
		if content.is_empty():
			push_error("表格文件不存在或无法加载: " + file_path)
			return []
	
	# 解析数据
	var data: Array[Dictionary] = []
	if file_path.ends_with(".json"):
		data = _parse_json(content)
	else:
		data = TableLoader.parse_csv(content)
	
	# 存入缓存
	_cache[table_name] = data
	
	print("[TableData] 加载表格: ", table_name, ", 行数: ", data.size())
	
	return data


# 加载表格文件内容
func _load_table_content(file_path: String) -> String:
	# 使用 AssetManager 加载（支持开发时和打包后）
	var resource = AssetManager.load(file_path, false)
	if resource is String and not resource.is_empty():
		return resource
	
	# 如果 AssetManager 加载失败，尝试直接读取（开发时）
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file != null:
		var content = file.get_as_text()
		file.close()
		return content
	
	return ""


# 解析 JSON 文件
func _parse_json(content: String) -> Array[Dictionary]:
	var json = JSON.new()
	var error = json.parse(content)
	if error != OK:
		push_error("[TableData] JSON 解析错误: " + json.get_error_message())
		return []
	
	var data = json.data
	if data is Array:
		var result: Array[Dictionary] = []
		for item in data:
			if item is Dictionary:
				result.append(item)
		return result
	
	return []


# 按 ID 查询单行数据
# @param table_name: 表格名称
# @param id: 要查询的 ID 值
# @return: 匹配的行数据字典，未找到返回空字典
func get_by_id(table_name: String, id: int) -> Dictionary:
	var data = load_table(table_name)
	
	for row in data:
		if row.get("id") == id:
			return row
	
	push_warning("[TableData] 未找到数据: table=" + table_name + ", id=" + str(id))
	return {}


# 按条件查询数据
# @param table_name: 表格名称
# @param condition: 条件回调函数，接收行数据字典，返回 bool
# @return: 符合条件的行数据数组
func query(table_name: String, condition: Callable) -> Array[Dictionary]:
	var data = load_table(table_name)
	var result: Array[Dictionary] = []
	
	for row in data:
		if condition.call(row):
			result.append(row)
	
	return result


# 获取表格所有数据
# @param table_name: 表格名称
# @return: 表格所有行数据
func get_all(table_name: String) -> Array[Dictionary]:
	return load_table(table_name)


# 热重载指定表格
# 清除缓存并从文件重新加载
# @param table_name: 表格名称
func reload(table_name: String) -> void:
	# 从缓存中移除
	if _cache.has(table_name):
		_cache.erase(table_name)
		print("[TableData] 清除缓存: ", table_name)
	
	# 重新加载
	load_table(table_name)
	print("[TableData] 热重载完成: ", table_name)


# 热重载所有已缓存的表格
func reload_all() -> void:
	var table_names = _cache.keys()
	for table_name in table_names:
		reload(table_name)


# 检查表格是否已加载到缓存
# @param table_name: 表格名称
# @return: 是否已缓存
func is_cached(table_name: String) -> bool:
	return _cache.has(table_name)


# 清除指定表格的缓存
# @param table_name: 表格名称
func clear_cache(table_name: String) -> void:
	if _cache.has(table_name):
		_cache.erase(table_name)
		print("[TableData] 清除缓存: ", table_name)


# 清除所有表格缓存
func clear_all_cache() -> void:
	_cache.clear()
	print("[TableData] 清除所有缓存")


# 获取已缓存的表格名称列表
# @return: 表格名称数组
func get_cached_tables() -> Array[String]:
	var result: Array[String] = []
	for table_name in _cache.keys():
		result.append(table_name)
	return result


# 获取表格行数
# @param table_name: 表格名称
# @return: 行数，表格不存在返回 0
func get_row_count(table_name: String) -> int:
	var data = load_table(table_name)
	return data.size()
