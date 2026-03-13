# Boss 血量条 UI 实现计划

## 目标
在 UIGamePanel 界面顶部创建一个大型的 Boss 血量条，血量条左边显示 Boss 名字。**血量条在 Boss 出场动画完成后才显示**。

## 现有结构分析

### Boss 类 (`framecore/character/boss.gd`)
- 已有 `hp_changed` 信号：`signal hp_changed(current: int, maximum: int)`
- Boss 配置包含 `name` 字段（如 "愤怒公牛"）

### Boss 出场流程
- `BossSpawnEffect` 警告光圈闪烁 2 秒
- 调用 `boss.start_battle()`
- Boss 弹出动画
- 动画完成后发送 `battle_start` 事件

### BossBattleController (`framecore/battle/boss_battle_controller.gd`)
- `battle_started` 信号：在 `_finish_intro()` 中发出
- 此时 Boss 出场动画已完成

### UIGamePanel (`resources/ui/game/UIGamePanel.tscn`)
- 当前只有退出按钮
- 需要添加 Boss 血量条 UI

## 实现步骤

### 步骤 1：创建 BossHealthBar 控件
**文件**: `game/ui/game/boss_health_bar.gd`

创建一个 Control 类型的血条组件：
- 属性：boss_name (String), current_hp (int), max_hp (int), visible (初始为 false)
- 方法：
  - `show_boss(name: String, hp: int, max_hp: int)` - 显示并设置 Boss 信息
  - `update_hp(current: int, max_hp: int)` - 更新血量
  - `hide_boss()` - 隐藏血量条
- 绘制：背景、血量条、Boss 名字
- 初始状态：隐藏

### 步骤 2：修改 UIGamePanel.tscn
**文件**: `resources/ui/game/UIGamePanel.tscn`

添加节点结构：
```
UIGamePanel
├── BossHealthBarContainer (顶部居中，初始隐藏)
│   └── BossHealthBar (自定义控件)
└── VBoxContainer (右上角退出按钮)
```

### 步骤 3：修改 UIGamePanel.gd
**文件**: `game/ui/game/UIGamePanel.gd`

- 添加 BossHealthBar 引用
- 监听 BossBattleController 的 `battle_started` 信号
- 连接 Boss 的 `hp_changed` 信号
- 在 Boss 出场完成后显示血量条

### 步骤 4：修改 BossBattleController
**文件**: `framecore/battle/boss_battle_controller.gd`

- 在 `battle_started` 信号中传递 Boss 实例
- 或通过 EventBus 发送 Boss 信息

## UI 设计

```
┌─────────────────────────────────────────────────────────────┐
│                                                             │
│     愤怒公牛  ████████████████████████░░░░░░░░░░░░           │
│               (Boss 出场动画完成后才显示)                    │
│                                                         [X] │
│                                                             │
│                    (游戏区域)                                │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

- 血量条位置：屏幕顶部居中
- Boss 名字：血量条左侧
- 血量条样式：红色/黄色/绿色渐变，带边框
- **初始隐藏，Boss 出场完成后显示**

## 出场时序

```
1. 玩家进入关卡
2. 警告光圈闪烁 2 秒
3. Boss 弹出动画 (~0.5秒)
4. Boss 出场动画完成 → 发送 battle_started 信号
5. 血量条显示（带淡入动画）
```

## 文件修改清单

| 文件 | 操作 |
|------|------|
| `game/ui/game/boss_health_bar.gd` | 新建 |
| `resources/ui/game/UIGamePanel.tscn` | 修改 |
| `game/ui/game/UIGamePanel.gd` | 修改 |
| `framecore/battle/boss_battle_controller.gd` | 修改 |

## 技术细节

### BossHealthBar 组件
```gdscript
class_name BossHealthBar
extends Control

@export var bar_height: float = 24.0
@export var bar_width: float = 400.0
@export var name_label_width: float = 120.0

var boss_name: String = ""
var current_hp: int = 100
var max_hp: int = 100

func _ready() -> void:
    visible = false  # 初始隐藏

func show_boss(name: String, hp: int, maximum: int) -> void:
    boss_name = name
    current_hp = hp
    max_hp = maximum
    visible = true
    # 可选：添加淡入动画

func update_hp(current: int, maximum: int) -> void:
    current_hp = current
    max_hp = maximum
    queue_redraw()

func hide_boss() -> void:
    visible = false

func _draw() -> void:
    # 绘制血量条
```

### 信号连接
```gdscript
# UIGamePanel.gd
func _ready() -> void:
    super._ready()
    # 监听 Boss 战开始
    EventBus.battle_started.connect(_on_battle_started)

func _on_battle_started() -> void:
    # 获取当前 Boss 实例（从 BossBattleController 或全局）
    var boss = _get_current_boss()
    if boss:
        boss_health_bar.show_boss(boss.boss_name, boss.current_hp, boss.max_hp)
        boss.hp_changed.connect(_on_boss_hp_changed)

func _on_boss_hp_changed(current: int, maximum: int) -> void:
    boss_health_bar.update_hp(current, maximum)
```

## BossBattleController 修改

```gdscript
# 在 _finish_intro() 中发送 Boss 信息
func _finish_intro() -> void:
    _unlock_player()
    battle_started.emit(_boss_instance)  # 传递 Boss 实例
```
