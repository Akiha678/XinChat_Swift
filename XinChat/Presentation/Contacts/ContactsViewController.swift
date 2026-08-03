import SnapKit
import UIKit

/// 联系人页面，支持远端加载、下拉刷新、失败重试以及发起聊天。
final class ContactsViewController: UIViewController {
    private let viewModel: ContactsViewModel
    private let tableView = UITableView(frame: .zero, style: .insetGrouped)
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let messageLabel = UILabel()
    private var contacts: [Contact] = []

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
        viewModel.load()
    }

    // MARK: - Setup & Binding

    private func setupUI() {
        view.backgroundColor = AppTheme.background
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
        case let .loaded(contacts):
            loadingView.stopAnimating()
            messageLabel.isHidden = true
            self.contacts = contacts
            tableView.reloadData()
        case let .failed(message):
            loadingView.stopAnimating()
            messageLabel.text = "\(message)\n点击重试"
            messageLabel.isHidden = false
        }
    }

    // MARK: - Actions

    @objc private func refresh() { viewModel.load() }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ContactsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { contacts.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ContactCell.reuseIdentifier, for: indexPath)
        (cell as? ContactCell)?.configure(contact: contacts[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let contact = contacts[indexPath.row]
        let conversation = Conversation(
            id: UUID(), name: contact.name, preview: "开始新的聊天", time: "现在", unreadCount: 0, colorSeed: contact.id
        )
        let chatViewController = ChatViewController(conversation: conversation)
        // 与消息列表入口保持一致，聊天详情不展示底部 TabBar。
        chatViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatViewController, animated: true)
    }
}
