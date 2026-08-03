import SnapKit
import UIKit

final class ChatViewController: UIViewController {
    private let conversation: Conversation
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let inputContainer = UIView()
    private let textField = UITextField()
    private let sendButton = UIButton(type: .system)
    private var messages: [ChatMessage]

    init(conversation: Conversation) {
        self.conversation = conversation
        messages = [
            ChatMessage(id: UUID(), text: "你好，欢迎使用 XinChat 👋", isOutgoing: false, time: "09:30"),
            ChatMessage(id: UUID(), text: conversation.preview, isOutgoing: true, time: conversation.time)
        ]
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { nil }

    override func viewDidLoad() {
        super.viewDidLoad()
        title = conversation.name
        navigationItem.largeTitleDisplayMode = .never
        setupUI()
    }

    private func setupUI() {
        view.backgroundColor = AppTheme.background
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

        view.addSubview(tableView)
        view.addSubview(inputContainer)
        inputContainer.addSubview(textField)
        inputContainer.addSubview(sendButton)

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
            $0.top.leading.trailing.equalToSuperview()
            $0.bottom.equalTo(inputContainer.snp.top)
        }
    }

    @objc private func sendTapped() {
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines), !text.isEmpty else { return }
        messages.append(ChatMessage(id: UUID(), text: text, isOutgoing: true, time: "刚刚"))
        textField.text = nil
        tableView.reloadData()
        tableView.scrollToRow(at: IndexPath(row: messages.count - 1, section: 0), at: .bottom, animated: true)
    }
}

extension ChatViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { messages.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatMessageCell.reuseIdentifier, for: indexPath)
        (cell as? ChatMessageCell)?.configure(message: messages[indexPath.row])
        return cell
    }
}

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

    func configure(message: ChatMessage) {
        messageLabel.text = message.text
        bubbleView.backgroundColor = message.isOutgoing ? AppTheme.tint : .systemBackground
        messageLabel.textColor = message.isOutgoing ? .white : .label
        leadingConstraint?.isActive = !message.isOutgoing
        trailingConstraint?.isActive = message.isOutgoing
    }
}
