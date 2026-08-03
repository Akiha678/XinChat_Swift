<div align="center">
  <img src="docs/images/xinchat_logo.png" width="120" alt="XinChat Logo" />

  # XinChat Swift

  一个使用 Swift、UIKit 与 MVVM 构建的通讯应用学习项目。

  [English](README_EN.md) · 简体中文
</div>

## 项目简介

XinChat 是一个持续开发中的开源 iOS 通讯应用示例。项目关注真实业务中常见的代码组织方式：通过 MVVM 管理页面状态，以 Repository 隔离数据来源，使用依赖注入完成模块组装，并集中封装网络与通用 UI。

当前版本提供消息列表、聊天详情、远端联系人和个人中心等基础页面，适合作为 UIKit 通讯类项目的起点或架构学习示例。

> 如果这个项目对你有帮助，欢迎点亮 Star。反馈和改进建议也非常欢迎。

## 功能

- 三栏主界面：消息、联系人、我的
- 会话列表、最近消息、时间和未读数展示
- 聊天消息气泡、文本输入和本地发送交互
- 联系人网络加载、下拉刷新和失败重试
- 从消息或联系人进入聊天详情，并自动隐藏底部 TabBar
- 浅色与深色模式适配
- 统一主题和可复用头像组件

## 技术栈

| 类型 | 技术 | 用途 |
| --- | --- | --- |
| 语言 | Swift | 业务与界面开发 |
| UI | UIKit | 业务页面与导航结构 |
| 生命周期 | SwiftUI | App 入口和 UIKit 桥接 |
| 自动布局 | SnapKit 5.7.1 | 代码化约束布局 |
| 网络 | Alamofire 5.12.0 | HTTP 请求、校验与解码 |
| 架构 | MVVM + Repository | 状态管理与数据源隔离 |
| 依赖管理 | Swift Package Manager | 第三方依赖集成 |

## 架构设计

依赖方向保持从页面层指向抽象，不让 ViewController 直接依赖 Alamofire：

```text
ViewController / Cell
        │
        ▼
    ViewModel
        │
        ▼
Repository Protocol
        │
        ▼
 NetworkClient Protocol
        │
        ▼
    Alamofire
```

- `AppContainer` 创建并持有共享服务，是应用的 Composition Root。
- `ViewController` 只负责布局、用户交互和状态渲染。
- `ViewModel` 组织页面数据，将请求过程转换为页面状态。
- `Repository` 隔离网络、本地数据库或缓存等数据来源。
- `NetworkClient` 统一处理请求构建、状态码验证、模型解码和错误映射。

## 项目目录

```text
XinChat/
├── App/
│   └── AppContainer.swift                 # 依赖注入与根页面组装
├── Common/
│   ├── Theme/AppTheme.swift               # 颜色与视觉令牌
│   └── UI/AvatarView.swift                # 通用头像组件
├── Core/Network/
│   ├── APIEndpoint.swift                  # Endpoint 协议与接口定义
│   ├── NetworkClient.swift                # Alamofire 统一封装
│   └── NetworkError.swift                 # 网络错误映射
├── Domain/
│   ├── Models/ChatModels.swift            # 领域模型
│   └── Repositories/ChatRepository.swift  # Repository 协议与实现
├── Presentation/
│   ├── Root/                              # 主 TabBar 与导航栈
│   ├── ConversationList/                  # 会话列表模块
│   ├── Chat/                              # 聊天详情模块
│   ├── Contacts/                          # 联系人模块
│   └── Profile/                           # 个人中心模块
├── ContentView.swift                      # SwiftUI/UIKit 桥接
└── XinChatApp.swift                       # 应用入口
```

## 环境要求

- macOS 与 Xcode 26.0 或更高版本
- iOS 26.0 或更高版本
- Swift Package Manager 可访问 GitHub

项目当前的 Deployment Target 为 iOS 26.0。如需兼容更早系统，请在 Xcode 中调整 Target，并检查所使用 API 的最低系统版本。

## 运行项目

1. 克隆仓库：

   ```bash
   git clone <repository-url>
   cd XinChat
   ```

2. 使用 Xcode 打开 `XinChat.xcodeproj`。
3. 等待 Swift Package Manager 自动解析 SnapKit 和 Alamofire。
4. 选择模拟器或已签名的真机，运行 `XinChat` Scheme。

命令行无签名构建示例：

```bash
xcodebuild \
  -project XinChat.xcodeproj \
  -scheme XinChat \
  -destination 'generic/platform=iOS' \
  CODE_SIGNING_ALLOWED=NO \
  build
```

## 网络配置

联系人页面当前使用 [JSONPlaceholder](https://jsonplaceholder.typicode.com/users) 作为公开演示接口。

接入真实服务时：

1. 在 `NetworkClient` 初始化时注入不同环境的 `baseURL`。
2. 在 `ChatAPI` 中增加接口和请求参数。
3. 在 Repository 中完成 DTO 到领域模型的转换。
4. 将 Token、重试、日志和证书校验等横切能力放在网络层，不要分散到页面中。

生产环境不应在源码中保存 Token、密码或私有服务地址。建议使用 `.xcconfig` 或 CI 环境变量管理环境配置。

## 当前边界与路线图

当前聊天消息和会话列表为内存演示数据，尚未接入持久化或即时通信服务。后续可逐步增加：

- 登录、注册与 Token 刷新
- WebSocket 长连接和消息收发
- SQLite/Core Data 本地消息持久化
- 会话分页、离线同步和已读回执
- 图片、语音、文件等消息类型
- 单元测试、UI 测试和持续集成

## 贡献

欢迎提交 Issue 或 Pull Request。新增功能时请尽量保持现有分层边界，并为重要业务逻辑补充测试和必要注释。

## License

本项目基于 [MIT License](LICENSE) 开源。
