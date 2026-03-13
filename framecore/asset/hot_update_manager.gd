class_name HotUpdateManager extends Node
## 热更新管理器
## 负责资源热更新、版本检查、下载和应用

# 信号定义
signal update_checked(result: Dictionary)      # 更新检查完成
signal download_progress(current: int, total: int)  # 下载进度
signal download_completed(save_path: String)   # 下载完成
signal download_failed(error: String)          # 下载失败
signal update_applied(pck_path: String)        # 更新应用完成

# 常量
const _version_file_path: String = "user://version.json"

# 成员变量
var _http_request: HTTPRequest
var _download_http: HTTPRequest
var _is_downloading: bool = false
var _current_download_path: String = ""
var _server_url: String = ""


func _ready() -> void:
	# 创建 HTTPRequest 节点用于版本检查
	_http_request = HTTPRequest.new()
	add_child(_http_request)
	_http_request.request_completed.connect(_on_version_check_completed)

	# 创建 HTTPRequest 节点用于下载
	_download_http = HTTPRequest.new()
	add_child(_download_http)
	_download_http.request_completed.connect(_on_download_completed)


# ==================== 版本检查 ====================

## 检查更新
## @param server_url 服务器地址
## @return 返回检查结果字典
func check_update(server_url: String) -> Dictionary:
	_server_url = server_url
	var result: Dictionary = {
		"has_update": false,
		"updates": [],
		"version": ""
	}

	# 请求服务器版本信息
	var version_url: String = server_url.trim_suffix("/") + "/version.json"
	var error: int = _http_request.request(version_url)

	if error != OK:
		result["has_update"] = false
		update_checked.emit(result)
		return result

	# 异步请求，结果通过信号返回
	return result


## 版本检查请求完成回调
func _on_version_check_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	var check_result: Dictionary = {
		"has_update": false,
		"updates": [],
		"version": ""
	}

	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		update_checked.emit(check_result)
		return

	# 解析服务器版本信息
	var json: JSON = JSON.new()
	var parse_error: int = json.parse(body.get_string_from_utf8())

	if parse_error != OK:
		update_checked.emit(check_result)
		return

	var server_info: Dictionary = json.data
	var server_version: String = server_info.get("version", "")
	var local_version: String = get_local_version()

	check_result["version"] = server_version

	# 对比版本
	if server_version != local_version:
		check_result["has_update"] = true
		check_result["updates"] = server_info.get("updates", [])

	update_checked.emit(check_result)


# ==================== 资源下载 ====================

## 下载更新包
## @param update_info 更新信息
## @param save_path 保存路径
func download_update(update_info: Dictionary, save_path: String) -> void:
	if _is_downloading:
		download_failed.emit("已有下载任务在进行中")
		return

	_is_downloading = true
	_current_download_path = save_path

	# 获取下载URL
	var download_url: String = update_info.get("url", "")
	if download_url.is_empty():
		_is_downloading = false
		download_failed.emit("下载地址为空")
		return

	# 如果是相对路径，拼接服务器地址
	if not download_url.begins_with("http"):
		download_url = _server_url.trim_suffix("/") + "/" + download_url.lstrip("/")

	# 检查断点续传
	var downloaded_size: int = 0
	if FileAccess.file_exists(save_path):
		var file: FileAccess = FileAccess.open(save_path, FileAccess.READ)
		if file:
			downloaded_size = file.get_length()
			file.close()

	# 设置下载范围（断点续传）
	if downloaded_size > 0:
		_download_http.set_download_file(save_path)
		var headers: PackedStringArray = ["Range: bytes=" + str(downloaded_size) + "-"]
		var error: int = _download_http.request(download_url, headers)
		if error != OK:
			_is_downloading = false
			download_failed.emit("发起下载请求失败")
			return
	else:
		_download_http.set_download_file(save_path)
		var error: int = _download_http.request(download_url)
		if error != OK:
			_is_downloading = false
			download_failed.emit("发起下载请求失败")
			return

	# 启动进度监控
	_monitor_download_progress()


## 监控下载进度
func _monitor_download_progress() -> void:
	while _is_downloading:
		var downloaded_bytes: int = _download_http.get_downloaded_bytes()
		var total_bytes: int = _download_http.get_body_size()

		if total_bytes > 0:
			download_progress.emit(downloaded_bytes, total_bytes)

		await get_tree().create_timer(0.1).timeout


## 取消下载
func cancel_download() -> void:
	if not _is_downloading:
		return

	_is_downloading = false
	_download_http.cancel_request()

	# 删除未完成的下载文件
	if FileAccess.file_exists(_current_download_path):
		DirAccess.remove_absolute(_current_download_path)

	_current_download_path = ""


## 下载完成回调
func _on_download_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	_is_downloading = false

	if result != HTTPRequest.RESULT_SUCCESS:
		# 检查是否为断点续传的部分内容响应
		if response_code == 206:
			download_completed.emit(_current_download_path)
			return

		download_failed.emit("下载失败，错误码: " + str(result))
		return

	download_completed.emit(_current_download_path)


# ==================== 更新应用 ====================

## 应用更新
## @param pck_path PCK文件路径
## @return 是否成功
func apply_update(pck_path: String) -> bool:
	# 检查文件是否存在
	if not FileAccess.file_exists(pck_path):
		push_error("PCK文件不存在: " + pck_path)
		return false

	# 加载PCK文件
	var success: bool = ProjectSettings.load_resource_pack(pck_path)

	if not success:
		push_error("加载PCK文件失败: " + pck_path)
		return false

	# 更新本地版本记录
	# 从PCK路径中提取版本信息或使用服务器版本
	var version: String = _extract_version_from_pck_path(pck_path)
	if not version.is_empty():
		set_local_version(version)

	update_applied.emit(pck_path)
	return true


## 从PCK路径提取版本号
func _extract_version_from_pck_path(pck_path: String) -> String:
	# 尝试从文件名提取版本号，如: update_v1.0.1.pck
	var file_name: String = pck_path.get_file()
	var regex: RegEx = RegEx.new()
	regex.compile("v(\\d+\\.\\d+\\.\\d+)")
	var result: RegExMatch = regex.search(file_name)

	if result:
		return result.get_string(1)

	return ""


# ==================== 本地版本管理 ====================

## 获取本地版本
## @return 本地版本号
func get_local_version() -> String:
	if not FileAccess.file_exists(_version_file_path):
		return "0.0.0"

	var file: FileAccess = FileAccess.open(_version_file_path, FileAccess.READ)
	if not file:
		return "0.0.0"

	var content: String = file.get_as_text()
	file.close()

	var json: JSON = JSON.new()
	if json.parse(content) != OK:
		return "0.0.0"

	var data: Dictionary = json.data
	return data.get("version", "0.0.0")


## 设置本地版本
## @param version 版本号
func set_local_version(version: String) -> void:
	var data: Dictionary = {
		"version": version,
		"update_time": Time.get_datetime_string_from_system()
	}

	var file: FileAccess = FileAccess.open(_version_file_path, FileAccess.WRITE)
	if not file:
		push_error("无法写入版本文件")
		return

	file.store_string(JSON.stringify(data))
	file.close()
