# Phoenix 框架常见问题

## 布局文件相关

### Q: root.html.heex 和 app.html.heex 有什么区别？

A: 这两个文件是 Phoenix 框架中的布局文件,它们有以下主要区别:

#### 1. root.html.heex
- **定位**: 最外层的布局文件
- **内容**: 包含基础的 HTML 结构(`<!DOCTYPE>`, `<html>`, `<head>`, `<body>`)
- **职责**: 
  - 管理全局 meta 标签
  - 引入全局 CSS/JavaScript 文件
  - 设置 CSRF token
  - 定义页面语言等基础属性
- **加载特点**: 只加载一次,不随页面切换重新加载

#### 2. app.html.heex
- **定位**: 内层布局文件(嵌套在 root.html.heex 内)
- **内容**: 包含应用级别的共享 UI 元素
- **职责**:
  - 展示导航栏
  - 管理侧边栏
  - 显示页脚
  - 处理 Flash 消息
- **加载特点**: 随页面切换会重新渲染

#### 布局嵌套关系
