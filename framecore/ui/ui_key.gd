class_name UIKey extends RefCounted
## UI 标识符，封装 UI ID 和资源路径

var id: StringName = &""
var path: String = ""

func _init(ui_id: StringName = &"", ui_path: String = "") -> void:
	id = ui_id
	path = ui_path
