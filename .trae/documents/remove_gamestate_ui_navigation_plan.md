# 移除 GameState 管理界面与场景跳转的计划

## 目标

1. 采用方案 A：合并 launch 到 GameEntryHost
2. 删除 GameFlow 相关文件
3. 改为在代码中直接调用 UIManager 和 SceneNavigator

***

## 实施步骤

### 步骤 1: 更新 GameEntryHost

在 `_ready()` 中完成框架初始化，然后调用业务入口。

### 步骤 2: 更新 GameEntry

直接打开登录界面。

### 步骤 3: 更新 UI 面板

直接调用 UIManager 和 SceneNavigator 进行切换：

* UILoginPanel

* UIMenuPanel

* UILevelPanel

* UIGamePanel

### 步骤 4: 更新 project.godot

* 移除 launch 主场景配置

* 移除 GameFlow Autoload

### 步骤 5: 删除文件

* `framecore/launch.gd`

* `framecore/launch.tscn`

* `game/game_flow.gd`

* `framecore/game_flow_host.gd`

* `framecore/interfaces/igame_flow.gd`

***

## 文件清单

### 需要修改的文件

1. `framecore/game_entry_host.gd` - 添加框架初始化逻辑
2. `game/game_entry.gd` - 直接打开登录界面
3. `game/ui/login/UILoginPanel.gd` - 直接切换
4. `game/ui/menu/UIMenuPanel.gd` - 直接切换
5. `game/ui/level/UILevelPanel.gd` - 直接切换
6. `game/ui/game/UIGamePanel.gd` - 直接切换
7. `project.godot` - 移除主场景和 GameFlow Autoload

### 需要删除的文件

1. `framecore/launch.gd`
2. `framecore/launch.tscn`
3. `game/game_flow.gd`
4. `framecore/game_flow_host.gd`
5. `framecore/interfaces/igame_flow.gd`

***

## 代码示例

### GameEntryHost.gd

```gdscript
extends Node
## 业务入口宿主：框架层 Autoload，负责框架初始化和业务入口调用

var _game_entry: IGameEntry = null

func _ready() -> void:
    # 框架初始化
    ConfigManager.apply_settings()
    
    # 等待所有 Autoload 初始化完成
    await get_tree().process_frame
    
    # 加载业务入口
    _load_game_entry()
    
    # 通知业务层开始初始化
    if _game_entry:
        _game_entry.on_framework_ready()

func _load_game_entry() -> void:
    var entry_path := "res://game/game_entry.gd"
    if ResourceLoader.exists(entry_path):
        var script := load(entry_path)
        if script:
            _game_entry = script.new()
```

### GameEntry.gd

```gdscript
extends IGameEntry
## 业务层入口：实现业务初始化逻辑

func on_framework_ready() -> void:
    # 注册业务 UI
    UIKeys.register_all()
    
    # 直接打开登录界面
    UIManager.open(UIKeys.LOGIN_PANEL())
    
    # 发出框架就绪事件
    EventBus.framework_ready.emit()
```

### UILoginPanel.gd

```gdscript
func _on_login_button_pressed() -> void:
    UIManager.close_all()
    UIManager.open(UIKeys.MENU_PANEL())
```

### UILevelPanel.gd

```gdscript
func _on_level1_button_pressed() -> void:
    UIManager.close_all()
    SceneNavigator.goto_scene("main")
    UIManager.open(UIKeys.GAME_HUD(), {"level_id": 1})
```

### UIGamePanel.gd

```gdscript
func _on_exit_button_pressed() -> void:
    UIManager.close_all()
    SceneNavigator.goto_scene("launch")
    UIManager.open(UIKeys.LEVEL_SELECT_PANEL())
```

***

## 架构优势

1. **简化流程** - 减少场景文件和中间层
2. **直观性** - 代码直接表达意图，易于理解
3. **灵活性** - 每个切换点可以自定义逻辑
4. **职责清晰** - GameEntryHost 负责框架初始化，GameEntry 负责业务初始化

