## 依赖分析器
## 用于分析 Godot 资源文件的依赖关系
class_name DependencyAnalyzer
extends RefCounted

var _dependency_cache: Dictionary = {}

func analyze(resource_path: String) -> Array:
	return []
