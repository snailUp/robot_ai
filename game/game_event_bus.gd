extends Node
## 业务层事件总线：定义业务相关事件，实现业务模块间解耦通信。

signal damage_vignette_requested(intensity: float, duration: float)
signal screen_shake_requested(intensity: float, duration: float)
signal player_died()
