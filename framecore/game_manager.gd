extends Node
## 总控节点（可选）：协调各模块初始化顺序，在入口场景中挂载或由 launch 实例化后使用。

func _ready() -> void:
	ConfigManager.apply_settings()
	GameState.set_state(GameState.State.MENU)
	EventBus.framework_ready.emit()
