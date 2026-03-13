class_name ButtonSound extends Control
## 按钮音效组件：点击按钮时播放音效
## 使用方式：将此脚本附加到任何按钮节点

@export var sound_path: String = "res://resources/audios/sfx/effect_button.mp3"

func _ready() -> void:
	var parent = get_parent()
	if parent and parent.has_signal("pressed"):
		parent.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	AudioManager.play_se(sound_path)
