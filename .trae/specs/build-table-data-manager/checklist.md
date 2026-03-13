# Checklist

## CSV 解析器
- [ ] TableLoader 能正确读取 CSV 文件
- [ ] 整数类型转换正确（"100" -> 100）
- [ ] 浮点数类型转换正确（"3.14" -> 3.14）
- [ ] 布尔类型转换正确（"true" -> true, "false" -> false）
- [ ] 数组类型转换正确（"[1,2,3]" -> [1,2,3]）
- [ ] 字典类型转换正确（"{\"key\":\"value\"}" -> {"key":"value"}）

## 表格数据管理器
- [ ] TableData 能加载指定表格
- [ ] TableData.get_by_id 返回正确数据
- [ ] TableData.query 条件查询返回正确结果
- [ ] TableData.reload 能重新加载表格
- [ ] 表格缓存机制正常工作

## 表格注册表
- [ ] TableRegistry 能注册表格
- [ ] 框架启动时自动加载注册的表格

## 集成验证
- [ ] TableData 已添加到 Autoload
- [ ] 示例表格文件能正确加载
- [ ] 技术文档已更新
