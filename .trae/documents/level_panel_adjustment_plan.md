# 关卡界面调整计划

## 目标
重新设计关卡选择界面，添加关卡切换功能和图标展示。

## 界面布局

```
┌────────────────────────────────────┐
│                           [退出按钮] │  ← 右上角
│                                    │
│      [←]    [关卡图标]    [→]      │  ← 中间区域
│              关卡名字               │  ← 图标下方，白色，字体100
│                                    │
└────────────────────────────────────┘
```

## 图片资源
| 用途 | 路径 |
|------|------|
| 退出按钮 | `res://resources/sprites/common/img_tc.png` |
| 左右箭头 | `res://resources/sprites/common/img_arrow.png` |
| 关卡图标 | `res://resources/sprites/level/icon/img_{id}.png` |

## 实施步骤

### 步骤 1: 更新 UILevelPanel.tscn 场景结构
1. 添加退出按钮（TextureButton）到右上角
   - 使用 `img_tc.png` 作为纹理
   - 锚点设置为右上角

2. 添加中间关卡展示区域（VBoxContainer）
   - 添加关卡图标容器（HBoxContainer）
     - 左箭头按钮（TextureButton）
       - 使用 `img_arrow.png`
       - 设置 `flip_h = true` 实现水平翻转
     
     - 关卡图标（TextureButton）
       - 原尺寸显示
       - 可点击跳转关卡
     
     - 右箭头按钮（TextureButton）
       - 使用 `img_arrow.png`（不翻转）
   
   - 添加关卡名字标签（Label）
     - 颜色：白色
     - 字体大小：100
     - 水平居中

### 步骤 2: 更新 UILevelPanel.gd 脚本
1. 添加节点引用
   - `exit_button`: 退出按钮
   - `left_button`: 左箭头按钮
   - `right_button`: 右箭头按钮
   - `level_icon`: 关卡图标
   - `level_name_label`: 关卡名字标签

2. 实现关卡切换逻辑
   - `_on_left_button_pressed()`: 切换到上一关
   - `_on_right_button_pressed()`: 切换到下一关
   - `_on_level_icon_pressed()`: 进入当前关卡

3. 实现关卡显示刷新
   - `_update_display()`: 更新关卡图标和名字

4. 使用 LevelManager 获取关卡数据

### 步骤 3: 更新关卡图标资源
- 确保 `resources/sprites/level/icon/` 目录下有 img_1~5.png

---

## 文件清单

### 需要修改的文件
1. `resources/ui/level/UILevelPanel.tscn` - 更新场景结构
2. `game/ui/level/UILevelPanel.gd` - 更新脚本逻辑

### 需要创建的目录
1. `resources/sprites/level/icon/` - 关卡图标目录

---

## 场景结构

```
UILevelPanel (Control)
├── ExitButton (TextureButton) - 右上角退出按钮
└── CenterContainer
    └── VBoxContainer
        ├── HBoxContainer
        │   ├── LeftButton (TextureButton) - 左箭头
        │   ├── LevelIcon (TextureButton) - 关卡图标
        │   └── RightButton (TextureButton) - 右箭头
        └── LevelNameLabel (Label) - 关卡名字，白色，字体100
```

---

## 代码示例

### UILevelPanel.gd
```gdscript
extends UIPanel

@onready var exit_button: TextureButton = $ExitButton
@onready var left_button: TextureButton = $CenterContainer/VBoxContainer/HBoxContainer/LeftButton
@onready var right_button: TextureButton = $CenterContainer/VBoxContainer/HBoxContainer/RightButton
@onready var level_icon: TextureButton = $CenterContainer/VBoxContainer/HBoxContainer/LevelIcon
@onready var level_name_label: Label = $CenterContainer/VBoxContainer/LevelNameLabel

var _current_level_index: int = 0
var _levels: Array[Dictionary] = []

func _ready() -> void:
    exit_button.pressed.connect(_on_exit_pressed)
    left_button.pressed.connect(_on_left_pressed)
    right_button.pressed.connect(_on_right_pressed)
    level_icon.pressed.connect(_on_level_icon_pressed)
    
    _levels = LevelManager.get_all_levels()
    _update_display()

func _update_display() -> void:
    var level = _levels[_current_level_index]
    
    # 更新关卡图标
    var icon_path = level.get("icon", "")
    if icon_path != "" and ResourceLoader.exists(icon_path):
        level_icon.texture_normal = load(icon_path)
    
    # 更新关卡名字
    level_name_label.text = level.get("name", "")
    
    # 更新箭头按钮状态
    left_button.disabled = _current_level_index == 0
    right_button.disabled = _current_level_index == _levels.size() - 1

func _on_left_pressed() -> void:
    if _current_level_index > 0:
        _current_level_index -= 1
        _update_display()

func _on_right_pressed() -> void:
    if _current_level_index < _levels.size() - 1:
        _current_level_index += 1
        _update_display()

func _on_level_icon_pressed() -> void:
    var level = _levels[_current_level_index]
    var scene_path = level.get("scene_path", "")
    if scene_path != "":
        UIManager.close_all()
        SceneNavigator.goto_scene_by_path(scene_path)
        UIManager.open(UIKeys.GAME_HUD(), {"level_id": level.get("id")})

func _on_exit_pressed() -> void:
    UIManager.close_all()
    UIManager.open(UIKeys.MENU_PANEL())
```
