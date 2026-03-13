class_name IPoolable extends RefCounted
## 可池化对象接口：定义对象池中对象的生命周期回调
## 继承此接口的对象可以自动处理状态重置

signal returned_to_pool
signal acquired_from_pool

func reset_state() -> void:
	push_warning("IPoolable.reset_state() should be overridden in subclass")

func on_acquired_from_pool() -> void:
	pass

func on_returned_to_pool() -> void:
	pass
