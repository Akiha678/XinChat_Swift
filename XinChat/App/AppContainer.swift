import UIKit

@MainActor
final class AppContainer {
    static let shared = AppContainer()

    private let networkClient: NetworkClientProtocol
    private let chatRepository: ChatRepositoryProtocol

    private init() {
        let client = NetworkClient()
        networkClient = client
        chatRepository = ChatRepository(networkClient: client)
    }

    func makeRootViewController() -> UIViewController {
        RootTabBarController(repository: chatRepository)
    }
}
