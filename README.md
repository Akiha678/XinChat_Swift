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
├── App/                                   # 应用装配、生命周期与启动入口
│   ├── XinChatApp.swift                   # SwiftUI App 入口
│   ├── ContentView.swift                  # SwiftUI / UIKit 桥接
│   ├── AppContainer.swift                 # 依赖注入组合根 (Composition Root)
│   ├── AppRootViewController.swift        # 根页面状态协调 (登录与主界面切换)
│   ├── AppSession.swift                   # 全局用户会话与令牌状态
│   └── Assets.xcassets                    # 应用图标与静态资源
├── Core/                                  # 基础设施与通用底层共享层
│   ├── Config/AppEnvironment.swift        # 多环境集中配置 (Dev/Staging/Prod)
│   ├── Network/                           # 网络客户端封装与 API Endpoint
│   ├── Realtime/                          # WebSocket 实时通信引擎
│   ├── Security/                          # Keychain 硬件级安全存储
│   ├── Models/                            # 全局领域实体模型 (Auth/Chat Models)
│   ├── Repositories/                      # 数据仓库层 (Auth/Chat Repository)
│   └── DesignSystem/                      # 统一设计系统 (Theme 主题令牌与公共 UI 组件)
└── Feature/                               # 业务特性层 (标准 MVVM 模式)
    ├── Root/                              # 主界面 TabBar 框架
    ├── Auth/                              # 认证模块 (登录/验证码输入/找回密码)
    ├── Chat/                              # 聊天会话与消息模块 (列表与详情)
    ├── Contacts/                          # 通讯录、添加好友与好友申请
    └── Profile/                           # 个人中心与资料设置
```

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

## 贡献

欢迎提交 Issue 或 Pull Request。新增功能时请尽量保持现有分层边界，并为重要业务逻辑补充测试和必要注释。

## License

本项目基于 [MIT License](LICENSE) 开源。
