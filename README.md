<div align="center">
  <img src="docs/images/xinchat_logo.png" width="120" alt="XinChat Logo" />

  # XinChat Swift

  一个使用 Swift、UIKit 与 MVVM 构建的通讯应用学习项目。

  [English](README_EN.md) · 简体中文
</div>

## 项目简介

XinChat 是一个持续开发中的开源 iOS 通讯应用示例。项目关注真实业务中常见的代码组织方式：通过 MVVM 管理页面状态，以 Repository 隔离数据来源，使用依赖注入完成模块组装，并集中封装网络与通用 UI。

当前版本提供账号登录、消息列表、聊天详情、远端联系人、添加好友和个人中心等基础页面，适合作为 UIKit 通讯类项目的起点或架构学习示例。

> 如果这个项目对你有帮助，欢迎点亮 Star。反馈和改进建议也非常欢迎。

## 📱 项目预览

<table>
  <tr>
    <td><img src="docs/preview/ChatList.PNG" alt="聊天列表"/></td>
    <td><img src="docs/preview/Contacts.PNG" alt="联系人"/></td>
    <td><img src="docs/preview/AddFriend.PNG" alt="添加好友"/></td>
  </tr>
</table>

## 功能

- 三栏主界面：消息、联系人、我的
- 用户名密码登录、登录状态持久化和退出登录
- 会话列表实时刷新、最近消息排序、持久化未读数和 Tab 红点
- 聊天消息气泡、历史消息加载和远端消息发送
- 联系人网络加载、下拉刷新和失败重试
- 按用户名搜索用户、发送好友申请，并防止重复提交
- 好友申请收件箱、待处理数量提示，以及同意/拒绝操作
- 从消息或联系人进入聊天详情，并自动隐藏底部 TabBar
- 浅色与深色模式适配

## 技术栈

| 类型 | 技术 | 用途 |
| --- | --- | --- |
| 语言 | Swift | 业务与界面开发 |
| UI | UIKit | 业务页面与导航结构 |
| 生命周期 | SwiftUI | App 入口和 UIKit 桥接 |
| 自动布局 | SnapKit 5.7.1 | 代码化约束布局 |
| 网络 | Alamofire 5.12.0 | HTTP 请求、校验与解码 |
| 实时通信 | URLSessionWebSocketTask | 消息推送、心跳与断线重连 |
| 安全存储 | Keychain Services | 登录访问令牌 |
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
- `AppRootViewController` 根据登录状态切换登录页与主 TabBar。
- `ViewController` 只负责布局、用户交互和状态渲染。
- `ViewModel` 组织页面数据，将请求过程转换为页面状态。
- `Repository` 隔离网络、本地数据库或缓存等数据来源。
- `NetworkClient` 统一处理请求构建、状态码验证、模型解码和错误映射。
- `AppBarView` 统一业务详情页的标题、返回和右侧操作区域，减少重复导航布局。

## 项目目录

```text
XinChat/
├── App/
│   ├── AppContainer.swift                 # 依赖注入与根页面组装
│   ├── AppRootViewController.swift        # 登录页与主界面协调
│   └── AppSession.swift                   # 当前用户会话
├── Common/
│   ├── Theme/AppTheme.swift               # 颜色与视觉令牌
│   └── UI/
│       ├── AppBarView.swift               # 通用顶部导航组件
│       └── AvatarView.swift               # 通用头像组件
├── Core/Network/
│   ├── APIEndpoint.swift                  # Endpoint 协议与接口定义
│   ├── NetworkClient.swift                # Alamofire 统一封装
│   └── NetworkError.swift                 # 网络错误映射
├── Core/Realtime/                          # WebSocket 连接与事件分发
├── Core/Security/                          # Keychain 令牌存储
├── Domain/
│   ├── Models/                            # 登录与聊天领域模型
│   └── Repositories/                      # 认证与聊天 Repository
├── Presentation/
│   ├── Login/                             # 用户名密码登录
│   ├── Root/                              # 主 TabBar 与导航栈
│   ├── ConversationList/                  # 会话列表模块
│   ├── Chat/                              # 聊天详情模块
│   ├── Contacts/                          # 联系人模块
│   ├── AddFriend/                         # 搜索用户与发送好友申请
│   ├── FriendRequests/                    # 收到的申请与同意/拒绝
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

客户端已接入配套 Spring Boot 服务，服务地址由 `AppEnvironment.serverBaseURL` 集中配置并注入 `NetworkClient`：

- `POST /auth/login`：用户名密码登录
- `GET /friends`、`GET /users/search?username=`：好友和用户名搜索
- `POST /friend-requests`：发送好友申请
- `GET /friend-requests/incoming`：获取收到的待处理申请
- `POST /friend-requests/{id}/accept|reject`：同意或拒绝申请
- `GET /conversations`、`POST /conversations/direct`：会话列表与单聊创建
- `GET/POST /conversations/{id}/messages`：历史消息与消息发送
- `POST /conversations/{id}/read`：推进当前用户的会话已读游标
- `WS /ws/chat`：Bearer Token 鉴权的实时消息事件

除登录外，所有 REST 与 WebSocket 请求都会携带 Keychain 中的 Bearer Token。服务端只从令牌解析当前用户，不接受客户端传入当前用户 ID。

完整好友流程如下：

1. 登录后进入“联系人”，点击右上角添加按钮。
2. 输入用户名，服务端返回非本人、非好友且没有待处理申请的候选用户。
3. 发送申请后，对方会在联系人页的“新的朋友”看到待处理数量。
4. 对方进入申请列表后选择同意或拒绝；同意后双方联系人列表立即可见。
5. 只有已成为好友的用户才能创建单聊，待处理或已拒绝的申请不能绕过该校验。

好友申请通过后，服务端会在同一事务中创建或复用双方单聊，并通过 `friendship.accepted` 事件通知双方刷新列表。收到 `message.created` 后客户端重新同步会话事实数据，因此最近消息、时间、排序和未读数在断线重连后仍然一致；进入聊天页面会调用已读接口，并通过 `conversation.read` 同步当前用户所有在线设备的未读状态。

后端提供密码均为 `123456` 的联调账号：`admin1` 与 `admin2` 已预置为好友，用于直接测试消息；`admin3` 没有预置好友，可用于完整测试发送申请、同意/拒绝和建立聊天。

## 贡献

欢迎提交 Issue 或 Pull Request。新增功能时请尽量保持现有分层边界，并为重要业务逻辑补充测试和必要注释。

## License

本项目基于 [MIT License](LICENSE) 开源。
