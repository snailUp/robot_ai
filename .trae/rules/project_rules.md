---
alwaysApply: true
---
# 项目规则

## 技术栈
- Godot 4.x (GDScript)

## 代码规范
- 函数/变量命名：snake_case
- 常量命名：UPPER_SNAKE_CASE
- 类名：PascalCase

## 框架与业务隔离规则
### 目录划分
- `framecore/` - 框架代码：通用基础模块，提供基础方法和接口
- `game/` - 业务代码：具体功能实现，调用框架接口

### 设计原则
1. **框架代码**只提供通用能力，不包含具体业务逻辑
2. **业务代码**使用框架提供的接口实现具体功能
3. 框架代码可以被业务代码调用和配置，但不应包含业务特定实现

### 框架包含
- 基类：Character, Boss, WeaponBase, Bullet
- 管理器：UIManager, AudioManager, EffectManager, LayerManager
- 通用组件：InfiniteMap, BossBattleController

## 节点创建规范
- 优先在 .tscn 场景中创建节点
- 避免脚本动态创建
- 提升可维护性

## 开发流程
1. 新功能开发完成后，需编译并自测
2. 提交前确保无编译错误

## Token 优化 (rtk) - 必须遵守
执行命令时必须使用 rtk 包装以节省 token：
- `git status` → `.\.bin\rtk git status`
- `git diff` → `.\.bin\rtk git diff`
- `git log` → `.\.bin\rtk git log -n 10`
- `git add/commit/push` → `.\.bin\rtk git add/commit/push`
- 读取文件 → `.\.bin\rtk read <file>`
- 搜索 → `.\.bin\rtk grep <pattern> .`

## 忽略目录
- `.godot/`
- `*.import`
- `.bin/`
