extends IGameEntry
## 业务层入口：实现业务初始化逻辑

func on_framework_ready() -> void:
	# 注册业务 UI
	UIKeys.register_all()
	
	# 播放菜单音乐
	if not AudioManager.is_bgm_playing_path("res://resources/audios/music/bgm_menu.mp3"):
		AudioManager.play_bgm("res://resources/audios/music/bgm_menu.mp3")
	
	# 直接打开登录界面
	UIManager.open(UIKeys.LOGIN_PANEL())
	
	# 发出框架就绪事件
	EventBus.framework_ready.emit()
