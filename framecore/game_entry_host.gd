extends Node
## 业务入口宿主：框架层 Autoload，负责框架初始化和业务入口调用

var _game_entry: IGameEntry = null

func _ready() -> void:
	# 框架初始化
	ConfigManager.apply_settings()
	
	# 等待所有 Autoload 初始化完成
	await get_tree().process_frame
	
	# 加载业务入口
	_load_game_entry()
	
	# 通知业务层开始初始化
	if _game_entry:
		_game_entry.on_framework_ready()

func _load_game_entry() -> void:
	var entry_path := "res://game/game_entry.gd"
	if ResourceLoader.exists(entry_path):
		var script := load(entry_path)
		if script:
			_game_entry = script.new()
