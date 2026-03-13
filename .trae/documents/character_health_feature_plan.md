# 角色血量功能开发计划

## 目标
1. 角色头顶显示绿色血条
2. 修改角色血量时动态刷新血条
3. 被攻击时显示飘字效果（"-10"从小到大向上飘动）

## 架构设计

### 框架层 (framecore/)
- **HealthBar** (`framecore/ui/health_bar.gd`)
  - 血条 UI 组件
  - 支持平滑过渡动画
  - 可配置颜色（绿色/红色等）

### 业务层 (game/effect/)
- **DamageNumber** (`game/effect/damage_number.gd`)
  - 伤害飘字特效
  - 从小到大缩放动画
  - 向上飘动动画
  - 支持自定义颜色和数值

### 角色层
- **Character** (`framecore/character/character.gd`)
  - 添加 `hp_changed` 信号
  - 添加 `take_damage` 方法

- **Player** (`game/character/player.gd`)
  - 添加血条组件
  - 受伤时生成飘字特效

- **Boss** (`framecore/character/boss.gd`)
  - 添加血条组件
  - 受伤时生成飘字特效

## 实现步骤

### 1. 创建血条 UI 组件
**文件**: `framecore/ui/health_bar.gd`

功能：
- 显示当前血量百分比
- 平滑过渡动画
- 可配置前景色和背景色
- 可配置宽度和高度
- 跟随角色位置

### 2. 更新 Character 基类
**文件**: `framecore/character/character.gd`

修改：
- 添加 `hp_changed` 信号
- 添加 `take_damage` 方法
- 添加 `heal` 方法

### 3. 创建伤害飘字特效
**文件**: `game/effect/damage_number.gd`

功能：
- 显示伤害数值（如 "-10"）
- 从小到大缩放动画（0.5 → 1.2 → 1.0）
- 向上飘动动画
- 淡出动画
- 自动回收

### 4. 创建飘字特效预制体
**文件**: `resources/prefabs/effect/damage_number.tscn`

### 5. 更新 Player 类
**文件**: `game/character/player.gd`

修改：
- 添加血条组件
- 受伤时生成飘字特效
- 连接 `hp_changed` 信号更新血条

### 6. 更新 Boss 类
**文件**: `framecore/character/boss.gd`

修改：
- 添加血条组件
- 受伤时生成飘字特效
- 连接 `hp_changed` 信号更新血条

### 7. 注册特效类型
**文件**: `game/map/level/LevelMapScene.gd`

修改：
- 注册 `damage_number` 特效类型

## 使用示例

### 血条使用
```gdscript
# 角色受伤时自动更新血条
func take_damage(amount: int) -> void:
    current_hp = max(0, current_hp - amount)
    hp_changed.emit(current_hp, max_hp)
```

### 飘字使用
```gdscript
# 生成伤害飘字
EffectManager.spawn("damage_number", {
    "position": global_position + Vector2(0, -50),
    "value": -10,
    "color": Color.RED
})
```

## 文件结构

```
framecore/
  ui/
    health_bar.gd           # 血条组件
  character/
    character.gd            # 添加 hp_changed 信号
    boss.gd                 # 添加血条和飘字

game/
  effect/
    damage_number.gd        # 伤害飘字特效
  character/
    player.gd               # 添加血条和飘字

resources/
  prefabs/
    effect/
      damage_number.tscn    # 飘字预制体
```

## 动画效果

### 血条动画
- 血量变化时平滑过渡（0.2秒）
- 颜色渐变（绿色 → 黄色 → 红色）

### 飘字动画
1. **缩放动画** (0.3秒)
   - 0.0s: scale = 0.5
   - 0.15s: scale = 1.2
   - 0.3s: scale = 1.0

2. **移动动画** (1.0秒)
   - 向上移动 50-80 像素
   - 带有随机水平偏移

3. **淡出动画** (0.5秒)
   - 最后 0.5秒开始淡出
   - alpha: 1.0 → 0.0

## 优势

1. **统一管理**: 血条和飘字通过组件和特效管理器统一管理
2. **易于扩展**: 新增角色只需添加血条组件
3. **性能优化**: 飘字使用对象池复用
4. **框架分离**: 框架层提供能力，业务层实现逻辑
