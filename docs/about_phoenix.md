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

## Context 相关

### Q: 什么是 Phoenix Context？如何正确使用它？

A: Context 是 Phoenix 框架中用于组织和管理业务逻辑的模块，它有以下特点和使用方式：

#### 1. Context 的定义
- **本质**: 专门用于暴露和分组相关功能的 Elixir 模块
- **目的**: 帮助划分应用程序的边界，隔离不同部分的功能
- **职责**: 封装数据访问和业务逻辑，提供清晰的公共 API

#### 2. Context 的组织结构
```
lib/my_app/
├── accounts/ # Context 目录
│ ├── user.ex # Schema 文件
│ └── credential.ex # Schema 文件
└── accounts.ex # Context 模块
```

#### 3. Context 的使用原则
- **单一职责**: 每个 Context 专注于特定的业务领域
- **封装性**: 隐藏内部实现细节，只暴露必要的公共 API
- **独立性**: Context 之间通过公共 API 交互，避免直接访问内部实现
- **多模型**: 一个 Context 可以包含多个相关的 Model（Schema）

#### 4. 常见使用场景
- **用户系统**: `Accounts` Context 处理用户认证和授权
- **产品目录**: `Catalog` Context 管理产品和分类
- **订单系统**: `Orders` Context 处理订单相关逻辑
- **支付系统**: `Payments` Context 处理支付流程

#### 5. 最佳实践
- 使用生成器创建基础结构：`mix phx.gen.context`
- Context 之间避免循环依赖
- 保持 Context 的边界清晰
- 根据业务领域而不是数据模型来划分 Context

#### 6. Context 示例
```elixir
defmodule MyApp.Accounts do
  alias MyApp.Accounts.{User, Credential}
  
  # 公共 API
  def list_users do
    Repo.all(User)
  end
  
  def get_user!(id) do
    Repo.get!(User, id)
  end
  
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end
  
  # ... 其他公共函数
end
```

#### 7. 判断标准
- 相关的功能是否应该放在同一个 Context 中？
- Context 是否变得过于庞大需要拆分？
- 是否存在跨 Context 的频繁调用？