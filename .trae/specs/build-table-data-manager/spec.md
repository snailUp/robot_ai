# 表格数据管理模块 Spec

## Why
策划需要通过 Excel 编辑游戏配置数据（如物品、技能、关卡等），然后转换为 CSV 格式供 Godot 引擎动态读取，实现数据驱动的游戏设计。

## What Changes
- 新增 `TableData` 表格数据管理器，负责加载和解析 CSV 文件
- 新增 `TableLoader` CSV 解析器，支持多种数据类型转换
- 新增 `TableRegistry` 表格注册表，管理所有配置表
- 新增表格数据缓存机制，支持热重载
- 新增表格数据访问 API，支持按 ID/条件查询

## Impact
- Affected specs: 无
- Affected code: 
  - `framecore/table_data.gd` - 表格数据管理器
  - `framecore/table_loader.gd` - CSV 加载器
  - `framecore/table_registry.gd` - 表格注册表
  - `resources/tables/` - 表格文件存放目录

## ADDED Requirements

### Requirement: CSV 表格加载
系统应提供 CSV 表格文件加载功能，支持从 `res://resources/tables/` 目录加载表格数据。

#### Scenario: 加载单个表格
- **WHEN** 调用 `TableData.load_table("items")` 
- **THEN** 系统从 `res://resources/tables/items.csv` 加载数据并返回解析后的字典数组

#### Scenario: 加载不存在的表格
- **WHEN** 调用 `TableData.load_table("not_exist")`
- **THEN** 系统返回空数组并输出警告日志

### Requirement: 数据类型转换
系统应支持 CSV 数据类型自动转换，包括整数、浮点数、布尔值、数组和字典。

#### Scenario: 整数类型转换
- **WHEN** CSV 单元格值为 `"100"`
- **THEN** 解析结果为整数 `100`

#### Scenario: 布尔类型转换
- **WHEN** CSV 单元格值为 `"true"` 或 `"false"`
- **THEN** 解析结果为布尔值 `true` 或 `false`

#### Scenario: 数组类型转换
- **WHEN** CSV 单元格值为 `"[1,2,3]"` 或 `"1,2,3"`
- **THEN** 解析结果为数组 `[1, 2, 3]`

### Requirement: 表格数据查询
系统应提供便捷的表格数据查询 API。

#### Scenario: 按 ID 查询
- **WHEN** 调用 `TableData.get_by_id("items", 1001)`
- **THEN** 返回 ID 为 1001 的物品数据字典

#### Scenario: 按条件查询
- **WHEN** 调用 `TableData.query("items", func(row): return row.type == "weapon")`
- **THEN** 返回所有 type 为 "weapon" 的物品数据数组

### Requirement: 表格热重载
系统应支持表格数据热重载，便于开发调试。

#### Scenario: 热重载表格
- **WHEN** 调用 `TableData.reload("items")`
- **THEN** 重新加载 items.csv 并更新缓存

### Requirement: 表格注册
系统应支持在启动时预加载指定表格。

#### Scenario: 注册表格
- **WHEN** 在 `TableRegistry` 中注册表格
- **THEN** 框架启动时自动加载所有注册的表格

## MODIFIED Requirements
无

## REMOVED Requirements
无
