import SnapKit
import UIKit

/// 消息首页，展示所有会话并负责进入聊天详情。
final class ConversationListViewController: UIViewController {
    var makeChatViewController: ((Conversation) -> UIViewController)?

    private let viewModel: ConversationListViewModel
    private let tableView = UITableView(frame: .zero, style: .plain)

    init(viewModel: ConversationListViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bind()
        viewModel.activate()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.load()
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = AppTheme.background
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "square.and.pencil"),
            style: .plain,
            target: self,
            action: #selector(composeTapped)
        )
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .none
        tableView.rowHeight = 78
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ConversationCell.self, forCellReuseIdentifier: ConversationCell.reuseIdentifier)
        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(refresh), for: .valueChanged)
        view.addSubview(tableView)
        tableView.snp.makeConstraints { $0.edges.equalToSuperview() }
    }

    private func bind() {
        viewModel.onDataChanged = { [weak self] in self?.tableView.reloadData() }
        viewModel.onLoadingChanged = { [weak self] isLoading in
            if !isLoading { self?.tableView.refreshControl?.endRefreshing() }
        }
        viewModel.onError = { [weak self] message in self?.showError(message) }
        viewModel.onUnreadCountChanged = { [weak self] count in
            self?.navigationController?.tabBarItem.badgeValue = count > 0 ? "\(min(count, 99))" : nil
        }
    }

    // MARK: - Actions

    @objc private func composeTapped() {
        let alert = UIAlertController(title: "发起聊天", message: "可从联系人页面选择好友开始聊天", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(alert, animated: true)
    }

    @objc private func refresh() { viewModel.load() }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "加载失败", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "重试", style: .default) { [weak self] _ in self?.viewModel.load() })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate

extension ConversationListViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.conversations.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: ConversationCell.reuseIdentifier,
            for: indexPath
        ) as? ConversationCell else { return UITableViewCell() }
        cell.configure(with: viewModel.conversations[indexPath.row])
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let conversation = viewModel.conversations[indexPath.row]
        guard let chatViewController = makeChatViewController?(conversation) else { return }
        // 聊天详情需要完整输入空间，push 后隐藏根控制器的底部 TabBar。
        chatViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatViewController, animated: true)
    }
}
