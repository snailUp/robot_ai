# 特效播放管理器开发计划

## 目标
创建一个统一的特效播放管理器，使用对象池管理特效生命周期，遵循框架业务分离规则。

## 架构设计

### 框架层 (framecore/)
- **EffectManager** (`framecore/effect/effect_manager.gd`)
  - 特效对象池管理
  - 特效生命周期管理
  - 特效类型注册和获取
  - 静态方法调用

- **IEffect** (`framecore/effect/i_effect.gd`)
  - 特效接口定义
  - 实现生命周期回调
  - 支持参数配置

### 业务层 (game/effect/)
- **DashTrail** (`game/effect/dash_trail.gd`)
  - 从 `game/boss/` 移动
  - 实现 `IEffect` 接口
  - Boss 冲锋拖尾特效

- **HitEffect** (`game/effect/hit_effect.gd`)
  - 子弹击中特效
  - 资源路径: `resources/animation/effect/gunfire`
  - 使用 AnimatedSprite2D 播放动画
  - 动画播放完成后自动回收
  - 支持自定义时长和缩放

- **DamageNumber** (`game/effect/damage_number.gd`)
  - 伤害数字显示
  - 飘动效果

## 实现步骤

### 1. 创建框架层特效接口
**文件**: `framecore/effect/i_effect.gd`

```gdscript
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
```

### 2. 创建特效管理器
**文件**: `framecore/effect/effect_manager.gd`

功能：
- 对象池管理（使用 `ObjectPool`）
- 特效类型注册表
- 生成特效方法
- 回收特效方法
- 自动回收机制（基于时间或动画完成）
- **自定义渲染层级支持**

### 3. 创建业务层特效类
**文件**: `game/effect/dash_trail.gd`
- 从 `game/boss/dash_trail.gd` 迁移
- 实现 `IEffect` 接口
- 保持原有功能不变

**文件**: `game/effect/hit_effect.gd`
- 子弹击中特效
- 资源路径: `resources/animation/effect/gunfire`
- 使用 AnimatedSprite2D 播放动画
- 动画播放完成后自动回收
- 支持自定义时长和缩放
- **子弹碰撞时自动调用**

**文件**: `game/effect/damage_number.gd`
- 伤害数字显示
- 飘动效果

### 4. 更新现有代码
**修改文件**:
- `game/boss/angry_bull.gd` - 使用 `EffectManager` 替代直接创建
- `game/boss/dash_trail.gd` - 迁移到 `game/effect/` 并实现接口
- `framecore/character/bullet.gd` - 碰撞时调用 `EffectManager.spawn("hit_effect")`
- `game/effect/hit_effect.gd` - 创建新的击中特效类

### 5. 更新 LayerManager
**文件**: `framecore/layer/layer_manager.gd`
- 添加 `get_effect_layer()` 方法（已存在）
- 确保 `add_effect()` 方法正常工作

## 设计原则

### 框架业务分离
1. **框架层不依赖业务层**
   - `EffectManager` 不引用任何业务类
   - 使用接口 `IEffect` 进行交互

2. **业务层依赖框架层**
   - 业务特效类继承或实现框架接口
   - 使用 `EffectManager` 管理生命周期

3. **可扩展性**
   - 新增特效只需实现 `IEffect` 接口
   - 通过 `EffectManager.register_type()` 注册

4. **性能优化**
   - 使用对象池复用特效节点
   - 批量回收减少 GC 压力
   - 自动回收机制防止内存泄漏

## 使用示例

### 业务层使用
```gdscript
# 生成特效（使用默认层级）
var effect = EffectManager.spawn("dash_trail", {
    "position": global_position,
    "duration": 3.0
})

# 生成特效（自定义层级）
var effect = EffectManager.spawn("dash_trail", {
    "position": global_position,
    "duration": 3.0,
    "z_index": LayerConstants.Z_EFFECT + 10  # 在特效层之上
})

# 回收特效
EffectManager.recycle(effect)

# 回收所有特效
EffectManager.recycle_all()
```

### 特效类实现
```gdscript
class_name DashTrail
extends Area2D
implements IEffect

var _duration: float = 3.0
var _timer: float = 0.0

func on_spawn() -> void:
    _timer = _duration

func on_update(delta: float) -> void:
    _timer -= delta
    if _timer <= 0:
        effect_finished.emit(self)

func on_despawn() -> void:
    # 清理资源
    pass

func set_params(params: Dictionary) -> void:
    if params.has("duration"):
        _duration = params["duration"]
    if params.has("z_index"):
        z_index = params["z_index"]
```

## 文件结构

```
framecore/
  effect/
    i_effect.gd           # 特效接口
    effect_manager.gd      # 特效管理器

game/
  effect/
    dash_trail.gd         # 冲锋拖尾特效
    hit_effect.gd          # 命中特效
    damage_number.gd       # 伤害数字
```

## 优势

1. **统一管理**: 所有特效通过 `EffectManager` 管理
2. **性能优化**: 对象池复用，减少创建销毁开销
3. **易于维护**: 集中管理，便于调试和优化
4. **框架分离**: 框架层提供能力，业务层实现逻辑
5. **类型安全**: 通过接口约束，减少运行时错误
