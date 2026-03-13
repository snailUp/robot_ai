# TableLoader - CSV 解析器
# 静态类，提供 CSV 文件解析功能
# 支持数据类型自动转换

class_name TableLoader


# 从文件路径解析 CSV
static func parse_csv_from_file(file_path: String) -> Array[Dictionary]:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("无法打开文件: " + file_path)
		return []
	
	var content = file.get_as_text()
	file.close()
	
	return parse_csv(content)


# 从字符串解析 CSV
static func parse_csv(content: String) -> Array[Dictionary]:
	if content.is_empty():
		return []
	
	var lines = _split_lines(content)
	if lines.is_empty():
		return []
	
	# 解析表头
	var headers = _parse_line(lines[0])
	if headers.is_empty():
		return []
	
	var result: Array[Dictionary] = []
	
	# 解析数据行
	for i in range(1, lines.size()):
		var line = lines[i].strip_edges()
		if line.is_empty():
			continue
		
		var values = _parse_line(lines[i])
		var row: Dictionary = {}
		
		for j in range(min(headers.size(), values.size())):
			var key = headers[j]
			var value = _convert_type(values[j])
			row[key] = value
		
		result.append(row)
	
	return result


# 将内容按行分割（处理不同换行符）
static func _split_lines(content: String) -> PackedStringArray:
	# 统一换行符为 \n
	var normalized = content.replace("\r\n", "\n").replace("\r", "\n")
	return normalized.split("\n")


# 解析单行 CSV（处理引号和逗号）
static func _parse_line(line: String) -> PackedStringArray:
	var result: PackedStringArray = []
	var current = ""
	var in_quotes = false
	var i = 0
	
	while i < line.length():
		var char = line[i]
		
		if char == '"':
			if in_quotes:
				# 检查是否是转义引号 ("")
				if i + 1 < line.length() and line[i + 1] == '"':
					current += '"'
					i += 1  # 跳过下一个引号
				else:
					in_quotes = false
			else:
				in_quotes = true
		elif char == ',' and not in_quotes:
			result.append(current.strip_edges())
			current = ""
		else:
			current += char
		
		i += 1
	
	# 添加最后一个字段
	result.append(current.strip_edges())
	
	return result


# 自动转换数据类型
static func _convert_type(value: String) -> Variant:
	value = value.strip_edges()
	
	if value.is_empty():
		return ""
	
	# 尝试解析布尔值
	var lower = value.to_lower()
	if lower == "true":
		return true
	if lower == "false":
		return false
	
	# 尝试解析数组 [ ... ]
	if value.begins_with("[") and value.ends_with("]"):
		var array_result = _parse_array(value)
		if array_result != null:
			return array_result
	
	# 尝试解析字典 { ... }
	if value.begins_with("{") and value.ends_with("}"):
		var dict_result = _parse_dict(value)
		if dict_result != null:
			return dict_result
	
	# 尝试解析整数
	if value.is_valid_int():
		return value.to_int()
	
	# 尝试解析浮点数
	if value.is_valid_float():
		return value.to_float()
	
	# 返回字符串
	return value


# 解析数组
static func _parse_array(value: String) -> Variant:
	# 首先尝试 JSON 解析
	var json = JSON.new()
	var error = json.parse(value)
	if error == OK:
		var result = json.get_data()
		if result is Array:
			return result
	
	# 如果 JSON 解析失败，尝试逗号分隔解析
	var inner = value.substr(1, value.length() - 2).strip_edges()
	if inner.is_empty():
		return []
	
	var result: Array = []
	var items = _split_array_items(inner)
	
	for item in items:
		result.append(_convert_type(item.strip_edges()))
	
	return result


# 分割数组项（处理嵌套和引号）
static func _split_array_items(content: String) -> PackedStringArray:
	var result: PackedStringArray = []
	var current = ""
	var depth = 0
	var in_quotes = false
	
	for i in range(content.length()):
		var char = content[i]
		
		if char == '"':
			in_quotes = not in_quotes
			current += char
		elif not in_quotes:
			if char == '[' or char == '{':
				depth += 1
				current += char
			elif char == ']' or char == '}':
				depth -= 1
				current += char
			elif char == ',' and depth == 0:
				result.append(current.strip_edges())
				current = ""
			else:
				current += char
		else:
			current += char
	
	if not current.is_empty():
		result.append(current.strip_edges())
	
	return result


# 解析字典
static func _parse_dict(value: String) -> Variant:
	var json = JSON.new()
	var error = json.parse(value)
	if error == OK:
		var result = json.get_data()
		if result is Dictionary:
			return result
	
	return null


# 辅助方法：将数组转换为 CSV 字符串（用于导出）
static func array_to_csv(data: Array[Dictionary]) -> String:
	if data.is_empty():
		return ""
	
	# 收集所有列名
	var headers: Array[String] = []
	for row in data:
		for key in row.keys():
			if not headers.has(key):
				headers.append(key)
	
	# 构建 CSV 内容
	var lines: Array[String] = []
	
	# 表头行
	var header_line = ""
	for i in range(headers.size()):
		if i > 0:
			header_line += ","
		header_line += _escape_csv_field(headers[i])
	lines.append(header_line)
	
	# 数据行
	for row in data:
		var line = ""
		for i in range(headers.size()):
			if i > 0:
				line += ","
			var value = row.get(headers[i], "")
			line += _escape_csv_field(_value_to_string(value))
		lines.append(line)
	
	return "\n".join(lines)


# 转义 CSV 字段
static func _escape_csv_field(field: String) -> String:
	# 如果字段包含逗号、引号或换行符，需要用引号包裹
	if field.find(",") != -1 or field.find("\"") != -1 or field.find("\n") != -1:
		# 将引号替换为两个引号
		var escaped = field.replace("\"", "\"\"")
		return "\"" + escaped + "\""
	return field


# 将值转换为字符串
static func _value_to_string(value: Variant) -> String:
	match typeof(value):
		TYPE_NIL:
			return ""
		TYPE_BOOL:
			return "true" if value else "false"
		TYPE_INT, TYPE_FLOAT:
			return str(value)
		TYPE_ARRAY, TYPE_DICTIONARY:
			return JSON.stringify(value)
		_:
			return str(value)
