## 技术栈
- 网络请求：Alamofire
- 自动布局：SnapKit

## 项目架构

项目采用 UIKit + MVVM + Repository 分层，SwiftUI 仅负责应用生命周期入口：

- `App`：依赖注入与根页面组装
- `Core/Network`：Alamofire 统一请求、Endpoint 与错误映射
- `Domain`：业务模型与 Repository
- `Presentation`：页面、Cell 与 ViewModel
- `Common`：主题和可复用 UI 组件

当前包含消息列表、聊天详情、网络联系人和个人中心基础页面。联系人演示接口使用 JSONPlaceholder，实际接入后只需替换 `NetworkClient` 的 `baseURL` 和 `ChatAPI`。
