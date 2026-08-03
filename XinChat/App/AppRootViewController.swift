import UIKit

/// 应用根协调器，根据会话状态在登录页与主 TabBar 之间切换。
final class AppRootViewController: UIViewController {
    private let authRepository: AuthRepositoryProtocol
    private let chatRepository: ChatRepositoryProtocol
    private let realtimeClient: ChatRealtimeClientProtocol
    private var contentViewController: UIViewController?

    init(
        authRepository: AuthRepositoryProtocol,
        chatRepository: ChatRepositoryProtocol,
        realtimeClient: ChatRealtimeClientProtocol
    ) {
        self.authRepository = authRepository
        self.chatRepository = chatRepository
        self.realtimeClient = realtimeClient
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = AppTheme.background
        AppSession.currentUser == nil ? showLogin(animated: false) : showMain(animated: false)
    }

    private func showLogin(animated: Bool) {
        let login = LoginViewController(viewModel: LoginViewModel(repository: authRepository))
        login.onLoginSucceeded = { [weak self] session in
            guard AppSession.signIn(session) else { return }
            self?.showMain(animated: true)
        }
        replaceContent(with: login, animated: animated)
    }

    private func showMain(animated: Bool) {
        guard let accessToken = AppSession.accessToken else {
            showLogin(animated: animated)
            return
        }
        realtimeClient.connect(accessToken: accessToken)
        let root = RootTabBarController(repository: chatRepository, realtimeClient: realtimeClient) { [weak self] in
            self?.realtimeClient.disconnect()
            AppSession.signOut()
            self?.showLogin(animated: true)
        }
        replaceContent(with: root, animated: animated)
    }

    private func replaceContent(with controller: UIViewController, animated: Bool) {
        let previous = contentViewController
        addChild(controller)
        controller.view.frame = view.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        view.addSubview(controller.view)
        controller.didMove(toParent: self)
        contentViewController = controller

        guard let previous else { return }
        let completion = {
            previous.willMove(toParent: nil)
            previous.view.removeFromSuperview()
            previous.removeFromParent()
        }
        if animated {
            controller.view.alpha = 0
            UIView.animate(withDuration: 0.25, animations: {
                controller.view.alpha = 1
                previous.view.alpha = 0
            }, completion: { _ in completion() })
        } else {
            completion()
        }
    }
}
