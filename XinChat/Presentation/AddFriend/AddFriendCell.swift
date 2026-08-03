import SnapKit
import UIKit

/// 添加好友候选用户单元格。
final class AddFriendCell: UITableViewCell {
    static let reuseIdentifier = "AddFriendCell"

    private let avatarView = AvatarView(size: 46)
    private let nameLabel = UILabel()
    private let detailLabel = UILabel()
    private let addButton = UIButton(type: .system)
    private var onAddTapped: (() -> Void)?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }

    required init?(coder: NSCoder) { nil }

    override func prepareForReuse() {
        super.prepareForReuse()
        onAddTapped = nil
    }

    func configure(
        contact: Contact,
        state: AddFriendViewModel.RequestState,
        onAddTapped: @escaping () -> Void
    ) {
        avatarView.configure(name: contact.name, seed: contact.id)
        nameLabel.text = contact.name
        detailLabel.text = "@\(contact.username)"
        self.onAddTapped = onAddTapped

        switch state {
        case .available:
            addButton.setTitle("添加", for: .normal)
            addButton.isEnabled = true
        case .sending:
            addButton.setTitle("发送中", for: .normal)
            addButton.isEnabled = false
        case .sent:
            addButton.setTitle("已发送", for: .normal)
            addButton.isEnabled = false
        }
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .systemBackground
        nameLabel.font = .systemFont(ofSize: 16, weight: .semibold)
        detailLabel.font = .systemFont(ofSize: 13)
        detailLabel.textColor = AppTheme.secondaryText

        addButton.titleLabel?.font = .systemFont(ofSize: 14, weight: .semibold)
        addButton.backgroundColor = AppTheme.tint.withAlphaComponent(0.12)
        addButton.layer.cornerRadius = 8
        addButton.addTarget(self, action: #selector(addTapped), for: .touchUpInside)

        [avatarView, nameLabel, detailLabel, addButton].forEach(contentView.addSubview)
        avatarView.snp.makeConstraints {
            $0.leading.equalToSuperview().offset(16)
            $0.centerY.equalToSuperview()
        }
        addButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
            $0.width.equalTo(68)
            $0.height.equalTo(34)
        }
        nameLabel.snp.makeConstraints {
            $0.leading.equalTo(avatarView.snp.trailing).offset(12)
            $0.top.equalToSuperview().offset(13)
            $0.trailing.lessThanOrEqualTo(addButton.snp.leading).offset(-12)
        }
        detailLabel.snp.makeConstraints {
            $0.leading.equalTo(nameLabel)
            $0.top.equalTo(nameLabel.snp.bottom).offset(4)
            $0.trailing.lessThanOrEqualTo(addButton.snp.leading).offset(-12)
        }
    }

    @objc private func addTapped() { onAddTapped?() }
}
