# 框架层入口与业务层隔离计划

## 目标
将入口脚本 `launch` 从业务层移到框架层，实现框架初始化后调用业务层入口，达到框架与业务的完全隔离。

## 当前架构问题

```
game/
└── launch.gd          # 业务层入口（混合了框架初始化和业务初始化）

scene/
└── launch.tscn        # 入口场景（引用业务层脚本）
```

**问题**：
1. 入口场景引用业务层脚本，框架无法独立复用
2. 框架初始化逻辑和业务初始化逻辑混在一起

## 目标架构

```
framecore/
├── launch.gd              # 框架层入口（主场景）
├── launch.tscn            # 框架层入口场景
├── interfaces/
│   └── igame_entry.gd     # 业务入口接口
└── game_entry_host.gd     # 业务入口宿主（Autoload）

game/
└── game_entry.gd          # 业务层入口实现
```

## 实施步骤

### 步骤 1: 创建业务入口接口
创建 `framecore/interfaces/igame_entry.gd`：
- 定义 `on_framework_ready()` 方法
- 业务层实现此接口完成业务初始化

### 步骤 2: 创建业务入口宿主
创建 `framecore/game_entry_host.gd`：
- 作为 Autoload
- 自动加载业务层入口脚本
- 调用业务入口的初始化方法

### 步骤 3: 创建框架层入口
创建 `framecore/launch.gd` 和 `framecore/launch.tscn`：
- 框架初始化逻辑
- 等待所有 Autoload 初始化完成
- 通知业务层入口开始初始化

### 步骤 4: 创建业务层入口
创建 `game/game_entry.gd`：
- 实现 `IGameEntry` 接口
- 注册业务 UI
- 设置初始游戏状态
- 发出框架就绪事件

### 步骤 5: 更新 project.godot
- 添加 `GameEntryHost` Autoload
- 更新主场景路径

### 步骤 6: 清理旧文件
- 删除 `game/launch.gd`
- 删除 `scene/launch.tscn`

## 文件清单

### 需要创建的文件
1. `framecore/interfaces/igame_entry.gd` - 业务入口接口
2. `framecore/game_entry_host.gd` - 业务入口宿主
3. `framecore/launch.gd` - 框架层入口脚本
4. `framecore/launch.tscn` - 框架层入口场景
5. `game/game_entry.gd` - 业务层入口实现

### 需要修改的文件
1. `project.godot` - 添加 Autoload，更新主场景

### 需要删除的文件
1. `game/launch.gd` - 旧业务入口
2. `scene/launch.tscn` - 旧入口场景

## 技术细节

### IGameEntry 接口
```gdscript
class_name IGameEntry extends RefCounted
## 业务入口接口：定义业务层初始化的标准方法

func on_framework_ready() -> void:
    pass
```

### GameEntryHost 宿主
```gdscript
extends Node
## 业务入口宿主：框架层 Autoload，持有业务层 IGameEntry 引用

var _game_entry: IGameEntry = null

func _ready() -> void:
    _load_game_entry()

func _load_game_entry() -> void:
    var entry_path := "res://game/game_entry.gd"
    if ResourceLoader.exists(entry_path):
        var script := load(entry_path)
        if script:
            _game_entry = script.new()

func on_framework_ready() -> void:
    if _game_entry:
        _game_entry.on_framework_ready()
```

### 框架层入口 launch.gd
```gdscript
extends Node
## 框架层入口：负责框架初始化，然后通知业务层

func _ready() -> void:
    # 框架初始化
    ConfigManager.apply_settings()
    
    # 等待所有 Autoload 初始化完成
    await get_tree().process_frame
    
    # 通知业务层开始初始化
    GameEntryHost.on_framework_ready()
```

### 业务层入口 game_entry.gd
```gdscript
extends IGameEntry
## 业务层入口：实现业务初始化逻辑

func on_framework_ready() -> void:
    # 注册业务 UI
    UIKeys.register_all()
    
    # 设置初始状态
    GameState.set_state(GameState.State.LOGIN)
    
    # 发出框架就绪事件
    EventBus.framework_ready.emit()
```

## 初始化流程

```
启动
    │
    │ 1. Autoloads 加载
    │    - EventBus, ConfigManager, GameState...
    │    - GameEntryHost (加载业务入口脚本)
    │
    │ 2. 主场景 launch.tscn 加载
    │    - launch.gd _ready()
    │    - ConfigManager.apply_settings()
    │    - await process_frame
    │
    │ 3. 框架通知业务层
    │    - GameEntryHost.on_framework_ready()
    │
    │ 4. 业务层初始化
    │    - GameEntry.on_framework_ready()
    │    - UIKeys.register_all()
    │    - GameState.set_state(LOGIN)
    │    - EventBus.framework_ready.emit()
    │
    ▼
登录界面
```

## 架构优势

1. **框架独立复用**
   - `framecore/` 完全独立，可直接复制到其他项目

2. **职责清晰**
   - 框架层：初始化框架、管理生命周期
   - 业务层：实现业务逻辑、定义业务入口

3. **易于扩展**
   - 业务层只需实现 `IGameEntry` 接口
   - 框架层自动调用业务初始化

## 预期成果
- 框架层入口与业务层完全隔离
- 框架可独立复用到其他项目
- 业务层只需实现入口接口
