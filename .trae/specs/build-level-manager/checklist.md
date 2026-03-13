# Checklist

## 关卡配置表
- [ ] levels.csv 包含必要字段（id, chapter_id, name, difficulty, scene_path）
- [ ] chapters.csv 包含必要字段（id, name, unlock_condition, levels）

## LevelManager 数据访问
- [ ] get_level(level_id) 返回正确的关卡数据
- [ ] get_levels_by_chapter(chapter_id) 返回正确的关卡列表
- [ ] get_all_levels() 返回所有关卡数据

## LevelManager 进度管理
- [ ] get_current_level() 返回当前关卡
- [ ] get_next_level() 返回下一关
- [ ] complete_level() 正确记录通关信息

## LevelManager 解锁检查
- [ ] is_level_unlocked() 正确判断关卡解锁状态
- [ ] is_chapter_unlocked() 正确判断章节解锁状态

## LevelManager 进度持久化
- [ ] save_progress() 正确保存进度
- [ ] load_progress() 正确加载进度
- [ ] 游戏启动时自动加载进度

## 集成验证
- [ ] LevelManager 已添加到 Autoload
- [ ] 技术文档已更新
