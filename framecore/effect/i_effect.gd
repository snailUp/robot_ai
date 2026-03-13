class_name IEffect
extends RefCounted

## 特效完成信号
signal effect_finished(effect: IEffect)

## 特效生命周期：初始化
func on_spawn() -> void:
	pass

## 特效生命周期：更新
func on_update(delta: float) -> void:
	pass

## 特效生命周期：回收
func on_despawn() -> void:
	pass

## 设置特效参数
func set_params(params: Dictionary) -> void:
	pass
