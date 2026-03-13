# 资源管理模块 Spec

## Why

当前框架已有基础的资源池（ResourcePool、ScenePool、ObjectPool），但缺乏完整的资源管理策略：
- 缺少资源打包（PCK）策略，无法实现 DLC/热更新
- 缺少依赖分析和依赖加载机制
- 缺少引用计数和智能卸载策略
- 缺少版本控制和差异更新能力

需要构建一个完整的资源管理系统，支持资源打包、加载、卸载、热更新等全生命周期管理。

## What Changes

- 新增 `AssetBundle` 类：资源包定义，类似 Unity AssetBundle 概念
- 新增 `AssetBundleBuilder` 类：资源打包工具，支持分包策略
- 新增 `AssetManager` 类：统一资源管理入口，整合加载/卸载/缓存
- 新增 `DependencyAnalyzer` 类：资源依赖分析器
- 新增 `AssetRegistry` 类：资源注册表，管理资源元信息
- 增强 `ResourcePool`：添加引用计数、优先级加载
- 更新 `EventBus`：添加资源管理相关信号

## Impact

- Affected specs: ResourcePool, ScenePool, EventBus
- Affected code: `framecore/pool/`, `framecore/event_bus.gd`

## ADDED Requirements

### Requirement: AssetBundle 资源包定义

系统应提供 AssetBundle 类，用于定义资源包的元信息和内容。

#### Scenario: 创建资源包定义
- **WHEN** 开发者创建 AssetBundle 配置
- **THEN** 系统应记录包名、版本、包含的资源列表、依赖的其他包

#### Scenario: 资源包版本控制
- **WHEN** 资源包更新
- **THEN** 系统应支持版本号比较，判断是否需要更新

### Requirement: AssetBundleBuilder 资源打包

系统应提供资源打包工具，支持将资源打包为 PCK 文件。

#### Scenario: 按策略打包资源
- **WHEN** 开发者执行打包命令
- **THEN** 系统应根据配置的分包策略（按模块/按场景/按更新频率）生成对应的 PCK 文件

#### Scenario: 打包加密
- **WHEN** 开发者指定加密选项
- **THEN** 系统应使用指定密钥加密 PCK 文件

#### Scenario: 生成资源清单
- **WHEN** 打包完成
- **THEN** 系统应生成资源清单文件（包含文件哈希、大小、依赖关系）

### Requirement: AssetManager 统一资源管理

系统应提供统一的资源管理入口，整合所有资源相关操作。

#### Scenario: 加载资源
- **WHEN** 开发者请求加载资源
- **THEN** 系统应检查缓存、加载资源、更新引用计数

#### Scenario: 异步加载带进度
- **WHEN** 开发者请求异步加载资源
- **THEN** 系统应提供加载进度回调，支持取消操作

#### Scenario: 卸载资源
- **WHEN** 开发者请求卸载资源
- **THEN** 系统应检查引用计数，安全卸载无引用的资源

#### Scenario: 加载外部 PCK
- **WHEN** 开发者请求加载 DLC 或 Mod
- **THEN** 系统应加载外部 PCK 文件并注册其中的资源

### Requirement: DependencyAnalyzer 依赖分析

系统应提供资源依赖分析功能。

#### Scenario: 分析资源依赖
- **WHEN** 开发者请求分析资源依赖
- **THEN** 系统应返回该资源的所有依赖列表

#### Scenario: 检测循环依赖
- **WHEN** 存在循环依赖
- **THEN** 系统应发出警告并提供循环路径信息

#### Scenario: 按依赖顺序加载
- **WHEN** 加载有依赖的资源
- **THEN** 系统应先加载依赖项，再加载目标资源

### Requirement: AssetRegistry 资源注册表

系统应维护资源注册表，记录所有已加载资源的元信息。

#### Scenario: 注册资源
- **WHEN** 资源加载成功
- **THEN** 系统应在注册表中记录资源路径、引用计数、所属包等信息

#### Scenario: 查询资源状态
- **WHEN** 开发者查询资源状态
- **THEN** 系统应返回资源是否已加载、引用计数、内存占用等信息

### Requirement: 引用计数管理

系统应实现引用计数机制，确保资源安全卸载。

#### Scenario: 增加引用
- **WHEN** 资源被获取使用
- **THEN** 系统应增加该资源的引用计数

#### Scenario: 减少引用
- **WHEN** 资源使用完毕释放
- **THEN** 系统应减少该资源的引用计数

#### Scenario: 自动卸载
- **WHEN** 资源引用计数归零
- **THEN** 系统应自动卸载该资源（可配置延迟卸载）

### Requirement: 分包策略

系统应支持多种分包策略。

#### Scenario: 按模块分包
- **WHEN** 使用模块分包策略
- **THEN** 系统应将同一功能模块的资源打包到同一 PCK

#### Scenario: 按场景分包
- **WHEN** 使用场景分包策略
- **THEN** 系统应将同一场景的资源打包到同一 PCK

#### Scenario: 按更新频率分包
- **WHEN** 使用更新频率策略
- **THEN** 系统应将常更新和不常更新的资源分开打包

### Requirement: 热更新支持

系统应支持资源热更新。

#### Scenario: 检查更新
- **WHEN** 游戏启动或手动检查
- **THEN** 系统应对比本地版本与服务器版本，返回需要更新的资源列表

#### Scenario: 下载更新
- **WHEN** 有资源需要更新
- **THEN** 系统应下载新的 PCK 文件，支持断点续传

#### Scenario: 应用更新
- **WHEN** 下载完成
- **THEN** 系统应加载新的 PCK，替换旧资源

## MODIFIED Requirements

### Requirement: ResourcePool 增强

现有 ResourcePool 应增加以下功能：

- 引用计数支持
- 加载优先级支持
- 与 AssetManager 集成
- 加载取消支持

### Requirement: EventBus 信号扩展

EventBus 应增加资源管理相关信号：

- `asset_bundle_loaded(bundle_name: String)`
- `asset_bundle_unloaded(bundle_name: String)`
- `asset_update_available(updates: Array)`
- `asset_update_progress(current: int, total: int)`

## REMOVED Requirements

无移除的需求。
