import UIKit

final class RootTabBarController: UITabBarController {
    private let repository: ChatRepositoryProtocol

    init(repository: ChatRepositoryProtocol) {
        self.repository = repository
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

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
        let profile = ProfileViewController()

        viewControllers = [
            navigationController(root: messages, title: "消息", image: "message.fill"),
            navigationController(root: contacts, title: "联系人", image: "person.2.fill"),
            navigationController(root: profile, title: "我的", image: "person.crop.circle.fill")
        ]
    }

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
