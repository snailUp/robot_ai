class_name ResourcePool extends Node
## 资源缓存池：缓存已加载的资源，避免重复IO
## 支持同步/异步加载，支持批量预加载
## 支持引用计数、加载优先级、加载取消

## 加载优先级枚举
enum LoadPriority {
	LOW = -1,		## 低优先级
	NORMAL = 0,		## 普通优先级
	HIGH = 1		## 高优先级
}

signal resource_loaded(path: String, resource: Resource)
signal load_progress(current: int, total: int)
signal preload_completed()
signal ref_count_changed(path: String, count: int)

var _cache: Dictionary = {}
var _loading: Dictionary = {}
var _ref_counts: Dictionary = {}
var _pending_loads: Array = []  ## 按优先级排序的待加载队列 [{path, priority, use_cache}]


func load_sync(path: String, use_cache: bool = true) -> Resource:
	if use_cache and _cache.has(path):
		return _cache[path]
	
	if not ResourceLoader.exists(path):
		push_error("ResourcePool: resource not found - %s" % path)
		return null
	
	var resource := ResourceLoader.load(path)
	if use_cache and resource != null:
		_cache[path] = resource
		# 初始化引用计数为1
		if not _ref_counts.has(path):
			_ref_counts[path] = 1
			ref_count_changed.emit(path, 1)
	return resource


func load_async(path: String, priority: int = LoadPriority.NORMAL, use_cache: bool = true) -> void:
	if use_cache and _cache.has(path):
		resource_loaded.emit(path, _cache[path])
		return
	
	if _loading.has(path):
		return
	
	if not ResourceLoader.exists(path):
		push_error("ResourcePool: resource not found - %s" % path)
		return
	
	# 添加到待加载队列
	_add_to_pending_queue(path, priority, use_cache)
	_process_pending_loads()


func _add_to_pending_queue(path: String, priority: int, use_cache: bool) -> void:
	# 检查是否已在队列中
	for item in _pending_loads:
		if item.path == path:
			# 更新优先级（取较高值）
			if priority > item.priority:
				item.priority = priority
			return
	
	var item := {
		"path": path,
		"priority": priority,
		"use_cache": use_cache
	}
	
	# 按优先级插入队列（高优先级在前）
	var insert_index := 0
	for i in range(_pending_loads.size()):
		if priority > _pending_loads[i].priority:
			insert_index = i
			break
		insert_index = i + 1
	
	_pending_loads.insert(insert_index, item)


func _process_pending_loads() -> void:
	if _pending_loads.is_empty():
		return
	
	# 取出最高优先级的任务
	var item = _pending_loads.pop_front()
	var path: String = item.path
	var use_cache: bool = item.use_cache
	
	ResourceLoader.load_threaded_request(path)
	_loading[path] = true
	_check_loading_status(path, use_cache)


func _check_loading_status(path: String, use_cache: bool) -> void:
	var status := ResourceLoader.load_threaded_get_status(path)
	
	match status:
		ResourceLoader.THREAD_LOAD_LOADED:
			var resource := ResourceLoader.load_threaded_get(path)
			_loading.erase(path)
			if use_cache and resource != null:
				_cache[path] = resource
				# 初始化引用计数为1
				if not _ref_counts.has(path):
					_ref_counts[path] = 1
					ref_count_changed.emit(path, 1)
			resource_loaded.emit(path, resource)
			# 处理下一个待加载任务
			_process_pending_loads()
		
		ResourceLoader.THREAD_LOAD_FAILED:
			_loading.erase(path)
			push_error("ResourcePool: failed to load - %s" % path)
			# 处理下一个待加载任务
			_process_pending_loads()
		
		ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().process_frame
			_check_loading_status(path, use_cache)


func preload_batch(paths: Array[String], use_cache: bool = true) -> void:
	var total := paths.size()
	var current := 0
	
	for path in paths:
		if use_cache and _cache.has(path):
			current += 1
			load_progress.emit(current, total)
			continue
		
		load_async(path, LoadPriority.NORMAL, use_cache)
		await resource_loaded
		current += 1
		load_progress.emit(current, total)
	
	preload_completed.emit()


func preload_batch_async(paths: Array[String], use_cache: bool = true) -> void:
	var total := paths.size()
	var loaded := 0
	
	for path in paths:
		if use_cache and _cache.has(path):
			loaded += 1
			load_progress.emit(loaded, total)
			continue
		
		if not ResourceLoader.exists(path):
			loaded += 1
			continue
		
		ResourceLoader.load_threaded_request(path)
		_loading[path] = true
	
	for path in paths:
		if not _loading.has(path):
			continue
		
		while ResourceLoader.load_threaded_get_status(path) == ResourceLoader.THREAD_LOAD_IN_PROGRESS:
			await get_tree().process_frame
		
		var status := ResourceLoader.load_threaded_get_status(path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			var resource := ResourceLoader.load_threaded_get(path)
			_loading.erase(path)
			if use_cache and resource != null:
				_cache[path] = resource
				# 初始化引用计数为1
				if not _ref_counts.has(path):
					_ref_counts[path] = 1
					ref_count_changed.emit(path, 1)
			resource_loaded.emit(path, resource)
		else:
			_loading.erase(path)
		
		loaded += 1
		load_progress.emit(loaded, total)
	
	preload_completed.emit()


## 增加资源的引用计数
## 返回增加后的引用计数，如果资源不存在返回-1
func retain(path: String) -> int:
	if not _cache.has(path):
		return -1
	
	if not _ref_counts.has(path):
		_ref_counts[path] = 1
	else:
		_ref_counts[path] += 1
	
	var count: int = _ref_counts[path]
	ref_count_changed.emit(path, count)
	return count


## 减少资源的引用计数
## 返回减少后的引用计数，如果资源不存在返回-1
func release(path: String) -> int:
	if not _ref_counts.has(path):
		return -1
	
	_ref_counts[path] -= 1
	var count: int = _ref_counts[path]
	
	if count <= 0:
		_ref_counts.erase(path)
		_cache.erase(path)
		ref_count_changed.emit(path, 0)
		return 0
	
	ref_count_changed.emit(path, count)
	return count


## 取消指定资源的加载
## 返回是否成功取消
func cancel_load(path: String) -> bool:
	# 从待加载队列中移除
	for i in range(_pending_loads.size()):
		if _pending_loads[i].path == path:
			_pending_loads.remove_at(i)
			return true
	
	# 注意：Godot的ResourceLoader不支持取消正在进行的线程加载
	# 只能取消队列中等待的任务
	return false


## 取消所有待加载的资源
func cancel_all_loads() -> void:
	_pending_loads.clear()


func get_cached(path: String) -> Resource:
	return _cache.get(path)


func has_cached(path: String) -> bool:
	return _cache.has(path)


func is_loading(path: String) -> bool:
	return _loading.has(path)


## 检查资源是否在待加载队列中
func is_pending(path: String) -> bool:
	for item in _pending_loads:
		if item.path == path:
			return true
	return false


## 获取资源的引用计数
func get_ref_count(path: String) -> int:
	return _ref_counts.get(path, 0)


func unload(path: String) -> void:
	_cache.erase(path)
	_ref_counts.erase(path)


func unload_batch(paths: Array[String]) -> void:
	for path in paths:
		_cache.erase(path)
		_ref_counts.erase(path)


func clear_cache() -> void:
	_cache.clear()
	_ref_counts.clear()


func get_cache_count() -> int:
	return _cache.size()


func get_loading_count() -> int:
	return _loading.size()


## 获取待加载队列大小
func get_pending_count() -> int:
	return _pending_loads.size()
