# 创建登录界面计划

## 目标
创建第一个 UI 界面 - 登录模块 `UILoginPanel`，包含一个按钮和一个文本显示区域，点击按钮后在文本区域显示 "Hello World"。

## 实施步骤

### 步骤 1: 创建目录结构
按照 UI 规范创建必要的目录：
- `game/ui/login/` - 存放脚本文件
- `resources/ui/login/` - 存放场景文件

### 步骤 2: 创建脚本文件
创建 `game/ui/login/UILoginPanel.gd`：
- 继承 `Control` 或 `Panel` 节点
- 定义按钮和文本显示区域的引用
- 实现按钮点击处理函数
- 点击按钮时在文本区域显示 "Hello World"

### 步骤 3: 创建场景文件
创建 `resources/ui/login/UILoginPanel.tscn`：
- 根节点：`Control` 或 `Panel`（命名为 UILoginPanel）
- 子节点：
  - `Button` - 点击按钮
  - `Label` - 文本显示区域
- 绑定脚本到根节点
- 配置节点属性（大小、位置、文本等）

### 步骤 4: 更新入口场景
修改 `scene/launch.tscn` 或创建测试场景：
- 在 `_ready()` 中注册 UILoginPanel
- 自动打开登录界面

### 步骤 5: 测试验证
- 运行项目
- 验证界面显示
- 点击按钮测试功能

## 文件清单

### 需要创建的文件
1. `game/ui/login/.gitkeep` - 目录占位符
2. `game/ui/login/UILoginPanel.gd` - 登录面板脚本
3. `resources/ui/login/.gitkeep` - 目录占位符
4. `resources/ui/login/UILoginPanel.tscn` - 登录面板场景

### 需要修改的文件
1. `scene/launch.tscn` 或 `framecore/launch.gd` - 注册并打开登录界面

## 技术细节

### 脚本结构（UILoginPanel.gd）
```gdscript
extends Control

@onready var button: Button = $Button
@onready var text_label: Label = $Label

func _ready() -> void:
    button.pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
    text_label.text = "Hello World"
```

### 场景结构（UILoginPanel.tscn）
```
UILoginPanel (Control)
├── Button (Button) - 居中显示，文本为 "Click Me"
└── Label (Label) - 用于显示 "Hello World"
```

## 预期成果
- 符合 UI 规范的登录界面
- 按钮点击功能正常
- 文本显示正常
- 可作为后续 UI 开发的参考模板
