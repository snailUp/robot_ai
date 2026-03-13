# 登录界面调整计划

## 目标
使用指定的图片资源调整登录界面的视觉效果。

## 图片资源
| 用途 | 路径 |
|------|------|
| 底图 | `resources/sprites/login/img_d.png` |
| 登录按钮 | `resources/sprites/login/img_ks.png` |
| 退出按钮 | `resources/sprites/login/img_js.png` |
| 参考图 | `resources/sprites/login/syt.png` |

## 实施步骤

### 步骤 1: 更新 UILoginPanel.tscn 场景结构
1. 添加底图 `TextureRect` 节点作为背景
   - 使用 `img_d.png` 作为纹理
   - 设置为拉伸模式填充整个屏幕

2. 修改登录按钮 `TextureButton`
   - 使用 `img_ks.png` 作为正常状态纹理
   - 移除默认文本

3. 修改退出按钮 `TextureButton`
   - 使用 `img_js.png` 作为正常状态纹理
   - 移除默认文本

4. 调整布局
   - 根据参考图 `syt.png` 调整按钮位置
   - 使用适当的锚点和偏移

### 步骤 2: 更新 UILoginPanel.gd 脚本
- 更新节点路径引用（如果需要）

---

## 文件清单

### 需要修改的文件
1. `resources/ui/login/UILoginPanel.tscn` - 更新场景结构和图片资源

### 需要检查的文件
1. `game/ui/login/UILoginPanel.gd` - 确认节点路径

---

## 场景结构预览

```
UILoginPanel (Control)
├── Background (TextureRect) - 底图 img_d.png
└── VBoxContainer
    ├── LoginButton (TextureButton) - 登录按钮 img_ks.png
    └── ExitButton (TextureButton) - 退出按钮 img_js.png
```

---

## 注意事项
1. 图片路径使用 `res://` 前缀
2. TextureButton 需要设置 `texture_normal` 属性
3. 底图需要设置 `expand_mode` 和 `stretch_mode`
