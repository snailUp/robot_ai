# 调整Menu界面计划

## 需求概述
调整Menu主菜单界面，使用图片资源创建美观的UI，包含底图和3个带图标、文本的按钮，按钮需要鼠标悬停放大动画。

## 资源文件
- 背景图: `res://resources/sprites/menu/img_dt.png`
- 关卡按钮: `res://resources/sprites/menu/img_dih.png`
- 关卡图标: `res://resources/sprites/menu/img_ditu.png`
- 装备按钮: `res://resources/sprites/menu/img_dil.png`
- 装备图标: `res://resources/sprites/menu/img_zhuangbei.png`
- 退出按钮: `res://resources/sprites/menu/img_hdih.png`
- 退出图标: `res://resources/sprites/menu/img_tuichu.png`

## 实现步骤

### 1. 修改 UIMenuPanel.tscn
- 添加Sprite2D作为底图（img_dt.png），全屏拉伸
- 移除原有的VBoxContainer和简单Button
- 创建3个按钮容器（使用TextureButton或Button）

### 2. 设计按钮结构
每个按钮包含：
- 按钮图片（img_dih.png/img_dil.png/img_hdih.png）
- 图标图片（在按钮右侧，img_ditu.png/img_zhuangbei.png/img_tuichu.png）
- 文本标签（Label或Button内置文本）
- 使用HBoxContainer实现：按钮图片 + 图标图片 + 文本
- 附加 HoverScale 组件实现鼠标放大动画

### 3. 文本描边设置（黑色描边3）
- 创建LabelSettings资源
- 设置 outline_size: 3
- 设置 outline_color: Color.BLACK (或 #000000)
- 将LabelSettings赋值给Label的settings属性

```gdscript
# 代码设置示例
var label_settings := LabelSettings.new()
label_settings.outline_size = 3
label_settings.outline_color = Color.BLACK
$Label.label_settings = label_settings
```

### 4. 使用框架HoverScale组件实现按钮放大动画
- 框架已实现 `HoverScale` 组件 (`res://framecore/component/hover_scale.gd`)
- 使用方式：将此脚本附加到按钮节点
- 可配置参数：
  - hover_scale: 悬停放大倍数（默认1.2）
  - hover_duration: 动画时长（默认0.15秒）
- 原理：鼠标进入时放大，移出时还原

### 5. 修改 UIMenuPanel.gd
- 保留按钮信号连接
- 调整按钮功能：
  - 关卡按钮 → 打开关卡选择界面
  - 装备按钮 → 打开装备界面（待实现）
  - 退出按钮 → 退出游戏

## 界面布局
```
┌─────────────────────────┐
│                         │
│      [底图背景]          │
│                         │
│  ┌──────────────────┐   │
│  │ 关卡图片+图标+文本│   │
│  └──────────────────┘   │
│  ┌──────────────────┐   │
│  │ 装备图片+图标+文本│   │
│  └──────────────────┘   │
│  ┌──────────────────┐   │
│  │ 退出图片+图标+文本│   │
│  └──────────────────┘   │
│                         │
└─────────────────────────┘
```

## 预计修改文件
1. `res://resources/ui/menu/UIMenuPanel.tscn` - 界面布局
2. `res://game/ui/menu/UIMenuPanel.gd` - 按钮逻辑
