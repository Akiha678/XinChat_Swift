import SnapKit
import UIKit

final class FriendRequestCell: UITableViewCell {
    static let reuseIdentifier = "FriendRequestCell"

    private let avatarView = AvatarView(size: 48)
    private let nameLabel = UILabel()
    private let messageLabel = UILabel()
    private let acceptButton = UIButton(type: .system)
    private let rejectButton = UIButton(type: .system)
    private var onAccept: (() -> Void)?
    private var onReject: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        messageLabel.font = .systemFont(ofSize: 13)
        messageLabel.textColor = AppTheme.secondaryText
        messageLabel.numberOfLines = 2

        acceptButton.setTitle("接受", for: .normal)
        acceptButton.setTitleColor(.white, for: .normal)
        acceptButton.backgroundColor = AppTheme.tint
        acceptButton.layer.cornerRadius = 8
        rejectButton.setTitle("拒绝", for: .normal)
        rejectButton.setTitleColor(.systemRed, for: .normal)
        rejectButton.backgroundColor = .secondarySystemBackground
        rejectButton.layer.cornerRadius = 8
        acceptButton.addTarget(self, action: #selector(acceptTapped), for: .touchUpInside)
        rejectButton.addTarget(self, action: #selector(rejectTapped), for: .touchUpInside)

        [avatarView, nameLabel, messageLabel, acceptButton, rejectButton].forEach(contentView.addSubview)
        avatarView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.top.equalToSuperview().offset(14)
        }
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(avatarView.snp.trailing).offset(12)
            $0.top.equalTo(avatarView)
            $0.trailing.lessThanOrEqualTo(rejectButton.snp.leading).offset(-10)
        }
        messageLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(5)
            $0.trailing.lessThanOrEqualTo(rejectButton.snp.leading).offset(-10)
        }
        acceptButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(14)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(54)
            $0.height.equalTo(34)
        }
        rejectButton.snp.makeConstraints {
            $0.trailing.equalTo(acceptButton.snp.leading).offset(-8)
            $0.centerY.width.height.equalTo(acceptButton)
        }
    }

    required init?(coder: NSCoder) { nil }

    func configure(
        request: FriendRequest,
        processing: Bool,
        onAccept: @escaping () -> Void,
        onReject: @escaping () -> Void
    ) {
        avatarView.configure(name: request.requester.name, seed: request.requester.avatarColor)
        nameLabel.text = "\(request.requester.name)  @\(request.requester.username)"
        messageLabel.text = request.message ?? "请求添加你为好友"
        acceptButton.isEnabled = !processing
        rejectButton.isEnabled = !processing
        acceptButton.alpha = processing ? 0.5 : 1
        rejectButton.alpha = processing ? 0.5 : 1
        self.onAccept = onAccept
        self.onReject = onReject
    }

    @objc private func acceptTapped() { onAccept?() }
    @objc private func rejectTapped() { onReject?() }
}
