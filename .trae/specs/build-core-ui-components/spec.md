# 核心交互 UI 组件 Spec

## Why

游戏开发中存在大量重复的 UI 交互场景：确认对话框、消息提示、进度条、列表视图等。每次重新实现这些组件效率低下且风格不一致。需要一套高复用的核心 UI 组件库，统一风格、减少重复代码、提高开发效率。

## What Changes

- 新增 `framecore/component/` 目录
- 新增 `UIComponent` 基类：所有组件的基础类
- 新增 `MessageBox` 组件：模态对话框（确认/取消/警告）
- 新增 `Toast` 组件：轻量级消息提示
- 新增 `ProgressBar` 组件：进度条（血条/经验条/加载）
- 新增 `Tooltip` 组件：悬浮提示框
- 新增 `ListView` 组件：虚拟化滚动列表
- 新增 `ComponentManager` 组件管理器：统一管理组件实例
- 新增 `UISamplePanel` 测试面板：集成所有组件用于测试

## Impact

- Affected specs: 无
- Affected code: `framecore/` 新增 component 目录

## ADDED Requirements

### Requirement: UIComponent 基类

系统应提供 UI 组件基类，定义组件的通用生命周期和行为。

#### Scenario: 组件显示与隐藏
- **WHEN** 调用 `show_component(data)` 方法
- **THEN** 组件应显示并触发 `shown` 信号

#### Scenario: 组件销毁
- **WHEN** 调用 `destroy()` 方法
- **THEN** 组件应清理资源并从父节点移除

### Requirement: MessageBox 模态对话框

系统应提供模态对话框组件，支持多种按钮组合。

#### Scenario: 确认对话框
- **WHEN** 调用 `MessageBox.show_confirm("确定删除?", callback)`
- **THEN** 显示包含"确定"和"取消"按钮的对话框

#### Scenario: 警告对话框
- **WHEN** 调用 `MessageBox.show_alert("网络错误", callback)`
- **THEN** 显示包含"确定"按钮的警告对话框

#### Scenario: 自定义按钮
- **WHEN** 调用 `MessageBox.show({"title": "提示", "content": "内容", "buttons": ["是", "否", "取消"]})`
- **THEN** 显示包含自定义按钮的对话框

### Requirement: Toast 消息提示

系统应提供轻量级消息提示组件，支持自动消失和队列显示。

#### Scenario: 显示提示
- **WHEN** 调用 `Toast.show("操作成功")`
- **THEN** 显示提示文本，2秒后自动消失

#### Scenario: 多条提示队列
- **WHEN** 连续调用多次 `Toast.show()`
- **THEN** 提示应依次排队显示，不会重叠

#### Scenario: 自定义持续时间
- **WHEN** 调用 `Toast.show("提示", 3.0)`
- **THEN** 提示持续3秒后消失

### Requirement: ProgressBar 进度条

系统应提供进度条组件，支持多种显示模式。

#### Scenario: 设置进度
- **WHEN** 调用 `set_progress(0.5)` 或 `set_progress(50, 100)`
- **THEN** 进度条应显示对应比例

#### Scenario: 平滑动画
- **WHEN** 进度值变化
- **THEN** 进度条应平滑过渡到新值

#### Scenario: 自定义样式
- **WHEN** 设置 `bar_color`、`background_color` 等属性
- **THEN** 进度条应使用自定义样式

### Requirement: Tooltip 悬浮提示

系统应提供悬浮提示组件，跟随鼠标或目标节点显示。

#### Scenario: 跟随鼠标
- **WHEN** 设置 `follow_mouse = true`
- **THEN** 提示框应跟随鼠标位置

#### Scenario: 跟随目标
- **WHEN** 设置 `target_node`
- **THEN** 提示框应显示在目标节点附近

#### Scenario: 延迟显示
- **WHEN** 鼠标悬停超过 `delay` 秒
- **THEN** 提示框才显示

### Requirement: ListView 虚拟化列表

系统应提供虚拟化滚动列表，支持大量数据高效渲染。

#### Scenario: 设置数据
- **WHEN** 调用 `set_data(items)`
- **THEN** 列表应显示数据项

#### Scenario: 虚拟化渲染
- **WHEN** 列表包含1000+项数据
- **THEN** 只渲染可见区域的项，保持流畅

#### Scenario: 动态更新
- **WHEN** 调用 `add_item()`、`remove_item()`、`refresh()`
- **THEN** 列表应正确更新

### Requirement: ComponentManager 组件管理器

系统应提供组件管理器，统一管理组件实例和生命周期。

#### Scenario: 获取组件
- **WHEN** 调用 `ComponentManager.get_component("MessageBox")`
- **THEN** 返回或创建组件实例

#### Scenario: 组件缓存
- **WHEN** 组件隐藏后再次请求
- **THEN** 应复用已创建的实例

#### Scenario: 清理组件
- **WHEN** 调用 `ComponentManager.clear()`
- **THEN** 应销毁所有缓存的组件

### Requirement: UISamplePanel 组件测试面板

系统应提供组件测试面板，集成所有实现的组件用于功能验证和测试。

#### Scenario: 打开测试面板
- **WHEN** 通过 UIManager 打开 UISamplePanel
- **THEN** 显示包含所有组件测试入口的面板

#### Scenario: MessageBox 测试
- **WHEN** 点击 MessageBox 测试按钮
- **THEN** 显示确认对话框、警告对话框、自定义按钮对话框

#### Scenario: Toast 测试
- **WHEN** 点击 Toast 测试按钮
- **THEN** 显示不同类型的消息提示

#### Scenario: ProgressBar 测试
- **WHEN** 点击 ProgressBar 测试按钮
- **THEN** 显示进度条动画效果

#### Scenario: Tooltip 测试
- **WHEN** 鼠标悬停在 Tooltip 测试区域
- **THEN** 显示悬浮提示

#### Scenario: ListView 测试
- **WHEN** 点击 ListView 测试按钮
- **THEN** 显示包含大量数据的虚拟化列表

## MODIFIED Requirements

无修改的需求。

## REMOVED Requirements

无移除的需求。
