extends Node2D
## 关卡地图场景：管理关卡中的Boss战流程

@export var boss_scene: PackedScene

var _battle_controller: BossBattleController = null
var _player: CharacterBody2D = null
var _infinite_map: Node = null


func _enter_tree() -> void:
	LayerManager.setup(self)
	_setup_effect_manager()


func _setup_effect_manager() -> void:
	var effect_layer = LayerManager.get_effect_layer()
	if effect_layer == null:
		push_warning("[LevelMapScene] 特效层未初始化")
		return

	EffectManager.setup(effect_layer)

	# 注册特效类型
	EffectManager.register_type("dash_trail", "res://resources/prefabs/effect/dash_trail.tscn", 10)
	EffectManager.register_type("player_dash_trail", "res://resources/prefabs/effect/player_dash_trail.tscn", 20)
	EffectManager.register_type("hit_effect", "res://resources/prefabs/effect/hit_effect.tscn", 20)
	EffectManager.register_type("damage_number", "res://resources/prefabs/effect/damage_number.tscn", 30)
	EffectManager.register_type("boss_spawn", "res://resources/prefabs/effect/boss_spawn_effect.tscn", 5)


func _ready() -> void:
	print("LevelMapScene loaded")
	
	# 播放战斗音乐
	if not AudioManager.is_bgm_playing_path("res://resources/audios/music/bgm_game.mp3"):
		AudioManager.play_bgm("res://resources/audios/music/bgm_game.mp3")
	
	# 打开特效面板
	UIManager.open(UIKeys.EFFECT_PANEL())
	
	_open_game_hud()
	_setup_boss_battle()


func _open_game_hud() -> void:
	UIManager.open(UIKeys.GAME_HUD())


func _setup_boss_battle() -> void:
	_player = get_node_or_null("MapPlayer")
	_infinite_map = get_node_or_null("InfiniteMap")

	if _player == null:
		push_warning("LevelMapScene: 未找到玩家节点")
		return

	if _infinite_map == null:
		push_warning("LevelMapScene: 未找到InfiniteMap节点")
	
	# 将玩家移动到角色层
	if _player.get_parent():
		_player.get_parent().remove_child(_player)
	LayerManager.add_character(_player)
	
	_battle_controller = BossBattleController.new()
	_battle_controller.name = "BossBattleController"
	var loaded_boss_scene = AssetManager.load("res://resources/prefabs/boss/angry_bull.tscn")
	if loaded_boss_scene != null:
		_battle_controller.boss_scene = loaded_boss_scene
	_battle_controller.arena_size = Vector2(1600, 1000)
	_battle_controller.camera_zoom_out = 0.1
	_battle_controller.intro_duration = 2.0
	
	add_child(_battle_controller)
	
	_battle_controller.battle_started.connect(_on_battle_started)
	_battle_controller.battle_ended.connect(_on_battle_ended)
	
	call_deferred("_start_boss_battle")


func _start_boss_battle() -> void:
	if _battle_controller == null or _player == null:
		return
	
	_battle_controller.start_battle(_player, _player.global_position)


func _on_battle_started(_boss: Node) -> void:
	print("LevelMapScene: Boss战开始！")

	# 禁用地板无限滚动
	if _infinite_map != null:
		_infinite_map.set_process(false)
		_infinite_map.process_mode = Node.PROCESS_MODE_DISABLED


func _on_battle_ended(victory: bool) -> void:
	if victory:
		print("LevelMapScene: Boss战胜利！")
	else:
		print("LevelMapScene: Boss战失败！")

	# 恢复地板无限滚动
	if _infinite_map != null:
		_infinite_map.set_process(true)
		_infinite_map.process_mode = Node.PROCESS_MODE_INHERIT
