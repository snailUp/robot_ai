# 音乐切换实现计划

## 目标
实现战斗音乐和非战斗背景音乐的自动切换，确保从game场景退出后能正确播放非战斗背景音乐。

## 音乐文件位置
- 战斗音乐：`resources/audios/music/bgm_game.mp3`
- 非战斗音乐：`resources/audios/music/bgm_menu.mp3`

## 场景与音乐映射
- login、menu、level 界面：bgm_menu.mp3
- game（战斗）界面：bgm_game.mp3

## 重要规则
- 切换界面时不重置背景音（如果已经在播放目标音乐，不要重复播放）

## 实现步骤

### 1. 在 BossBattleController 中添加音乐控制
**文件：** `framecore/battle/boss_battle_controller.gd`

- 在 `start_battle()` 方法中，战斗开始时播放战斗音乐
  - 检查当前是否已经在播放战斗音乐，避免重复播放
- 在 `end_battle()` 方法中，战斗结束时停止战斗音乐

### 2. 在 UIGamePanel 退出按钮中处理音乐切换
**文件：** `game/ui/game/UIGamePanel.gd`

- 修改 `_on_exit_button_pressed()` 方法
- 在切换场景前停止当前音乐
- 在场景切换完成后播放菜单音乐
  - 检查当前是否已经在播放菜单音乐，避免重复播放

### 3. 在 LevelMapScene 中确保菜单音乐播放
**文件：** `game/map/level/LevelMapScene.gd`

- 场景加载时检查并播放菜单音乐（如果未播放）

## 实现细节

### BossBattleController 修改
```gdscript
func start_battle(player: CharacterBody2D, spawn_position: Vector2) -> void:
    # ... 现有代码 ...
    
    # 播放战斗音乐（如果未播放）
    if not AudioManager.is_bgm_playing():
        AudioManager.play_bgm("res://resources/audios/music/bgm_game.mp3")

func end_battle(victory: bool) -> void:
    # ... 现有代码 ...
    
    # 停止战斗音乐
    AudioManager.stop_bgm()
```

### UIGamePanel 修改
```gdscript
func _on_exit_button_pressed() -> void:
    UIManager.close_all()
    
    # 停止当前音乐
    AudioManager.stop_bgm()
    
    SceneNavigator.goto_scene("entry", 5, func():
        UIManager.open(UIKeys.LEVEL_SELECT_PANEL())
        # 播放菜单音乐（如果未播放）
        if not AudioManager.is_bgm_playing():
            AudioManager.play_bgm("res://resources/audios/music/bgm_menu.mp3")
    )
```

### LevelMapScene 修改（可选）
```gdscript
func _ready() -> void:
    # 确保菜单音乐在播放
    if not AudioManager.is_bgm_playing():
        AudioManager.play_bgm("res://resources/audios/music/bgm_menu.mp3")
```

## 注意事项
1. 确保 AudioManager 已正确初始化为 Autoload
2. 音乐文件路径需要正确
3. 避免重复播放同一首音乐（使用 `is_bgm_playing()` 检查）
4. 只有从战斗场景退出时才切换音乐
5. login、menu、level 之间切换不重置背景音
