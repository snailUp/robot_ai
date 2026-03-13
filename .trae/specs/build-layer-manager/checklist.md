# Checklist

## 层级常量类
- [x] LayerConstants 类已创建，包含渲染层级常量
- [x] LayerConstants 类包含碰撞层级常量
- [x] LayerConstants 类包含碰撞预设配置函数

## 层级管理器
- [x] LayerManager 类已创建，实现单例模式
- [x] LayerManager 提供初始化方法 setup()
- [x] LayerManager 提供添加节点方法 (add_character, add_bullet, add_effect)
- [x] LayerManager 提供获取层级容器方法
- [x] LayerManager 支持 YSort 角色层

## 场景层级结构
- [x] BattleArena 包含标准层级容器节点
- [x] 各容器 z_index 设置正确
- [x] 角色层 YSort 功能正常

## 现有代码适配
- [x] BossBattleController 使用 LayerManager 添加 Boss
- [x] AngryBull 使用 LayerManager 添加特效
- [x] BulletManager 使用 LayerManager 管理子弹
- [x] LevelMapScene 使用 LayerManager 管理层级

## 功能验证
- [x] 项目运行无错误
- [x] 层级渲染顺序正确
- [x] YSort 角色排序正常
- [x] 碰撞检测正常
