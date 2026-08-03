import SnapKit
import UIKit

/// 单聊详情页面，展示持久化消息，并通过 WebSocket 实时接收新消息。
final class ChatViewController: UIViewController {
    private let viewModel: ChatViewModel
    private lazy var appBar = AppBarView(title: viewModel.conversation.name)
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let loadingView = UIActivityIndicatorView(style: .large)
    private let inputContainer = UIView()
    private let textField = UITextField()
    private let sendButton = UIButton(type: .system)

    init(viewModel: ChatViewModel) {
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
        navigationController?.setNavigationBarHidden(true, animated: animated)
        viewModel.activate()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        viewModel.deactivate()
    }

    // MARK: - Layout

    private func setupUI() {
        view.backgroundColor = AppTheme.background
        appBar.onBackTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.register(ChatMessageCell.self, forCellReuseIdentifier: ChatMessageCell.reuseIdentifier)
        tableView.keyboardDismissMode = .interactive

        inputContainer.backgroundColor = .systemBackground
        textField.placeholder = "输入消息"
        textField.backgroundColor = .secondarySystemBackground
        textField.layer.cornerRadius = 18
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 1))
        textField.leftViewMode = .always
        sendButton.setTitle("发送", for: .normal)
        sendButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        sendButton.addTarget(self, action: #selector(sendTapped), for: .touchUpInside)

        view.addSubview(appBar)
        view.addSubview(tableView)
        view.addSubview(loadingView)
        view.addSubview(inputContainer)
        inputContainer.addSubview(textField)
        inputContainer.addSubview(sendButton)

        appBar.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(AppBarView.contentHeight)
        }
        inputContainer.snp.makeConstraints {
            $0.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
            $0.height.equalTo(58)
        }
        textField.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(12)
            $0.centerY.equalToSuperview()
            $0.height.equalTo(38)
            $0.trailing.equalTo(sendButton.snp.leading).offset(-8)
        }
        sendButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(46)
        }
        tableView.snp.makeConstraints {
            $0.top.equalTo(appBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(inputContainer.snp.top)
        }
        loadingView.snp.makeConstraints { $0.center.equalTo(tableView) }
    }

    private func bind() {
        viewModel.onDataChanged = { [weak self] in
            guard let self else { return }
            tableView.reloadData()
            if !viewModel.messages.isEmpty {
                tableView.scrollToRow(
                    at: IndexPath(row: viewModel.messages.count - 1, section: 0),
                    at: .bottom,
                    animated: true
                )
            }
        }
        viewModel.onLoadingChanged = { [weak self] isLoading in
            isLoading ? self?.loadingView.startAnimating() : self?.loadingView.stopAnimating()
        }
        viewModel.onError = { [weak self] message in self?.showError(message) }
    }

    // MARK: - Actions

    @objc private func sendTapped() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        textField.text = nil
        viewModel.send(text: text)
    }

    private func showError(_ message: String) {
        let alert = UIAlertController(title: "操作失败", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "知道了", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.reuseIdentifier, for: indexPath)
        (cell as? ChatMessageCell)?.configure(message: viewModel.messages[indexPath.row])
        return cell
    }
}

/// 根据消息方向切换对齐方式与气泡颜色的聊天消息单元格。
private final class ChatMessageCell: UITableViewCell {
    static let reuseIdentifier = "ChatMessageCell"
    private let bubbleView = UIView()
    private let messageLabel = UILabel()
    private var leadingConstraint: Constraint?
    private var trailingConstraint: Constraint?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        messageLabel.numberOfLines = 0
        messageLabel.font = .systemFont(ofSize: 16)
        bubbleView.layer.cornerRadius = 16
        bubbleView.addSubview(messageLabel)
        contentView.addSubview(bubbleView)
        messageLabel.snp.makeConstraints { $0.edges.equalToSuperview().inset(UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)) }
        bubbleView.snp.makeConstraints {
            $0.top.bottom.equalToSuperview().inset(5)
            $0.width.lessThanOrEqualToSuperview().multipliedBy(0.76)
            leadingConstraint = $0.leading.equalToSuperview().offset(16).constraint
            trailingConstraint = $0.trailing.equalToSuperview().inset(16).constraint
        }
        trailingConstraint?.deactivate()
    }

    required init?(coder: NSCoder) { nil }

    /// 更新气泡内容，并激活与消息方向对应的水平约束。
    func configure(message: ChatMessage) {
        messageLabel.text = message.text
        bubbleView.backgroundColor = message.isOutgoing ? AppTheme.tint : .systemBackground
        messageLabel.textColor = message.isOutgoing ? .white : .label
        leadingConstraint?.isActive = !message.isOutgoing
        trailingConstraint?.isActive = message.isOutgoing
    }
}
