import SnapKit
import UIKit

/// 联系人列表单元格，展示头像、姓名及账号信息。
final class ContactCell: UITableViewCell {
    static let reuseIdentifier = "ContactCell"
    private let avatarView = AvatarView(size: 44)
    private let nameLabel = UILabel()
    private let detailLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        detailLabel.font = .systemFont(ofSize: 13)
        detailLabel.textColor = AppTheme.secondaryText
        [avatarView, nameLabel, detailLabel].forEach(contentView.addSubview)
        avatarView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(avatarView.snp.trailing).offset(12)
            $0.top.equalToSuperview().offset(10)
            $0.trailing.equalToSuperview().inset(36)
        }
        detailLabel.snp.makeConstraints {
            $0.leading.trailing.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(3)
        }
    }

    required init?(coder: NSCoder) { nil }

    /// 使用联系人模型更新展示内容。
    func configure(contact: Contact) {
        avatarView.configure(name: contact.name, seed: contact.id)
        nameLabel.text = contact.name
        detailLabel.text = "@\(contact.username) · \(contact.email.lowercased())"
    }
}
