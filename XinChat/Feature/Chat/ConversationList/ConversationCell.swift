import SnapKit
import UIKit

/// 会话列表单元格，展示头像、名称、最近消息、时间和未读数。
final class ConversationCell: UITableViewCell {
    static let reuseIdentifier = "ConversationCell"

    private let avatarView = AvatarView(size: 52)
    private let nameLabel = UILabel()
    private let previewLabel = UILabel()
    private let timeLabel = UILabel()
    private let badgeLabel = UILabel()
    private let separator = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { nil }

    // MARK: - Layout

    private func setupUI() {
        backgroundColor = .systemBackground
        selectionStyle = .none
        nameLabel.font = .systemFont(ofSize: 17, weight: .semibold)
        previewLabel.font = .systemFont(ofSize: 14)
        previewLabel.textColor = AppTheme.secondaryText
        previewLabel.lineBreakMode = .byTruncatingTail
        timeLabel.font = .systemFont(ofSize: 12)
        timeLabel.textColor = .tertiaryLabel
        badgeLabel.font = .systemFont(ofSize: 11, weight: .bold)
        badgeLabel.textColor = .white
        badgeLabel.backgroundColor = .systemRed
        badgeLabel.textAlignment = .center
        badgeLabel.layer.cornerRadius = 10
        badgeLabel.clipsToBounds = true
        separator.backgroundColor = .separator

        [avatarView, nameLabel, previewLabel, timeLabel, badgeLabel, separator].forEach(contentView.addSubview)
        avatarView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        timeLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(14)
            $0.trailing.equalToSuperview().inset(16)
        }
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(avatarView.snp.trailing).offset(12)
            $0.top.equalToSuperview().offset(13)
            $0.trailing.lessThanOrEqualTo(timeLabel.snp.leading).offset(-8)
        }
        previewLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(7)
            $0.trailing.lessThanOrEqualTo(badgeLabel.snp.leading).offset(-10)
        }
        badgeLabel.snp.makeConstraints {
            $0.centerY.equalTo(previewLabel)
            $0.trailing.equalToSuperview().inset(16)
            $0.height.equalTo(20)
            $0.width.greaterThanOrEqualTo(20)
        }
        separator.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.trailing.bottom.equalToSuperview()
            $0.height.equalTo(0.5)
        }
    }

    // MARK: - Configuration

    /// 使用会话展示模型更新单元格。
    func configure(with conversation: Conversation) {
        avatarView.configure(name: conversation.name, seed: conversation.colorSeed)
        nameLabel.text = conversation.name
        previewLabel.text = conversation.preview
        timeLabel.text = conversation.time
        badgeLabel.text = conversation.unreadCount > 99 ? "99+" : "\(conversation.unreadCount)"
        badgeLabel.isHidden = conversation.unreadCount == 0
    }
}
