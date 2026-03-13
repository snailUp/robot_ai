# Boss 出场优化计划

## 目标
优化 Boss 出场效果，增加视觉冲击力：
1. 在 Boss 出生位置显示警告光圈（img_w.png）从小到大出现
2. 光圈闪烁效果（一闪一闪）
3. Boss 从小到大弹出出场

## 实现方案

### 1. 创建 Boss 出场特效类
**文件**: `game/effect/boss_spawn_effect.gd`

功能：
- 显示警告光圈（Sprite2D）
- 光圈闪烁动画（透明度渐变）
- 闪烁完成后触发 Boss 出场
- 自动回收

参数：
- `warning_duration`: 警告持续时间（默认 2.0 秒）
- `blink_speed`: 闪烁速度（默认 0.2 秒）
- `boss_scale`: Boss 出场缩放（默认 1.0）

### 2. 创建出场特效预制体
**文件**: `resources/prefabs/effect/boss_spawn_effect.tscn`

结构：
```
BossSpawnEffect (Node2D)
├── WarningSprite (Sprite2D) - 警告光圈
└── BossSpawnPoint (Marker2D) - Boss 出生点
```

### 3. 注册特效类型
**文件**: `game/map/level/LevelMapScene.gd`

在 `_ready()` 中注册：
```gdscript
EffectManager.register_type("boss_spawn", "res://resources/prefabs/effect/boss_spawn_effect.tscn", 5)
```

### 4. 修改 Boss 出场逻辑
**文件**: `game/boss/angry_bull.gd`

修改 `_ready()` 方法：
1. 初始时 Boss 隐藏且缩放为 0
2. 生成警告特效
3. 等待警告完成
4. Boss 从小到大弹出
5. 开始 Boss 战

### 5. 动画细节

**警告光圈动画**：
- 持续时间：2.0 秒
- 闪烁频率：0.2 秒一次
- 透明度：0.3 ↔ 1.0
- 最后 0.5 秒快速闪烁

**Boss 出场动画**：
- 缩放：0 → 1.2 → 1.0
- 持续时间：0.5 秒
- 缓动：弹性回弹

## 文件修改清单

| 文件 | 操作 | 说明 |
|------|------|------|
| `game/effect/boss_spawn_effect.gd` | 新建 | 出场特效脚本 |
| `resources/prefabs/effect/boss_spawn_effect.tscn` | 新建 | 出场特效预制体 |
| `game/map/level/LevelMapScene.gd` | 修改 | 注册特效类型 |
| `game/boss/angry_bull.gd` | 修改 | 添加出场逻辑 |

## 实现顺序

1. ✅ 创建 `boss_spawn_effect.gd` 特效脚本
2. ✅ 创建 `boss_spawn_effect.tscn` 预制体
3. ✅ 注册特效类型
4. ✅ 修改 Boss 出场逻辑
5. ✅ 测试验证
