import SnapKit
import UIKit

/// 联系人页面，支持远端加载、下拉刷新、失败重试以及发起聊天。
final class ContactsViewController: UIViewController {
    /// 由根组装层注入添加好友页面工厂，避免当前页面直接创建 Repository。
    var makeAddFriendViewController: (() -> UIViewController)?
    var makeFriendRequestsViewController: (() -> UIViewController)?
    var makeChatViewController: ((Conversation) -> UIViewController)?

    private let viewModel: ContactsViewModel
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()
    private var contacts: [Contact] = []
    private var pendingRequestCount = 0

    init(viewModel: ContactsViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }

    // MARK: - Setup & Binding

    private func setupUI() {
        view.backgroundColor = AppTheme.background
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "person.badge.plus"),
            style: .plain,
            target: self,
            action: #selector(addFriendTapped)
        )
        navigationItem.rightBarButtonItem?.accessibilityLabel = "添加好友"
        tableView.backgroundColor = .clear
        tableView.rowHeight = 64
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ContactCell.self, forCellReuseIdentifier: ContactCell.reuseIdentifier)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        messageLabel.textColor = AppTheme.secondaryText
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        messageLabel.isHidden = true
        messageLabel.isUserInteractionEnabled = true
        messageLabel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(refresh)))

        [tableView, loadingView, messageLabel].forEach(view.addSubview)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
        loadingView.snp.makeConstraints { $0.center.equalToSuperview() }
        messageLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.leading.trailing.equalToSuperview().inset(36)
        }
    }

    private func bind() {
        viewModel.onStateChanged = { [weak self] state in self?.render(state) }
    }

    // MARK: - Rendering

    /// 根据 ViewModel 状态切换加载、内容或错误视图。
    private func render(_ state: ContactsViewModel.State) {
        tableView.refreshControl?.endRefreshing()
        switch state {
        case .idle:
            break
        case .loading:
            messageLabel.isHidden = true
            loadingView.startAnimating()
        case let .loaded(contacts, pendingRequestCount):
            loadingView.stopAnimating()
            messageLabel.isHidden = true
            self.contacts = contacts
            self.pendingRequestCount = pendingRequestCount
            tableView.reloadData()
        case let .failed(message):
            loadingView.stopAnimating()
            messageLabel.text = "\(message)\n点击重试"
            messageLabel.isHidden = false
        }
    }

    // MARK: - Actions

    @objc private func refresh() { viewModel.load() }

    @objc private func addFriendTapped() {
        guard let viewController = makeAddFriendViewController?() else { return }
        viewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(viewController, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int { 2 }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
            var configuration = cell.defaultContentConfiguration()
            configuration.text = "新的朋友"
            configuration.image = UIImage(systemName: "person.crop.circle.badge.plus")
            configuration.imageProperties.tintColor = AppTheme.tint
            configuration.secondaryText = pendingRequestCount > 0 ? "\(pendingRequestCount) 条待处理" : nil
            configuration.secondaryTextProperties.color = .systemRed
            cell.contentConfiguration = configuration
            cell.accessoryType = .disclosureIndicator
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactCell.reuseIdentifier, for: indexPath)
        (cell as? ContactCell)?.configure(contact: contacts[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        if indexPath.section == 0 {
            guard let viewController = makeFriendRequestsViewController?() else { return }
            viewController.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(viewController, animated: true)
            return
        }
        let contact = contacts[indexPath.row]
        viewModel.createConversation(with: contact) { [weak self] result in
            switch result {
            case let .success(conversation):
                guard let chatViewController = self?.makeChatViewController?(conversation) else { return }
                chatViewController.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(chatViewController, animated: true)
            case let .failure(error):
                self?.showChatError(error.localizedDescription)
            }
        }
    }

    private func showChatError(_ message: String) {
        let alert = UIAlertController(title: "无法创建聊天", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(alert, animated: true)
    }
}
