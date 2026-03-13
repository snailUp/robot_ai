# Checklist

- [x] 角色配置表 `characters.csv` 包含所有必需字段
- [x] Character 基类能正确从配置表加载属性
- [x] Bullet 类正确实现 IPoolable 接口
- [x] Bullet 的 `reset_state()` 方法正确重置所有状态
- [x] BulletManager 正确封装 ObjectPool 操作
- [x] 子弹能从对象池正确获取和归还
- [x] 枪械组件枪口正确跟随鼠标旋转
- [x] 点击鼠标能正确发射子弹
- [x] 子弹沿正确方向飞行
- [x] 子弹碰撞后正确回收到对象池
- [x] 子弹离开屏幕后自动回收到对象池
- [x] 攻击速度限制正常工作
- [x] MapPlayer 正确继承 Character 并拥有枪械组件
- [x] 项目编译无错误
