# UI 界面规范实施计划

## 目标
将 UI 界面开发规范整合到技术框架文档中，统一命名约定和目录结构。

## 规范内容

### 1. 命名规范
- **UI 面板命名**: `UIXXXPanel` 格式
  - 示例: `UISettingsPanel`, `UIMainMenuPanel`, `UIPausePanel`
  - 前缀: `UI`
  - 后缀: `Panel`
  - 中间部分: 功能名称（PascalCase）

### 2. 目录结构规范

#### 脚本目录
```
game/ui/
├── common/           # 通用 UI 组件
│   └── UIXXXPanel.gd
├── main_menu/        # 主菜单模块
│   └── UIXXXPanel.gd
├── settings/         # 设置模块
│   └── UIXXXPanel.gd
├── pause/            # 暂停菜单模块
│   └── UIXXXPanel.gd
└── .../              # 其他模块
```

#### 场景资源目录
```
resources/ui/
├── common/           # 通用 UI 组件
│   └── UIXXXPanel.tscn
├── main_menu/        # 主菜单模块
│   └── UIXXXPanel.tscn
├── settings/         # 设置模块
│   └── UIXXXPanel.tscn
├── pause/            # 暂停菜单模块
│   └── UIXXXPanel.tscn
└── .../              # 其他模块
```

## 实施步骤

### 步骤 1: 更新技术框架文档
在 `docs/TECH_FRAMEWORK.md` 中进行以下修改：

1. **更新目录约定章节（第 3 章）**
   - 修改 `game/ui/` 的说明
   - 新增 `resources/ui/` 目录说明

2. **新增 UI 界面规范章节（第 6.5 节）**
   - 命名规范
   - 目录结构规范
   - 使用示例

3. **更新 UIManager API 说明（第 5.8 节）**
   - 使用新的命名规范示例

### 步骤 2: 创建目录结构
创建必要的目录和 .gitkeep 文件：
- `resources/ui/common/`
- `resources/ui/main_menu/`
- `resources/ui/settings/`
- `resources/ui/pause/`
- `resources/ui/hud/`
- `resources/ui/dialog/`

### 步骤 3: 创建示例 UI 面板
创建一个示例 UI 面板作为参考模板：
- 脚本: `game/ui/common/UISamplePanel.gd`
- 场景: `resources/ui/common/UISamplePanel.tscn`

## 文件清单

### 需要创建的文件
1. `resources/ui/common/.gitkeep`
2. `resources/ui/main_menu/.gitkeep`
3. `resources/ui/settings/.gitkeep`
4. `resources/ui/pause/.gitkeep`
5. `resources/ui/hud/.gitkeep`
6. `resources/ui/dialog/.gitkeep`
7. `game/ui/common/UISamplePanel.gd` (示例脚本)
8. `resources/ui/common/UISamplePanel.tscn` (示例场景)

### 需要更新的文件
1. `docs/TECH_FRAMEWORK.md` - 整合 UI 规范

## 预期成果
- 技术框架文档包含完整的 UI 规范
- 统一的目录结构已创建
- 提供可复用的示例模板
