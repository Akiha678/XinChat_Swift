import UIKit

/// 应用级依赖容器，负责创建并持有跨页面共享的基础服务。
///
/// 页面只依赖协议，由容器在应用启动时完成具体实现的组装，便于后续替换真实服务或注入测试对象。
@MainActor
final class AppContainer {
    /// 全局唯一容器。容器及其创建的 UIKit 对象均限定在主线程访问。
    static let shared = AppContainer()

    private let networkClient: NetworkClientProtocol
    private let chatRepository: ChatRepositoryProtocol

    private init() {
        let client = NetworkClient()
        networkClient = client
        chatRepository = ChatRepository(networkClient: client)
    }

    /// 创建应用根控制器，并将共享 Repository 注入各业务模块。
    func makeRootViewController() -> UIViewController {
        RootTabBarController(repository: chatRepository)
    }
}
