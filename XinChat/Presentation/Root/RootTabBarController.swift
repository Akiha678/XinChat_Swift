import UIKit

/// 应用主导航容器，为消息、联系人和个人中心分别维护独立导航栈。
final class RootTabBarController: UITabBarController {
    private let repository: ChatRepositoryProtocol
    private let onLogout: () -> Void
    private let realtimeClient: ChatRealtimeClientProtocol

    init(
        repository: ChatRepositoryProtocol,
        realtimeClient: ChatRealtimeClientProtocol,
        onLogout: @escaping () -> Void
    ) {
        self.repository = repository
        self.realtimeClient = realtimeClient
        self.onLogout = onLogout
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        tabBar.tintColor = AppTheme.tint
        tabBar.backgroundColor = .systemBackground

        let messages = ConversationListViewController(
            viewModel: ConversationListViewModel(repository: repository)
        )
        let contacts = ContactsViewController(
            viewModel: ContactsViewModel(repository: repository)
        )
        // 页面创建职责保留在根组装层，联系人模块只负责触发导航。
        let addFriendRepository = repository
        contacts.makeAddFriendViewController = {
            AddFriendViewController(
                viewModel: AddFriendViewModel(repository: addFriendRepository)
            )
        }
        let realtimeClient = realtimeClient
        let chatFactory: (Conversation) -> UIViewController = { conversation in
            ChatViewController(
                viewModel: ChatViewModel(
                    conversation: conversation,
                    repository: addFriendRepository,
                    realtimeClient: realtimeClient
                )
            )
        }
        messages.makeChatViewController = chatFactory
        contacts.makeChatViewController = chatFactory
        guard let user = AppSession.currentUser else { return }
        let profile = ProfileViewController(user: user, onLogout: onLogout)

        viewControllers = [
            navigationController(root: messages, title: "消息", image: "message.fill"),
            navigationController(root: contacts, title: "联系人", image: "person.2.fill"),
            navigationController(root: profile, title: "我的", image: "person.crop.circle.fill")
        ]
    }

    // MARK: - Navigation Factory

    /// 为 Tab 创建独立导航控制器，确保不同模块的页面栈互不影响。
    private func navigationController(
        root: UIViewController,
        title: String,
        image: String
    ) -> UINavigationController {
        root.title = title
        let controller = UINavigationController(rootViewController: root)
        controller.tabBarItem = UITabBarItem(
            title: title,
            image: UIImage(systemName: image),
            selectedImage: nil
        )
        controller.navigationBar.prefersLargeTitles = true
        controller.navigationBar.tintColor = AppTheme.tint
        return controller
    }
}
