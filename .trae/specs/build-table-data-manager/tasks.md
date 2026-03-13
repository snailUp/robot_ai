# Tasks

- [x] Task 1: 创建 CSV 解析器 TableLoader
  - [x] SubTask 1.1: 实现 CSV 文件读取功能
  - [x] SubTask 1.2: 实现数据类型自动转换（int, float, bool, array, dict）
  - [x] SubTask 1.3: 处理特殊字符和转义

- [x] Task 2: 创建表格数据管理器 TableData
  - [x] SubTask 2.1: 实现表格加载和缓存机制
  - [x] SubTask 2.2: 实现 get_by_id 查询方法
  - [x] SubTask 2.3: 实现 query 条件查询方法
  - [x] SubTask 2.4: 实现 reload 热重载方法

- [x] Task 3: 创建表格注册表 TableRegistry
  - [x] SubTask 3.1: 定义表格注册列表
  - [x] SubTask 3.2: 实现批量预加载功能

- [x] Task 4: 集成到框架启动流程
  - [x] SubTask 4.1: 在 GameEntryHost 中初始化 TableRegistry
  - [x] SubTask 4.2: 更新 project.godot 添加 TableData Autoload

- [x] Task 5: 创建示例表格文件
  - [x] SubTask 5.1: 创建 items.csv 示例表格
  - [x] SubTask 5.2: 创建 skills.csv 示例表格

- [x] Task 6: 更新技术文档
  - [x] SubTask 6.1: 在 TECH_FRAMEWORK.md 中添加 TableData 模块说明

# Task Dependencies
- [Task 2] depends on [Task 1]
- [Task 3] depends on [Task 2]
- [Task 4] depends on [Task 3]
- [Task 5] 可与 [Task 1-3] 并行
- [Task 6] depends on [Task 4]
