# 为 MainScene 创建 UIGamePanel 计划

## 目标
为游戏场景 MainScene 创建一个 UIGamePanel，包含退出按钮，实现 GameState 状态切换功能。

## 当前项目结构分析

### GameState 状态
- `MENU` - 菜单状态
- `PLAYING` - 游戏中状态
- `PAUSED` - 暂停状态

### GameFlow 状态映射
```gdscript
const STATE_UI_MAP := {
    GameState.State.MENU: &"login",
    GameState.State.PLAYING: &"game_hud",  # 需要创建
}
```

## 实施步骤

### 步骤 1: 创建 UIGamePanel 脚本
创建 `game/ui/game/UIGamePanel.gd`：
- 继承 UIPanel 基类
- 定义退出按钮引用
- 实现按钮点击处理：切换到 MENU 状态
- 可选：实现暂停功能

### 步骤 2: 创建 UIGamePanel 场景
创建 `resources/ui/game/UIGamePanel.tscn`：
- 根节点：Control（命名为 UIGamePanel）
- 子节点：
  - 退出按钮（Button）- 右上角
  - 可选：暂停按钮
- 绑定脚本到根节点

### 步骤 3: 更新 UIKeys 注册
修改 `game/ui_keys.gd`：
- 添加 `&"game_hud"` 到 UI_DEFINITIONS
- 添加 `GAME_HUD()` 静态方法

### 步骤 4: 验证 GameFlow 配置
确认 `game/game_flow.gd` 中：
- `STATE_UI_MAP` 已配置 `GameState.State.PLAYING: &"game_hud"`

### 步骤 5: 测试验证
- 运行项目
- 进入游戏场景
- 点击退出按钮
- 验证状态切换到 MENU
- 验证 UI 切换到登录界面

## 文件清单

### 需要创建的文件
1. `game/ui/game/.gitkeep` - 目录占位符
2. `game/ui/game/UIGamePanel.gd` - 游戏HUD脚本
3. `resources/ui/game/.gitkeep` - 目录占位符
4. `resources/ui/game/UIGamePanel.tscn` - 游戏HUD场景

### 需要修改的文件
1. `game/ui_keys.gd` - 注册 game_hud UI

## 技术细节

### UIGamePanel.gd 结构
```gdscript
extends UIPanel

@onready var exit_button: Button = $VBoxContainer/ExitButton

func _ready() -> void:
    exit_button.pressed.connect(_on_exit_button_pressed)

func _on_exit_button_pressed() -> void:
    GameState.set_state(GameState.State.MENU)

func _on_show(_data: Dictionary) -> void:
    # 刷新HUD数据
    pass
```

### UIGamePanel.tscn 结构
```
UIGamePanel (Control)
└── VBoxContainer
    └── ExitButton (Button) - 文本 "退出游戏"
```

## 预期成果
- UIGamePanel 显示在游戏场景中
- 点击退出按钮可以返回登录界面
- 状态切换流程正常工作
