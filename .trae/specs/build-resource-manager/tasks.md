# Tasks

## Phase 1: 核心架构

- [x] Task 1: 创建 AssetBundle 资源包定义类
  - [x] 1.1 定义 AssetBundle 类，包含包名、版本、资源列表、依赖包
  - [x] 1.2 实现版本比较方法
  - [x] 1.3 实现资源清单序列化/反序列化

- [x] Task 2: 创建 AssetRegistry 资源注册表
  - [x] 2.1 定义资源元信息结构（路径、引用计数、所属包、加载时间）
  - [x] 2.2 实现注册/注销资源方法
  - [x] 2.3 实现资源状态查询方法

- [x] Task 3: 创建 DependencyAnalyzer 依赖分析器
  - [x] 3.1 实现场景文件依赖解析
  - [x] 3.2 实现资源文件依赖解析
  - [x] 3.3 实现脚本文件依赖解析
  - [x] 3.4 实现循环依赖检测

## Phase 2: 资源管理核心

- [x] Task 4: 创建 AssetManager 统一资源管理器
  - [x] 4.1 实现同步/异步加载接口
  - [x] 4.2 实现引用计数管理
  - [x] 4.3 实现资源卸载逻辑
  - [x] 4.4 整合 ResourcePool 和 ScenePool

- [x] Task 5: 增强 ResourcePool
  - [x] 5.1 添加引用计数支持
  - [x] 5.2 添加加载优先级支持
  - [x] 5.3 添加加载取消支持
  - [x] 5.4 与 AssetManager 集成

## Phase 3: 打包系统

- [x] Task 6: 创建 AssetBundleBuilder 资源打包工具
  - [x] 6.1 实现 PCK 文件创建（使用 PCKPacker）
  - [x] 6.2 实现按模块分包策略
  - [x] 6.3 实现按场景分包策略
  - [x] 6.4 实现加密打包选项
  - [x] 6.5 生成资源清单文件

## Phase 4: 热更新支持

- [x] Task 7: 实现热更新功能
  - [x] 7.1 实现版本检查接口
  - [x] 7.2 实现资源下载器（支持断点续传）
  - [x] 7.3 实现外部 PCK 加载
  - [x] 7.4 实现更新应用逻辑

## Phase 5: 集成与文档

- [x] Task 8: 更新 EventBus 信号
  - [x] 8.1 添加资源管理相关信号
  - [x] 8.2 更新技术文档

- [x] Task 9: 创建使用示例
  - [x] 9.1 创建资源打包示例
  - [x] 9.2 创建热更新示例
  - [x] 9.3 创建 DLC 加载示例

# Task Dependencies

- [Task 4] depends on [Task 1, Task 2, Task 3]
- [Task 5] depends on [Task 4]
- [Task 6] depends on [Task 1]
- [Task 7] depends on [Task 4, Task 6]
- [Task 8] depends on [Task 4, Task 7]
- [Task 9] depends on [Task 6, Task 7, Task 8]
