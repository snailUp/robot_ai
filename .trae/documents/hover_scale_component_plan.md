# 创建鼠标悬停放大组件计划

## 目标
创建一个可复用的UI组件，当鼠标进入时放大，移出时还原大小。

## 实施步骤

### 步骤 1: 创建 HoverScale 组件
在 `framecore/component/` 目录下创建 `hover_scale.gd`：
- 继承自 `UIComponent`
- 配置参数：
  - `hover_scale: float = 1.2` - 放大倍数
  - `hover_duration: float = 0.15` - 动画时长
- 实现功能：
  - `_ready()`: 记录原始大小，连接鼠标信号
  - `_on_mouse_entered()`: 播放放大动画
  - `_on_mouse_exited()`: 播放还原动画
  - `_tween_scale()`: 使用 Tween 动画缩放

### 步骤 2: 测试验证
在登录界面的按钮上添加 HoverScale 组件进行测试

---

## 文件清单

### 需要创建的文件
1. `framecore/component/hover_scale.gd` - 悬停放大组件脚本

---

## 代码示例

### hover_scale.gd
```gdscript
class_name HoverScale extends UIComponent
## 悬停放大组件：鼠标进入时放大，移出时还原大小

@export var hover_scale: float = 1.2
@export var hover_duration: float = 0.15

var _original_scale: Vector2 = Vector2.ONE
var _tween: Tween = null

func _ready() -> void:
    super._ready()
    _original_scale = scale
    mouse_entered.connect(_on_mouse_entered)
    mouse_exited.connect(_on_mouse_exited)

func _on_mouse_entered() -> void:
    _tween_scale(_original_scale * hover_scale)

func _on_mouse_exited() -> void:
    _tween_scale(_original_scale)

func _tween_scale(target_scale: Vector2) -> void:
    if _tween and _tween.is_valid():
        _tween.kill()
    _tween = create_tween()
    _tween.tween_property(self, "scale", target_scale, hover_duration).set_ease(Tween.Ease.OUT)
```

---

## 使用方式

1. 将 `HoverScale` 组件添加到需要悬停效果的 Control 节点
2. 在检查器中调整 `hover_scale` 和 `hover_duration` 参数

---

## 注意事项

1. 继承自 `UIComponent`，与现有组件体系一致
2. 使用 `Tween` 实现平滑动画效果
3. 使用 `@export` 导出变量，方便在检查器中配置
